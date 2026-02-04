import { Request, Response } from 'express'
import { GoogleGenerativeAI } from '@google/generative-ai'
import TrainingPlan from '../models/TrainingPlan'
import User from '../models/User'

export const generateTrainingPlan = async (req: Request, res: Response) => {
  try {
    const apiKey = process.env.GEMINI_API_KEY
    if (!apiKey) {
      res.status(500).json({ message: 'Server configuration error' })
      return
    }

    const userId = (req as any).user._id
    const user = await User.findById(userId)

    if (!user) {
      res.status(404).json({ message: 'User not found' })
      return
    }

    const genAI = new GoogleGenerativeAI(apiKey)
    const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash' })

    const userContext = `
      User Profile:
      - Gender: ${user.gender || 'Not specified'}
      - Age: ${user.age || 'Not specified'}
      - Weight: ${user.weight ? user.weight + ' kg' : 'Not specified'}
      - Height: ${user.height ? user.height + ' cm' : 'Not specified'}
      - Goal: ${user.goal || 'General fitness'}
      
      Current Muscle Stats (1-10 scale, 0 means not assessed):
      - Arms: ${user.muscleStats?.arms || 0}
      - Chest: ${user.muscleStats?.chest || 0}
      - Abs: ${user.muscleStats?.abs || 0}
      - Shoulders: ${user.muscleStats?.shoulders || 0}
      - Legs: ${user.muscleStats?.legs || 0}
      - Back: ${user.muscleStats?.back || 0}
    `

    const prompt = `
      You are an expert personal trainer and fitness coach. Based on the user's profile and muscle stats, 
      create a personalized weekly training plan.

      ${userContext}

      Create a 7-day training plan that:
      1. Focuses on the user's weakest muscle groups (lowest scores)
      2. Maintains their strong points
      3. Aligns with their stated goal
      4. Includes appropriate rest days (typically 1-2 per week)
      5. Has realistic sets and reps for each exercise

      Return ONLY valid JSON in this exact format:
      {
        "title": "Power & Size Builder",
        "description": "A balanced program focusing on your weak points while maintaining your strengths.",
        "weekPlan": [
          {
            "day": "Monday",
            "focus": "Chest & Triceps",
            "isRestDay": false,
            "exercises": [
              { "name": "Bench Press", "sets": 4, "reps": "8-10", "notes": "Focus on controlled tempo" },
              { "name": "Incline Dumbbell Press", "sets": 3, "reps": "10-12", "notes": "" }
            ]
          },
          {
            "day": "Sunday",
            "focus": "Rest Day",
            "isRestDay": true,
            "exercises": []
          }
        ],
        "tips": [
          "Stay hydrated - aim for 3-4 liters of water daily",
          "Get 7-8 hours of sleep for optimal recovery",
          "Progressive overload is key - increase weight when reps become easy"
        ]
      }
      
      Include all 7 days (Monday through Sunday).
      Each workout day should have 4-6 exercises.
      Include 3-5 practical tips.
      Do not include markdown formatting like \`\`\`json.
    `

    const result = await model.generateContent(prompt)
    const response = await result.response
    const text = response.text()

    const cleanJson = text
      .replace(/```json/g, '')
      .replace(/```/g, '')
      .trim()

    const planData = JSON.parse(cleanJson)

    // Save the training plan
    const trainingPlan = await TrainingPlan.create({
      user: userId,
      title: planData.title,
      description: planData.description,
      weekPlan: planData.weekPlan,
      tips: planData.tips,
      userStats: {
        goal: user.goal,
        weight: user.weight,
        height: user.height,
        gender: user.gender,
        muscleStats: user.muscleStats,
      },
    })

    res.status(201).json(trainingPlan)
  } catch (error) {
    console.error('Generate Training Plan Error:', error)
    res.status(500).json({ message: (error as Error).message })
  }
}

export const getTrainingPlans = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user._id
    const page = parseInt(req.query.page as string) || 1
    const limit = parseInt(req.query.limit as string) || 10

    const plans = await TrainingPlan.find({ user: userId })
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(limit)

    const total = await TrainingPlan.countDocuments({ user: userId })

    res.json({
      plans,
      currentPage: page,
      totalPages: Math.ceil(total / limit),
      total,
    })
  } catch (error) {
    console.error('Get Training Plans Error:', error)
    res.status(500).json({ message: (error as Error).message })
  }
}

export const getTrainingPlan = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user._id
    const plan = await TrainingPlan.findOne({
      _id: req.params.id,
      user: userId,
    })

    if (!plan) {
      res.status(404).json({ message: 'Training plan not found' })
      return
    }

    res.json(plan)
  } catch (error) {
    res.status(500).json({ message: (error as Error).message })
  }
}

export const deleteTrainingPlan = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user._id
    const plan = await TrainingPlan.findOneAndDelete({
      _id: req.params.id,
      user: userId,
    })

    if (!plan) {
      res.status(404).json({ message: 'Training plan not found' })
      return
    }

    res.json({ message: 'Training plan deleted' })
  } catch (error) {
    res.status(500).json({ message: (error as Error).message })
  }
}
