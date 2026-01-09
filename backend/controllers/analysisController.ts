import { Request, Response } from 'express'
import Analysis from '../models/Analysis'
import User from '../models/User'
import { GoogleGenerativeAI } from '@google/generative-ai'
import { v2 as cloudinary } from 'cloudinary'
import streamifier from 'streamifier'

// Helper to upload buffer to Cloudinary
const uploadToCloudinary = (buffer: Buffer): Promise<string> => {
  return new Promise((resolve, reject) => {
    const uploadStream = cloudinary.uploader.upload_stream(
      { folder: 'flexly_analyses' },
      (error, result) => {
        if (error) return reject(error)
        if (result) return resolve(result.secure_url)
        reject(new Error('Cloudinary upload failed'))
      }
    )
    streamifier.createReadStream(buffer).pipe(uploadStream)
  })
}

// @desc    Upload images and analyze physique
// @route   POST /api/analysis
// @access  Private
export const analyzePhysique = async (req: Request, res: Response) => {
  try {
    // Debug: Check API Key
    const apiKey = process.env.GEMINI_API_KEY
    if (!apiKey) {
      console.error('GEMINI_API_KEY is missing in environment variables')
      res
        .status(500)
        .json({ message: 'Server configuration error: API Key missing' })
      return
    }

    // Initialize Gemini (Lazy initialization to ensure env is loaded)
    const genAI = new GoogleGenerativeAI(apiKey)

    // 1. Handle Files
    const files = req.files as Express.Multer.File[]
    if (!files || files.length === 0) {
      res.status(400).json({ message: 'Please upload at least one image' })
      return
    }

    // 2. Prepare Images for Gemini & Upload to Cloudinary
    // We do this in parallel for efficiency
    const processingPromises = files.map(async (file) => {
      // Prepare for Gemini
      const geminiPart = {
        inlineData: {
          data: file.buffer.toString('base64'),
          mimeType: file.mimetype,
        },
      }

      // Upload to Cloudinary
      const cloudinaryUrl = await uploadToCloudinary(file.buffer)

      return { geminiPart, cloudinaryUrl }
    })

    const processedFiles = await Promise.all(processingPromises)
    const imageParts = processedFiles.map((f) => f.geminiPart)
    const imageUrls = processedFiles.map((f) => f.cloudinaryUrl)

    const model = genAI.getGenerativeModel({ model: 'gemini-flash-latest' })

    const prompt = `
      You are an elite bodybuilding and physique coach with a critical eye for detail. 
      Analyze the user's physique from the images provided.
      
      1. **Ratings (1.0 - 10.0)**:
         - Rate the following muscle groups: arms, chest, abs, shoulders, legs, back.
         - **CRITICAL**: If a muscle group is NOT visible in ANY of the images (e.g., legs in an upper-body selfie, or back in a front pose), return exactly **0** for that rating. Do not guess.
         - Be strict but fair. A 10 is professional Olympia level. Average fit person might be 5-7.

      2. **Advice**:
         - **Title**: Provide a short, punchy title for the advice (max 5-7 words). E.g., "Focus on Upper Chest" or "Great Symmetry, Lagging Legs".
         - **Description**: Provide a detailed, actionable analysis (2-4 sentences).
         - Explicitly mention which parts are strong and which lag behind.
         - If you rated any part as 0 (not visible), briefly mention that you couldn't see it.
         - Give specific exercise recommendations for the lagging parts.
      
      Return ONLY valid JSON in this exact format:
      {
        "ratings": {
          "arms": 7.5,
          "chest": 8.0,
          "abs": 6.5,
          "shoulders": 7.0,
          "legs": 0,
          "back": 7.8
        },
        "adviceTitle": "Focus on Upper Chest",
        "advice": "Your shoulders have great width, but your upper chest lacks fullness; prioritize incline movements. I couldn't see your legs, so I couldn't rate them."
      }
      Do not include markdown formatting like \`\`\`json.
    `

    // 3. Call Gemini API
    const result = await model.generateContent([prompt, ...imageParts])
    const response = await result.response
    const text = response.text()

    // 4. Parse Response
    // Clean up potential markdown code blocks
    const cleanJson = text
      .replace(/```json/g, '')
      .replace(/```/g, '')
      .trim()

    let aiData
    try {
      aiData = JSON.parse(cleanJson)
    } catch (e) {
      console.error('Failed to parse AI response:', text)
      throw new Error('AI Analysis failed to generate valid data')
    }

    // Calculate Overall
    const ratings: Record<string, number> = aiData.ratings

    // Filter out 0 ratings (not visible) for the average calculation
    const validRatings = Object.values(ratings).filter((r) => r > 0)

    const overall =
      validRatings.length > 0
        ? parseFloat(
            (
              validRatings.reduce((a, b) => a + b, 0) / validRatings.length
            ).toFixed(1)
          )
        : 0 // Fallback if nothing is visible

    // If overall is 0 (i.e., nothing was visible), we perhaps shouldn't save a broken analysis?
    // User requested: "if some of the results is 0 it shouldn't be counted"
    // But we still save it so they see the advice "Couldn't see legs etc".
    // However, for the USER STATS (Score), we probably shouldn't add 0.

    // 5. Save to Database
    // Use the authenticated user from the token
    const userId = (req as any).user?._id
    if (!userId) {
      res.status(401).json({ message: 'User not authenticated' })
      return
    }

    const analysis = await Analysis.create({
      user: userId,
      imageUrls, // Now these are Cloudinary URLs
      ratings: { ...ratings, overall },
      advice: aiData.advice,
      adviceTitle: aiData.adviceTitle || 'Analysis Result', // Fallback
    })

    // Update User Stats (Score, Analytics Tracked, Streak)
    const userToUpdate = await User.findById(userId)
    if (userToUpdate) {
      // 1. Analytics Tracked
      userToUpdate.analyticsTracked = (userToUpdate.analyticsTracked || 0) + 1

      // Fetch all analyses to calculate accurate averages for leaderboard
      const allAnalyses = await Analysis.find({ user: userId })

      // 2. Score (Now = Average Overall Rating)
      // We calculate it from all analyses to be accurate
      const validAnalyses = allAnalyses.filter(
        (a: any) => a.ratings.overall > 0
      )
      if (validAnalyses.length > 0) {
        const totalOverall = validAnalyses.reduce(
          (sum: number, a: any) => sum + a.ratings.overall,
          0
        )
        // Store as float with 1 decimal precision, or just float.
        // User model `score` is Number, so it handles floats.
        userToUpdate.score = parseFloat(
          (totalOverall / validAnalyses.length).toFixed(1)
        )
      } else {
        userToUpdate.score = 0
      }

      // 2.5 Recalculate Muscle Averages
      const muscleSums: any = {
        arms: 0,
        chest: 0,
        abs: 0,
        shoulders: 0,
        legs: 0,
        back: 0,
      }
      const muscleCounts: any = {
        arms: 0,
        chest: 0,
        abs: 0,
        shoulders: 0,
        legs: 0,
        back: 0,
      }

      allAnalyses.forEach((a: any) => {
        const r = a.ratings
        // Iterate keys
        Object.keys(muscleSums).forEach((key) => {
          if (r[key] && r[key] > 0) {
            muscleSums[key] += r[key]
            muscleCounts[key]++
          }
        })
      })

      const muscleAverages: any = {}
      Object.keys(muscleSums).forEach((key) => {
        muscleAverages[key] =
          muscleCounts[key] > 0
            ? parseFloat((muscleSums[key] / muscleCounts[key]).toFixed(2))
            : 0
      })

      userToUpdate.muscleStats = muscleAverages

      // 3. Streak Logic
      // Find the last analysis *before* this new one
      const lastAnalysis = await Analysis.findOne({
        user: userId,
        _id: { $ne: analysis._id },
      }).sort({ createdAt: -1 })

      if (!lastAnalysis) {
        // First analysis ever starts a streak
        userToUpdate.streak = 1
      } else {
        const lastDate = new Date(lastAnalysis.createdAt as any)
        lastDate.setHours(0, 0, 0, 0) // Normalize to midnight

        const today = new Date()
        today.setHours(0, 0, 0, 0)

        // Calculate difference in days
        const diffTime = Math.abs(today.getTime() - lastDate.getTime())
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))

        if (diffDays === 1) {
          // Consecutive day: increment streak
          userToUpdate.streak = (userToUpdate.streak || 0) + 1
        } else if (diffDays > 1) {
          // Missed a day: reset streak
          userToUpdate.streak = 1
        }
        // If diffDays == 0 (same day), maintain current streak
      }

      await userToUpdate.save()
    }

    res.status(201).json(analysis)
  } catch (error) {
    console.error('Analysis Error:', error)
    res
      .status(500)
      .json({ message: 'Analysis failed', error: (error as Error).message })
  }
}

// @desc    Get all analyses for a user
// @route   GET /api/analysis
// @access  Private
export const getAnalyses = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user?.id

    if (!userId) {
      res.status(401).json({ message: 'User not authenticated' })
      return
    }

    const analyses = await Analysis.find({ user: userId }).sort({
      createdAt: -1,
    })
    res.json(analyses)
  } catch (error) {
    res.status(500).json({ message: (error as Error).message })
  }
}

// @desc    Get analyses by user ID
// @route   GET /api/analysis/user/:userId
// @access  Private
export const getAnalysesByUserId = async (req: Request, res: Response) => {
  try {
    const userId = req.params.userId
    const analyses = await Analysis.find({ user: userId }).sort({
      createdAt: -1,
    })
    res.json(analyses)
  } catch (error) {
    res.status(500).json({ message: (error as Error).message })
  }
}
