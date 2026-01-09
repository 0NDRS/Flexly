import express from 'express'
import {
  getLeaderboard,
  getUserProfile,
  followUser,
  searchUsers,
} from '../controllers/userController'
import { protect } from '../middleware/authMiddleware'

const router = express.Router()

router.get('/leaderboard', protect, getLeaderboard)
router.get('/search', protect, searchUsers)
router.get('/:id', protect, getUserProfile)
router.post('/:id/follow', protect, followUser)

export default router
