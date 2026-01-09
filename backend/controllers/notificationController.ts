import { Request, Response } from 'express'
import Notification from '../models/Notification'

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

export const markNotificationsRead = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user._id

    await Notification.updateMany(
      { recipient: userId, read: false },
      { $set: { read: true } }
    )

    res.json({ message: 'Notifications marked as read' })
  } catch (error) {
    res.status(500).json({ message: 'Server error' })
  }
}
