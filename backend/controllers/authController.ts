import { Request, Response } from 'express'
import jwt from 'jsonwebtoken'
import User from '../models/User'
import Analysis from '../models/Analysis'
import { v2 as cloudinary } from 'cloudinary'
import streamifier from 'streamifier'

/**
 * Generates a JWT token for a user ID.
 * @param id - The user ID to encode in the token.
 * @returns A signed JWT token string.
 */
const generateToken = (id: string) => {
  if (!process.env.JWT_SECRET) {
    throw new Error('JWT_SECRET is not defined in environment variables')
  }
  return jwt.sign({ id }, process.env.JWT_SECRET, {
    expiresIn: '30d',
  })
}

/**
 * @desc    Register a new user
 * @route   POST /api/auth/register
 * @access  Public
 */
export const registerUser = async (req: Request, res: Response) => {
  const { name, email, password } = req.body

  try {
    // Check if user already exists
    const userExists = await User.findOne({ email })

    if (userExists) {
      res.status(400).json({ message: 'User already exists' })
      return
    }

    // Create new user
    let username = req.body.username
    if (!username) {
      // Generate username from name if not provided
      const baseName = name.toLowerCase().replace(/\s+/g, '')
      const randomSuffix = Math.floor(1000 + Math.random() * 9000)
      username = `${baseName}${randomSuffix}`
    }

    const user = await User.create({
      name,
      email,
      password,
      username,
    })

    if (user) {
      // Respond with user data and token
      res.status(201).json({
        _id: user._id,
        name: user.name,
        email: user.email,
        username: user.username,
        bio: user.bio,
        gender: user.gender,
        age: user.age,
        height: user.height,
        weight: user.weight,
        goal: user.goal,
        profilePicture: user.profilePicture,
        followers: user.followers,
        following: user.following,
        score: user.score,
        streak: user.streak,
        analyticsTracked: user.analyticsTracked,
        token: generateToken(user._id.toString()),
      })
    } else {
      res.status(400).json({ message: 'Invalid user data' })
    }
  } catch (error) {
    res.status(500).json({ message: (error as Error).message })
  }
}

/**
 * @desc    Authenticate a user and get token
 * @route   POST /api/auth/login
 * @access  Public
 */
export const loginUser = async (req: Request, res: Response) => {
  const { email, password } = req.body

  try {
    // Check for user by email
    // We need to explicitly select password because it's set to select: false in schema
    const user = await User.findOne({ email }).select('+password')

    // Check if user exists and password matches
    if (user && (await (user as any).matchPassword(password))) {
      res.json({
        _id: user._id,
        name: user.name,
        email: user.email,
        username: user.username,
        bio: user.bio,
        gender: user.gender,
        age: user.age,
        height: user.height,
        weight: user.weight,
        goal: user.goal,
        profilePicture: user.profilePicture,
        followers: user.followers,
        following: user.following,
        score: user.score,
        streak: user.streak,
        analyticsTracked: user.analyticsTracked,
        token: generateToken(user._id.toString()),
      })
    } else {
      res.status(401).json({ message: 'Invalid email or password' })
    }
  } catch (error) {
    res.status(500).json({ message: (error as Error).message })
  }
}

/**
 * @desc    Get current user data
 * @route   GET /api/auth/me
 * @access  Private
 */
export const getMe = async (req: Request, res: Response) => {
  try {
    const user = await User.findById((req as any).user.id)

    // Self-healing: Recalculate stats if score is 0 OR score > 10 (legacy) or muscleStats missing
    // We assume max average score is 10. If it's higher, it's a legacy sum.
    if (
      user &&
      (!user.score || user.score === 0 || user.score > 10 || !user.muscleStats)
    ) {
      const analyses = await Analysis.find({ user: user._id })
      if (analyses.length > 0) {
        // 1. Calculate Score
        const validAnalyses = analyses.filter(
          (a: any) => a.ratings?.overall > 0
        )
        if (validAnalyses.length > 0) {
          const totalOverall = validAnalyses.reduce(
            (sum: number, a: any) => sum + a.ratings.overall,
            0
          )
          user.score = parseFloat(
            (totalOverall / validAnalyses.length).toFixed(1)
          )
        } else {
          user.score = 0
        }

        // 2. Calculate Muscle Stats
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

        analyses.forEach((a: any) => {
          const r = a.ratings || {}
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
              ? parseFloat((muscleSums[key] / muscleCounts[key]).toFixed(1))
              : 0
        })
        user.muscleStats = muscleAverages

        await user.save()
      } else {
        // If data is weird but no analyses, just reset to 0
        if (user.score > 10) {
          user.score = 0
          user.muscleStats = {
            arms: 0,
            chest: 0,
            abs: 0,
            shoulders: 0,
            legs: 0,
            back: 0,
          }
          await user.save()
        }
      }
    }

    res.status(200).json(user)
  } catch (error) {
    res.status(500).json({ message: (error as Error).message })
  }
}

/**
 * @desc    Update user profile
 * @route   PUT /api/auth/profile
 * @access  Private
 */
export const updateProfile = async (req: Request, res: Response) => {
  try {
    const user = await User.findById((req as any).user.id)

    if (user) {
      user.name = req.body.name || user.name
      user.email = req.body.email || user.email
      if (req.body.username) user.username = req.body.username
      if (req.body.bio) user.bio = req.body.bio

      if (req.body.gender) user.gender = req.body.gender
      if (req.body.age) user.age = Number(req.body.age)
      if (req.body.height) user.height = Number(req.body.height)
      if (req.body.weight) user.weight = Number(req.body.weight)
      if (req.body.goal) user.goal = req.body.goal

      if (req.body.password) {
        user.password = req.body.password
      }

      // Handle Profile Picture Upload
      if (req.file) {
        // Upload to Cloudinary using stream
        const uploadFromBuffer = (buffer: Buffer) => {
          return new Promise((resolve, reject) => {
            const stream = cloudinary.uploader.upload_stream(
              { folder: 'profile_pictures' },
              (error, result) => {
                if (result) {
                  resolve(result)
                } else {
                  reject(error)
                }
              }
            )
            streamifier.createReadStream(buffer).pipe(stream)
          })
        }

        try {
          const result: any = await uploadFromBuffer(req.file.buffer)
          user.profilePicture = result.secure_url
        } catch (error) {
          console.error(error)
          // Continue saving user even if image upload fails
        }
      }

      const updatedUser = await user.save()

      res.json({
        _id: updatedUser._id,
        name: updatedUser.name,
        email: updatedUser.email,
        username: updatedUser.username,
        bio: updatedUser.bio,
        gender: updatedUser.gender,
        age: updatedUser.age,
        height: updatedUser.height,
        weight: updatedUser.weight,
        goal: updatedUser.goal,
        profilePicture: updatedUser.profilePicture,
        followers: updatedUser.followers,
        following: updatedUser.following,
        score: updatedUser.score,
        streak: updatedUser.streak,
        analyticsTracked: updatedUser.analyticsTracked,
        token: generateToken(updatedUser._id.toString()),
      })
    } else {
      res.status(404).json({ message: 'User not found' })
    }
  } catch (error) {
    res.status(500).json({ message: (error as Error).message })
  }
}
