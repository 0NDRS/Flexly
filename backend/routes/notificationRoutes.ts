import express from 'express'
import { protect } from '../middleware/authMiddleware'
import {
  getNotifications,
  markNotificationsRead,
} from '../controllers/notificationController'

const router = express.Router()

router.get('/', protect, getNotifications)
router.put('/read', protect, markNotificationsRead)

export default router
