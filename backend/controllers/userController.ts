import { Request, Response } from 'express'
import User from '../models/User'
import Analysis from '../models/Analysis'
import Notification from '../models/Notification'
import { createAndPushNotification } from './notificationController'

export const getLeaderboard = async (req: Request, res: Response) => {
  try {
    const currentUserId = (req as any).user?._id

    const { category, gender, weightClass } = req.query as {
      category?: string
      gender?: string
      weightClass?: string
    }

    const filter: any = {}

    if (gender && gender !== 'All') {
      filter.gender = gender
    }

    if (weightClass && weightClass !== 'All') {
      if (weightClass === '< 70kg') {
        filter.weight = { $lt: 70 }
      } else if (weightClass === '70-85kg') {
        filter.weight = { $gte: 70, $lte: 85 }
      } else if (weightClass === '> 85kg') {
        filter.weight = { $gt: 85 }
      }
    }

    let sortField = 'score'
    if (category && category !== 'Overall') {
      const validMuscles = ['arms', 'chest', 'abs', 'shoulders', 'legs', 'back']
      if (validMuscles.includes(category.toLowerCase())) {
        sortField = `muscleStats.${category.toLowerCase()}`
      }
    }

    const messyUsers = await User.find({
      $or: [
        { score: { $gt: 10 } },
        { score: { $gt: 0 }, muscleStats: { $exists: false } },
        { score: { $gt: 0 }, 'muscleStats.arms': { $exists: false } },
      ],
    }).limit(50)

    for (const user of messyUsers) {
      const analyses = await Analysis.find({ user: user._id })
      if (analyses.length > 0) {
        const validAnalyses = analyses.filter(
          (a: any) => a.ratings?.overall > 0
        )
        if (validAnalyses.length > 0) {
          const total = validAnalyses.reduce(
            (sum: number, a: any) => sum + a.ratings.overall,
            0
          )
          user.score = parseFloat((total / validAnalyses.length).toFixed(1))
        } else {
          user.score = 0
        }

        const muscleSums: any = {
          arms: 0,
          chest: 0,
          abs: 0,
          shoulders: 0,
          legs: 0,
          back: 0,
        }
        const muscleCounts: any = {
          arms: 0,
          chest: 0,
          abs: 0,
          shoulders: 0,
          legs: 0,
          back: 0,
        }
        analyses.forEach((a: any) => {
          const r = a.ratings || {}
          Object.keys(muscleSums).forEach((key) => {
            if (r[key] && r[key] > 0) {
              muscleSums[key] += r[key]
              muscleCounts[key]++
            }
          })
        })
        const muscleAverages: any = {}
        Object.keys(muscleSums).forEach((key) => {
          muscleAverages[key] =
            muscleCounts[key] > 0
              ? parseFloat((muscleSums[key] / muscleCounts[key]).toFixed(1))
              : 0
        })
        user.muscleStats = muscleAverages
        await user.save()
      } else {
        user.score = 0
        user.muscleStats = {
          arms: 0,
          chest: 0,
          abs: 0,
          shoulders: 0,
          legs: 0,
          back: 0,
        }
        await user.save()
      }
    }

    const users = await User.find(filter)
      .sort({ [sortField]: -1 })
      .limit(50)
      .select(
        'name username profilePicture score muscleStats gender weight country'
      )

    let myRank = -1
    let myData = null

    if (currentUserId) {
      const currentUser = await User.findById(currentUserId)
      if (currentUser) {
        let myValue = 0
        if (sortField === 'score') {
          myValue = currentUser.score || 0
        } else {
          const parts = sortField.split('.')
          if (currentUser.muscleStats) {
            myValue = (currentUser.muscleStats as any)[parts[1]] || 0
          }
        }

        const betterUsersCount = await User.countDocuments({
          ...filter,
          [sortField]: { $gt: myValue },
        })

        myRank = betterUsersCount + 1

        myData = {
          _id: currentUser._id,
          name: currentUser.name,
          username: currentUser.username,
          profilePicture: currentUser.profilePicture,
          score: currentUser.score,
          muscleStats: currentUser.muscleStats,
          rank: myRank,
        }
      }
    }

    res.json({
      leaderboard: users,
      myRank: myData,
    })
  } catch (error) {
    res.status(500).json({ message: (error as Error).message })
  }
}

export const getUserProfile = async (req: Request, res: Response) => {
  try {
    const user = await User.findById(req.params.id).select('-password')
    if (user) {
      const currentUserId = (req as any).user._id
      const isFollowing =
        (user as any).followersList &&
        (user as any).followersList.includes(currentUserId)

      res.json({ ...user.toObject(), isFollowing })
    } else {
      res.status(404).json({ message: 'User not found' })
    }
  } catch (error) {
    res.status(500).json({ message: (error as Error).message })
  }
}

export const followUser = async (req: Request, res: Response) => {
  try {
    const targetUserId = req.params.id
    const currentUserId = (req as any).user._id

    if (targetUserId === currentUserId.toString()) {
      res.status(400).json({ message: 'Cannot follow yourself' })
      return
    }

    const targetUser = await User.findById(targetUserId)
    const currentUser = await User.findById(currentUserId)

    if (!targetUser || !currentUser) {
      res.status(404).json({ message: 'User not found' })
      return
    }

    const isFollowing =
      (currentUser as any).followingList &&
      (currentUser as any).followingList.includes(targetUserId)

    if (isFollowing) {
      ;(currentUser as any).followingList = (
        currentUser as any
      ).followingList.filter((id: any) => id.toString() !== targetUserId)
      currentUser.following = (currentUser.followingList as any).length
      ;(targetUser as any).followersList = (
        targetUser as any
      ).followersList.filter(
        (id: any) => id.toString() !== currentUserId.toString()
      )
      targetUser.followers = (targetUser.followersList as any).length

      await currentUser.save()
      await targetUser.save()

      res.json({ message: 'Unfollowed', isFollowing: false })
    } else {
      if (!(currentUser as any).followingList) currentUser.followingList = []
      if (!(targetUser as any).followersList) targetUser.followersList = []

      currentUser.followingList.push(targetUserId as any)
      currentUser.following = currentUser.followingList.length

      targetUser.followersList.push(currentUserId as any)
      targetUser.followers = targetUser.followersList.length

      await currentUser.save()
      await targetUser.save()

      await createAndPushNotification({
        recipient: targetUserId,
        sender: currentUserId,
        type: 'follow',
      })

      res.json({ message: 'Followed', isFollowing: true })
    }
  } catch (error) {
    res.status(500).json({ message: (error as Error).message })
  }
}

export const searchUsers = async (req: Request, res: Response) => {
  try {
    const query = req.query.q as string
    const currentUserId = (req as any).user._id

    if (!query) {
      res.json([])
      return
    }

    const users = await User.find({
      $and: [
        { _id: { $ne: currentUserId } },
        {
          $or: [
            { name: { $regex: query, $options: 'i' } },
            { username: { $regex: query, $options: 'i' } },
          ],
        },
      ],
    })
      .select('name username profilePicture')
      .limit(20)

    res.json(users)
  } catch (error) {
    console.error('Search Users Error:', error)
    res.status(500).json({ message: 'Server error' })
  }
}
