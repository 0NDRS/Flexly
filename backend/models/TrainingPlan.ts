import mongoose from 'mongoose'

const exerciseSchema = new mongoose.Schema({
  name: { type: String, required: true },
  sets: { type: Number, required: true },
  reps: { type: String, required: true },
  notes: { type: String },
})

const dayPlanSchema = new mongoose.Schema({
  day: { type: String, required: true },
  focus: { type: String, required: true },
  exercises: [exerciseSchema],
  isRestDay: { type: Boolean, default: false },
})

const trainingPlanSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      required: true,
      ref: 'User',
    },
    title: {
      type: String,
      required: true,
    },
    description: {
      type: String,
      required: true,
    },
    weekPlan: [dayPlanSchema],
    tips: [{ type: String }],
    userStats: {
      goal: { type: String },
      weight: { type: Number },
      height: { type: Number },
      gender: { type: String },
      muscleStats: {
        arms: { type: Number },
        chest: { type: Number },
        abs: { type: Number },
        shoulders: { type: Number },
        legs: { type: Number },
        back: { type: Number },
      },
    },
  },
  {
    timestamps: true,
  },
)

const TrainingPlan = mongoose.model('TrainingPlan', trainingPlanSchema)

export default TrainingPlan
