import express from 'express'
import {
  getLeaderboard,
  getUserProfile,
  followUser,
  searchUsers,
  getFollowers,
  getFollowing,
  deleteAccount,
} from '../controllers/userController'
import { protect } from '../middleware/authMiddleware'

const router = express.Router()

router.get('/leaderboard', protect, getLeaderboard)
router.get('/search', protect, searchUsers)
router.delete('/me', protect, deleteAccount)
router.get('/:id', protect, getUserProfile)
router.get('/:id/followers', protect, getFollowers)
router.get('/:id/following', protect, getFollowing)
router.post('/:id/follow', protect, followUser)

export default router
