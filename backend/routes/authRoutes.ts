import express from 'express'
import { registerUser, loginUser, getMe } from '../controllers/authController'

const router = express.Router()

// Route for user registration
router.post('/register', registerUser)

// Route for user login
router.post('/login', loginUser)

// Route to get current user data (Protected)
// TODO: Add auth middleware to protect this route
router.get('/me', getMe)

export default router
