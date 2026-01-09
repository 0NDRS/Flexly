import express from 'express'
import {
  getLeaderboard,
  getUserProfile,
  followUser,
} from '../controllers/userController'
import { protect } from '../middleware/authMiddleware'

const router = express.Router()

router.get('/leaderboard', protect, getLeaderboard)
router.get('/:id', protect, getUserProfile)
router.post('/:id/follow', protect, followUser)

export default router
