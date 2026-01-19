import Notification from '../models/Notification'
import User from '../models/User'

const FCM_ENDPOINT = 'https://fcm.googleapis.com/fcm/send'
const SERVER_KEY = process.env.FCM_SERVER_KEY

// Sends a push notification via FCM legacy HTTP API to provided device tokens.
export const sendPushNotification = async (
  deviceTokens: string[],
  title: string,
  body: string,
  data: Record<string, string> = {}
) => {
  if (!SERVER_KEY) {
    console.warn('FCM_SERVER_KEY not set; skipping push send')
    return
  }
  if (!deviceTokens || deviceTokens.length === 0) return

  try {
    const payload = {
      registration_ids: deviceTokens,
      notification: {
        title,
        body,
      },
      data,
      priority: 'high',
    }

    await fetch(FCM_ENDPOINT, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `key=${SERVER_KEY}`,
      },
      body: JSON.stringify(payload),
    })
  } catch (error) {
    console.error('Failed to send push notification', error)
  }
}

// Convenience helper to send when a Notification document is created.
export const sendPushForNotification = async (
  notification: InstanceType<typeof Notification>
) => {
  try {
    const recipient = await User.findById(notification.recipient).select(
      'deviceTokens name'
    )
    if (!recipient) return
    const tokens = recipient.deviceTokens || []
    if (tokens.length === 0) return

    let title = 'New notification'
    let body = 'You have a new update.'

    if (notification.type === 'follow') {
      title = 'New follower'
      body = 'Someone just followed you on Flexly.'
    }

    await sendPushNotification(tokens, title, body, {
      notificationId: notification._id.toString(),
      type: notification.type,
    })
  } catch (error) {
    console.error('Failed to send push for notification', error)
  }
}
