import express from 'express'
import {
  registerUser,
  loginUser,
  getMe,
  updateProfile,
} from '../controllers/authController'
import { protect } from '../middleware/authMiddleware'

const router = express.Router()

// Route for user registration
router.post('/register', registerUser)

// Route for user login
router.post('/login', loginUser)

// Route to get current user data (Protected)
router.get('/me', protect, getMe)

// Route to update user profile (Protected)
router.put('/profile', protect, updateProfile)

export default router
