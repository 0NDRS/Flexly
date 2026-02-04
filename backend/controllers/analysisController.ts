import { Request, Response } from 'express'
import Analysis from '../models/Analysis'
import User from '../models/User'
import { GoogleGenerativeAI } from '@google/generative-ai'
import { v2 as cloudinary } from 'cloudinary'
import streamifier from 'streamifier'

const uploadToCloudinary = (buffer: Buffer): Promise<string> => {
  return new Promise((resolve, reject) => {
    const uploadStream = cloudinary.uploader.upload_stream(
      { folder: 'flexly_analyses' },
      (error, result) => {
        if (error) return reject(error)
        if (result) return resolve(result.secure_url)
        reject(new Error('Cloudinary upload failed'))
      },
    )
    streamifier.createReadStream(buffer).pipe(uploadStream)
  })
}

export const analyzePhysique = async (req: Request, res: Response) => {
  try {
    const apiKey = process.env.GEMINI_API_KEY
    if (!apiKey) {
      console.error('GEMINI_API_KEY is missing in environment variables')
      res
        .status(500)
        .json({ message: 'Server configuration error: API Key missing' })
      return
    }

    const genAI = new GoogleGenerativeAI(apiKey)

    const files = req.files as Express.Multer.File[]
    if (!files || files.length === 0) {
      res.status(400).json({ message: 'Please upload at least one image' })
      return
    }

    const processingPromises = files.map(async (file) => {
      const geminiPart = {
        inlineData: {
          data: file.buffer.toString('base64'),
          mimeType: file.mimetype,
        },
      }

      const cloudinaryUrl = await uploadToCloudinary(file.buffer)

      return { geminiPart, cloudinaryUrl }
    })

    const processedFiles = await Promise.all(processingPromises)
    const imageParts = processedFiles.map((f) => f.geminiPart)
    const imageUrls = processedFiles.map((f) => f.cloudinaryUrl)

    const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash' })

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

    const result = await model.generateContent([prompt, ...imageParts])
    const response = await result.response
    const text = response.text()

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

    const ratings: Record<string, number> = aiData.ratings

    const validRatings = Object.values(ratings).filter((r) => r > 0)

    const overall =
      validRatings.length > 0
        ? parseFloat(
            (
              validRatings.reduce((a, b) => a + b, 0) / validRatings.length
            ).toFixed(1),
          )
        : 0

    const userId = (req as any).user?._id
    if (!userId) {
      res.status(401).json({ message: 'User not authenticated' })
      return
    }

    const analysis = await Analysis.create({
      user: userId,
      imageUrls,
      ratings: { ...ratings, overall },
      advice: aiData.advice,
      adviceTitle: aiData.adviceTitle || 'Analysis Result',
    })

    const userToUpdate = await User.findById(userId)
    if (userToUpdate) {
      userToUpdate.analyticsTracked = (userToUpdate.analyticsTracked || 0) + 1

      const allAnalyses = await Analysis.find({ user: userId })

      const validAnalyses = allAnalyses.filter(
        (a: any) => a.ratings.overall > 0,
      )
      if (validAnalyses.length > 0) {
        const totalOverall = validAnalyses.reduce(
          (sum: number, a: any) => sum + a.ratings.overall,
          0,
        )
        userToUpdate.score = parseFloat(
          (totalOverall / validAnalyses.length).toFixed(1),
        )
      } else {
        userToUpdate.score = 0
      }

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

      const lastAnalysis = await Analysis.findOne({
        user: userId,
        _id: { $ne: analysis._id },
      }).sort({ createdAt: -1 })

      if (!lastAnalysis) {
        userToUpdate.streak = 1
      } else {
        const lastDate = new Date(lastAnalysis.createdAt as any)
        lastDate.setHours(0, 0, 0, 0)
        const today = new Date()
        today.setHours(0, 0, 0, 0)

        const diffTime = Math.abs(today.getTime() - lastDate.getTime())
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))

        if (diffDays === 1) {
          userToUpdate.streak = (userToUpdate.streak || 0) + 1
        } else if (diffDays > 1) {
          userToUpdate.streak = 1
        }
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

export const getAnalyses = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user?.id
    const page = parseInt(req.query.page as string) || 1
    const limit = parseInt(req.query.limit as string) || 10
    const skip = (page - 1) * limit

    if (!userId) {
      res.status(401).json({ message: 'User not authenticated' })
      return
    }

    const analyses = await Analysis.find({ user: userId })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)

    res.json(analyses)
  } catch (error) {
    res.status(500).json({ message: (error as Error).message })
  }
}

export const getAnalysesByUserId = async (req: Request, res: Response) => {
  try {
    const userId = req.params.userId
    const requesterId = (req as any).user?._id?.toString()
    const targetUser = await User.findById(userId)
    if (targetUser && targetUser.socialHidden && requesterId !== userId) {
      res.status(403).json({ message: 'User has hidden social activity' })
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

export const getFeed = async (req: Request, res: Response) => {
  try {
    const currentUser = (req as any).user
    const page = parseInt(req.query.page as string) || 1
    const limit = parseInt(req.query.limit as string) || 10
    const skip = (page - 1) * limit

    if (!currentUser) {
      res.status(401).json({ message: 'User not authenticated' })
      return
    }

    const followingIds = currentUser.followingList || []
    if (followingIds.length === 0) {
      res.json([])
      return
    }

    const visibleFollowing = await User.find({
      _id: { $in: followingIds },
      socialHidden: { $ne: true },
    }).select('_id')

    const visibleIds = visibleFollowing.map((u) => u._id)

    const analyses = await Analysis.find({ user: { $in: visibleIds } })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .populate('user', 'name username profilePicture')

    res.json(analyses)
  } catch (error) {
    console.error('Get Feed Error:', error)
    res.status(500).json({ message: 'Server error' })
  }
}

export const deleteAnalysis = async (req: Request, res: Response) => {
  try {
    const analysisId = req.params.id
    const user = (req as any).user

    const analysis = await Analysis.findById(analysisId)

    if (!analysis) {
      res.status(404).json({ message: 'Analysis not found' })
      return
    }

    if (analysis.user.toString() !== user._id.toString()) {
      res.status(401).json({ message: 'Not authorized' })
      return
    }

    await analysis.deleteOne()

    const remainingAnalyses = await Analysis.find({ user: user._id })
    const validAnalyses = remainingAnalyses.filter(
      (a: any) => a.ratings?.overall > 0,
    )

    let newScore = 0
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

    if (validAnalyses.length > 0) {
      const total = validAnalyses.reduce(
        (sum: number, a: any) => sum + a.ratings.overall,
        0,
      )
      newScore = parseFloat((total / validAnalyses.length).toFixed(1))

      remainingAnalyses.forEach((a: any) => {
        const r = a.ratings || {}
        Object.keys(muscleSums).forEach((key) => {
          if (r[key] && r[key] > 0) {
            muscleSums[key] += r[key]
            muscleCounts[key]++
          }
        })
      })
    }

    const muscleAverages: any = {}
    Object.keys(muscleSums).forEach((key) => {
      muscleAverages[key] =
        muscleCounts[key] > 0
          ? parseFloat((muscleSums[key] / muscleCounts[key]).toFixed(1))
          : 0
    })

    await User.findByIdAndUpdate(user._id, {
      score: newScore,
      muscleStats: muscleAverages,
    })

    res.json({ message: 'Analysis removed' })
  } catch (error) {
    res.status(500).json({ message: (error as Error).message })
  }
}
