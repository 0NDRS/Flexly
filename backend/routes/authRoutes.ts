import express from 'express'
import {
  registerUser,
  loginUser,
  getMe,
  updateProfile,
  changePassword,
} from '../controllers/authController'
import { protect } from '../middleware/authMiddleware'
import upload from '../middleware/uploadMiddleware'

const router = express.Router()

// Route for user registration
router.post('/register', registerUser)

// Route for user login
router.post('/login', loginUser)

// Route to get current user data (Protected)
router.get('/me', protect, getMe)

// Route to update user profile (Protected)
router.put('/profile', protect, upload.single('profilePicture'), updateProfile)

// Route to change password (Protected)
router.put('/password', protect, changePassword)

export default router
