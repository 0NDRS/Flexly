import express from 'express'
import { protect } from '../middleware/authMiddleware'
import {
  getNotifications,
  markNotificationsRead,
  registerDeviceToken,
} from '../controllers/notificationController'

const router = express.Router()

router.get('/', protect, getNotifications)
router.put('/read', protect, markNotificationsRead)
router.post('/device-token', protect, registerDeviceToken)

export default router
