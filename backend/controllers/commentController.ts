import { Request, Response } from 'express'
import Comment from '../models/Comment'
import Analysis from '../models/Analysis'

export const getCommentsForAnalysis = async (req: Request, res: Response) => {
  try {
    const analysisId = req.params.id
    const comments = await Comment.find({ analysis: analysisId })
      .sort({ createdAt: -1 })
      .populate('user', 'name username profilePicture')
      .populate('parentComment', '_id')

    res.json(comments)
  } catch (error) {
    res.status(500).json({ message: 'Server error' })
  }
}

export const addCommentToAnalysis = async (req: Request, res: Response) => {
  try {
    const analysisId = req.params.id
    const userId = (req as any).user?._id
    const { text, parentCommentId } = req.body as {
      text?: string
      parentCommentId?: string
    }

    if (!text || text.trim().length === 0) {
      res.status(400).json({ message: 'Comment text is required' })
      return
    }

    const analysis = await Analysis.findById(analysisId)
    if (!analysis) {
      res.status(404).json({ message: 'Analysis not found' })
      return
    }

    let parentComment = null
    if (parentCommentId) {
      parentComment = await Comment.findById(parentCommentId)
      if (!parentComment) {
        res.status(404).json({ message: 'Parent comment not found' })
        return
      }
      if (parentComment.analysis.toString() !== analysisId.toString()) {
        res
          .status(400)
          .json({ message: 'Parent comment does not belong to this analysis' })
        return
      }
    }

    const comment = await Comment.create({
      analysis: analysisId,
      user: userId,
      text: text.trim(),
      parentComment: parentComment ? parentComment._id : undefined,
    })

    await comment.populate('user', 'name username profilePicture')
    await comment.populate('parentComment', '_id')

    res.status(201).json(comment)
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
