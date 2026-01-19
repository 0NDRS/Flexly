import { Request, Response } from 'express'
import jwt from 'jsonwebtoken'
import User from '../models/User'
import Analysis from '../models/Analysis'
import { v2 as cloudinary } from 'cloudinary'
import streamifier from 'streamifier'
import { OAuth2Client } from 'google-auth-library'

const generateToken = (id: string) => {
  if (!process.env.JWT_SECRET) {
    throw new Error('JWT_SECRET is not defined in environment variables')
  }
  return jwt.sign({ id }, process.env.JWT_SECRET, {
    expiresIn: '30d',
  })
}

const googleClientId = process.env.GOOGLE_CLIENT_ID
const googleClient = googleClientId ? new OAuth2Client(googleClientId) : null

const buildAuthResponse = (user: any) => {
  return {
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
    socialHidden: user.socialHidden,
    token: generateToken(user._id.toString()),
  }
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
      res.status(201).json(buildAuthResponse(user))
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
      res.json(buildAuthResponse(user))
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
      const cooldownMs = 90 * 24 * 60 * 60 * 1000 // 90 days
      const now = new Date()

      // Name change with cooldown
      if (req.body.name && req.body.name !== user.name) {
        if (
          user.nameChangedAt &&
          now.getTime() - user.nameChangedAt.getTime() < cooldownMs
        ) {
          const remainingMs =
            cooldownMs - (now.getTime() - user.nameChangedAt.getTime())
          const remainingDays = Math.ceil(remainingMs / (1000 * 60 * 60 * 24))
          res.status(400).json({
            message: `Name can be changed again in ${remainingDays} day(s)`,
          })
          return
        }
        user.name = req.body.name
        user.nameChangedAt = now
      }

      user.email = req.body.email || user.email

      // Username change with cooldown and uniqueness check
      if (req.body.username && req.body.username !== user.username) {
        if (
          user.usernameChangedAt &&
          now.getTime() - user.usernameChangedAt.getTime() < cooldownMs
        ) {
          const remainingMs =
            cooldownMs - (now.getTime() - user.usernameChangedAt.getTime())
          const remainingDays = Math.ceil(remainingMs / (1000 * 60 * 60 * 24))
          res.status(400).json({
            message: `Username can be changed again in ${remainingDays} day(s)`,
          })
          return
        }

        const existingUsername = await User.findOne({
          username: req.body.username,
          _id: { $ne: user._id },
        })

        if (existingUsername) {
          res.status(400).json({ message: 'Username is already taken' })
          return
        }

        user.username = req.body.username
        user.usernameChangedAt = now
      }

      if (req.body.bio) user.bio = req.body.bio

      if (req.body.gender) user.gender = req.body.gender
      if (req.body.age) user.age = Number(req.body.age)
      if (req.body.height) user.height = Number(req.body.height)
      if (req.body.weight) user.weight = Number(req.body.weight)
      if (req.body.goal) user.goal = req.body.goal

      if (typeof req.body.socialHidden !== 'undefined') {
        user.socialHidden = req.body.socialHidden === true || req.body.socialHidden === 'true'
      }

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
        socialHidden: updatedUser.socialHidden,
        token: generateToken(updatedUser._id.toString()),
      })
    } else {
      res.status(404).json({ message: 'User not found' })
    }
  } catch (error) {
    res.status(500).json({ message: (error as Error).message })
  }
}

export const googleAuth = async (req: Request, res: Response) => {
  try {
    const { idToken } = req.body as { idToken?: string }
    if (!idToken) {
      res.status(400).json({ message: 'idToken is required' })
      return
    }
    if (!googleClient) {
      res.status(500).json({ message: 'GOOGLE_CLIENT_ID not configured' })
      return
    }

    const ticket = await googleClient.verifyIdToken({
      idToken,
      audience: googleClientId,
    })

    const payload = ticket.getPayload()
    if (!payload || !payload.email) {
      res.status(400).json({ message: 'Invalid Google token' })
      return
    }

    const email = payload.email
    const name = payload.name || email.split('@')[0]
    const picture = payload.picture

    let user = await User.findOne({ email })

    if (!user) {
      // Build a unique username
      const base = name.toLowerCase().replace(/[^a-z0-9]/g, '') || 'user'
      let username = base
      let attempt = 0
      while (await User.findOne({ username })) {
        username = `${base}${Math.floor(1000 + Math.random() * 9000)}`
        attempt++
        if (attempt > 5) break
      }

      user = await User.create({
        name,
        email,
        username,
        password: `${payload.sub || 'google'}-${Date.now()}`,
        profilePicture: picture || '',
      })
    }

    res.json(buildAuthResponse(user))
  } catch (error) {
    res.status(500).json({ message: (error as Error).message })
  }
}

export const changePassword = async (req: Request, res: Response) => {
  try {
    const { currentPassword, newPassword } = req.body
    const user = await User.findById((req as any).user.id).select('+password')

    if (!user) {
      res.status(404).json({ message: 'User not found' })
      return
    }

    const matches = await (user as any).matchPassword(currentPassword)
    if (!matches) {
      res.status(400).json({ message: 'Current password is incorrect' })
      return
    }

    user.password = newPassword
    await user.save()

    res.json({ message: 'Password updated' })
  } catch (error) {
    res.status(500).json({ message: (error as Error).message })
  }
}
