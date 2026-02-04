import { Request, Response } from 'express'
import Notification from '../models/Notification'
import User from '../models/User'
import { sendPushForNotification } from '../utils/pushService'

export const getNotifications = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user._id
    const notifications = await Notification.find({ recipient: userId })
      .sort({ createdAt: -1 })
      .populate('sender', 'name username profilePicture')
      .limit(50)

    res.json(notifications)
  } catch (error) {
    res.status(500).json({ message: 'Server error' })
  }
}

export const registerDeviceToken = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user._id
    const { token } = req.body as { token?: string }

    if (!token) {
      res.status(400).json({ message: 'Device token is required' })
      return
    }

    const user = await User.findById(userId)
    if (!user) {
      res.status(404).json({ message: 'User not found' })
      return
    }

    const tokens = new Set((user as any).deviceTokens || [])
    tokens.add(token)
    ;(user as any).deviceTokens = Array.from(tokens)
    await user.save()

    res.json({ success: true })
  } catch (error) {
    res.status(500).json({ message: 'Server error' })
  }
}

export const markNotificationsRead = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user._id

    await Notification.updateMany(
      { recipient: userId, read: false },
      { $set: { read: true } },
    )

    res.json({ message: 'Notifications marked as read' })
  } catch (error) {
    res.status(500).json({ message: 'Server error' })
  }
}

export const createAndPushNotification = async (params: {
  recipient: any
  sender: any
  type: string
}) => {
  const notification = await Notification.create(params)
  await sendPushForNotification(notification)
  return notification
}
