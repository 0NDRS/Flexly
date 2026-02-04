import express from 'express'
import {
  generateTrainingPlan,
  getTrainingPlans,
  getTrainingPlan,
  deleteTrainingPlan,
} from '../controllers/trainingController'
import { protect } from '../middleware/authMiddleware'

const router = express.Router()

router.post('/generate', protect, generateTrainingPlan)
router.get('/', protect, getTrainingPlans)
router.get('/:id', protect, getTrainingPlan)
router.delete('/:id', protect, deleteTrainingPlan)

export default router
