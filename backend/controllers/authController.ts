import { Request, Response } from 'express'
import jwt from 'jsonwebtoken'
import User from '../models/User'

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
  // TODO: Implement middleware to set req.user from token
  // const { _id, name, email } = await User.findById(req.user.id);
  // res.status(200).json({ id: _id, name, email });
  res.status(200).json({ message: 'User data display' })
}
