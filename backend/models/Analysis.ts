import mongoose from 'mongoose'

const analysisSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'User',
  },
  imageUrls: [
    {
      type: String,
      required: true,
    },
  ],
  ratings: {
    arms: { type: Number, required: true },
    chest: { type: Number, required: true },
    abs: { type: Number, required: true },
    shoulders: { type: Number, required: true },
    legs: { type: Number, required: true },
    back: { type: Number, required: true },
    overall: { type: Number, required: true },
  },
  advice: {
    type: String,
    required: true,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
})

const Analysis = mongoose.model('Analysis', analysisSchema)

export default Analysis
