import { Request, Response } from 'express'
import jwt from 'jsonwebtoken'
import User from '../models/User'
import { v2 as cloudinary } from 'cloudinary'
import streamifier from 'streamifier'

/**
 * Generates a JWT token for a user ID.
 * @param id - The user ID to encode in the token.
 * @returns A signed JWT token string.
 */
const generateToken = (id: string) => {
  return jwt.sign({ id }, process.env.JWT_SECRET || 'secret', {
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
    const user = await User.create({
      name,
      email,
      password,
    })

    if (user) {
      // Respond with user data and token
      res.status(201).json({
        _id: user._id,
        name: user.name,
        email: user.email,
        username: user.username,
        bio: user.bio,
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
