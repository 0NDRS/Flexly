import mongoose from 'mongoose'

const commentSchema = new mongoose.Schema(
  {
    analysis: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Analysis',
      required: true,
      index: true,
    },
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    text: {
      type: String,
      required: true,
      trim: true,
      maxlength: 1000,
    },
  },
  {
    timestamps: true,
  }
)

const Comment = mongoose.model('Comment', commentSchema)

export default Comment
