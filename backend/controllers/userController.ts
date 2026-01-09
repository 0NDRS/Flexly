import { Request, Response } from 'express'
import User from '../models/User'
import Analysis from '../models/Analysis'

// @desc    Get leaderboard
// @route   GET /api/users/leaderboard
// @access  Private (to get my rank) or Public? Private is better.
export const getLeaderboard = async (req: Request, res: Response) => {
  try {
    const currentUserId = (req as any).user?._id

    // Check query params
    const { category, gender, weightClass } = req.query as {
      category?: string
      gender?: string
      weightClass?: string
    }

    // Build Filter
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

    // Determine Sort Field
    let sortField = 'score'
    if (category && category !== 'Overall') {
      // Assuming category matches muscleStats keys (arms, chest, etc.)
      const validMuscles = ['arms', 'chest', 'abs', 'shoulders', 'legs', 'back']
      if (validMuscles.includes(category.toLowerCase())) {
        sortField = `muscleStats.${category.toLowerCase()}`
      }
    }

    // LAZY MIGRATION FORCE
    // Check for users who have a score > 0 but are missing muscleStats OR have legacy high score > 10
    // This catches users who have valid normal scores but no muscle breakdown yet.
    const messyUsers = await User.find({
      $or: [
        { score: { $gt: 10 } },
        { score: { $gt: 0 }, muscleStats: { $exists: false } },
        { score: { $gt: 0 }, 'muscleStats.arms': { $exists: false } },
      ],
    }).limit(50)

    for (const user of messyUsers) {
      // Fix this user
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

        // Recalc muscles too
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
        // no analysis but data present? reset.
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

    // Fetch Top 50 Users (Now cleaned up mostly)
    const users = await User.find(filter)
      .sort({ [sortField]: -1 })
      .limit(50)
      .select(
        'name username profilePicture score muscleStats gender weight country'
      )

    // Iterate and fix any 0.0s for muscles if they actually have data (unlikely if score is fixed, but robust)
    // Actually, for display, we just send what we have.

    // Calculate My Rank
    let myRank = -1
    let myData = null

    if (currentUserId) {
      const currentUser = await User.findById(currentUserId)
      if (currentUser) {
        // Apply same filters to rank calculation?
        // Usually rank is within the filter context.
        // e.g. "I am rank 5 in Females"
        // So yes, use the filter.

        // Get my value for the sort field
        let myValue = 0
        if (sortField === 'score') {
          myValue = currentUser.score || 0
        } else {
          // muscleStats.arms
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

        // If I am in the top 50, I am already in `users`.
        // If not, I still need my data to show at the bottom.
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

// @desc    Get user profile by ID
// @route   GET /api/users/:id
// @access  Private
export const getUserProfile = async (req: Request, res: Response) => {
  try {
    const user = await User.findById(req.params.id).select('-password')
    if (user) {
      const currentUserId = (req as any).user._id
      // Check if following
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

// @desc    Follow/Unfollow user
// @route   POST /api/users/:id/follow
// @access  Private
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

    // Check if already following
    const isFollowing =
      (currentUser as any).followingList &&
      (currentUser as any).followingList.includes(targetUserId)

    if (isFollowing) {
      // Unfollow
      // Remove from currentUser followingList
      ;(currentUser as any).followingList = (
        currentUser as any
      ).followingList.filter((id: any) => id.toString() !== targetUserId)
      currentUser.following = (currentUser.followingList as any).length

      // Remove from targetUser followersList
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
      // Follow
      if (!(currentUser as any).followingList) currentUser.followingList = []
      if (!(targetUser as any).followersList) targetUser.followersList = []

      currentUser.followingList.push(targetUserId as any)
      currentUser.following = currentUser.followingList.length

      targetUser.followersList.push(currentUserId as any)
      targetUser.followers = targetUser.followersList.length

      await currentUser.save()
      await targetUser.save()

      res.json({ message: 'Followed', isFollowing: true })
    }
  } catch (error) {
    res.status(500).json({ message: (error as Error).message })
  }
}
