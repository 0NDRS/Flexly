import { Request, Response } from 'express'
import jwt from 'jsonwebtoken'
import User from '../models/User'
import Analysis from '../models/Analysis'
import { v2 as cloudinary } from 'cloudinary'
import streamifier from 'streamifier'

const generateToken = (id: string) => {
  if (!process.env.JWT_SECRET) {
    throw new Error('JWT_SECRET is not defined in environment variables')
  }
  return jwt.sign({ id }, process.env.JWT_SECRET, {
    expiresIn: '30d',
  })
}

export const registerUser = async (req: Request, res: Response) => {
  const { name, email, password } = req.body

  try {
    const userExists = await User.findOne({ email })

    if (userExists) {
      res.status(400).json({ message: 'User already exists' })
      return
    }

    let username = req.body.username
    if (!username) {
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

export const loginUser = async (req: Request, res: Response) => {
  const { email, password } = req.body

  try {
    const user = await User.findOne({ email }).select('+password')

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

export const getMe = async (req: Request, res: Response) => {
  try {
    const user = await User.findById((req as any).user.id)

    if (
      user &&
      (!user.score || user.score === 0 || user.score > 10 || !user.muscleStats)
    ) {
      const analyses = await Analysis.find({ user: user._id })
      if (analyses.length > 0) {
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

      if (req.file) {
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
