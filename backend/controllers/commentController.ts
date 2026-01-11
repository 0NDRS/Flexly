import { Request, Response } from 'express'
import Comment from '../models/Comment'
import Analysis from '../models/Analysis'

export const getCommentsForAnalysis = async (req: Request, res: Response) => {
  try {
    const analysisId = req.params.id
    const comments = await Comment.find({ analysis: analysisId })
      .sort({ createdAt: -1 })
      .populate('user', 'name username profilePicture')

    res.json(comments)
  } catch (error) {
    res.status(500).json({ message: 'Server error' })
  }
}

export const addCommentToAnalysis = async (req: Request, res: Response) => {
  try {
    const analysisId = req.params.id
    const userId = (req as any).user?._id
    const { text } = req.body as { text?: string }

    if (!text || text.trim().length === 0) {
      res.status(400).json({ message: 'Comment text is required' })
      return
    }

    const analysis = await Analysis.findById(analysisId)
    if (!analysis) {
      res.status(404).json({ message: 'Analysis not found' })
      return
    }

    const comment = await Comment.create({
      analysis: analysisId,
      user: userId,
      text: text.trim(),
    })

    const populated = await comment.populate('user', 'name username profilePicture')
    res.status(201).json(populated)
  } catch (error) {
    res.status(500).json({ message: 'Server error' })
  }
}

export const deleteComment = async (req: Request, res: Response) => {
  try {
    const commentId = req.params.commentId
    const userId = (req as any).user?._id

    const comment = await Comment.findById(commentId)
    if (!comment) {
      res.status(404).json({ message: 'Comment not found' })
      return
    }

    if (comment.user.toString() !== userId.toString()) {
      res.status(403).json({ message: 'Not authorized to delete this comment' })
      return
    }

    await comment.deleteOne()
    res.json({ message: 'Comment deleted' })
  } catch (error) {
    res.status(500).json({ message: 'Server error' })
  }
}
