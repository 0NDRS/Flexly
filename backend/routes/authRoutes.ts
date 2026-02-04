import express from 'express'
import {
  registerUser,
  loginUser,
  getMe,
  updateProfile,
  changePassword,
  googleAuth,
} from '../controllers/authController'
import { protect } from '../middleware/authMiddleware'
import upload from '../middleware/uploadMiddleware'

const router = express.Router()

router.post('/register', registerUser)
router.post('/login', loginUser)
router.get('/me', protect, getMe)
router.put('/profile', protect, upload.single('profilePicture'), updateProfile)
router.put('/password', protect, changePassword)
router.post('/google', googleAuth)

export default router
