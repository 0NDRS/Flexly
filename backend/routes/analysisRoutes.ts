import express from 'express'
import { analyzePhysique, getAnalyses } from '../controllers/analysisController'
import upload from '../middleware/uploadMiddleware'
import { protect } from '../middleware/authMiddleware'

const router = express.Router()

// POST /api/analysis - Upload images and get analysis
router.post('/', protect, upload.array('images', 5), analyzePhysique)

// GET /api/analysis - Get history
router.get('/', protect, getAnalyses)

export default router
