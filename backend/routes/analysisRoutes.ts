import express from 'express'
import {
  analyzePhysique,
  getAnalyses,
  getAnalysesByUserId,
  getFeed,
  deleteAnalysis,
} from '../controllers/analysisController'
import {
  addCommentToAnalysis,
  getCommentsForAnalysis,
  deleteComment,
} from '../controllers/commentController'
import upload from '../middleware/uploadMiddleware'
import { protect } from '../middleware/authMiddleware'

const router = express.Router()

router.post('/', protect, upload.array('images', 5), analyzePhysique)
router.get('/', protect, getAnalyses)
router.get('/feed', protect, getFeed)
router.get('/user/:userId', protect, getAnalysesByUserId)
router.get('/:id/comments', protect, getCommentsForAnalysis)
router.post('/:id/comments', protect, addCommentToAnalysis)
router.delete('/comments/:commentId', protect, deleteComment)
router.delete('/:id', protect, deleteAnalysis)

export default router
