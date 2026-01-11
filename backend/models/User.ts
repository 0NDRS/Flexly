import mongoose from 'mongoose'
import bcrypt from 'bcryptjs'

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Please add a name'],
  },
  email: {
    type: String,
    required: [true, 'Please add an email'],
    unique: true,
    match: [
      /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/,
      'Please add a valid email',
    ],
  },
  username: {
    type: String,
    unique: true,
    sparse: true,
  },
  bio: {
    type: String,
    default: '',
  },
  gender: {
    type: String,
    enum: ['Male', 'Female', 'Other'],
  },
  age: {
    type: Number,
  },
  height: {
    type: Number,
  },
  weight: {
    type: Number,
  },
  goal: {
    type: String,
  },
  followers: {
    type: Number,
    default: 0,
  },
  following: {
    type: Number,
    default: 0,
  },
  followersList: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  followingList: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  score: {
    type: Number,
    default: 0,
  },
  streak: {
    type: Number,
    default: 0,
  },
  analyticsTracked: {
    type: Number,
    default: 0,
  },
  muscleStats: {
    arms: { type: Number, default: 0 },
    chest: { type: Number, default: 0 },
    abs: { type: Number, default: 0 },
    shoulders: { type: Number, default: 0 },
    legs: { type: Number, default: 0 },
    back: { type: Number, default: 0 },
  },
  profilePicture: {
    type: String,
    default: '',
  },
  nameChangedAt: {
    type: Date,
  },
  usernameChangedAt: {
    type: Date,
  },
  password: {
    type: String,
    required: [true, 'Please add a password'],
    minlength: 6,
    select: false,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
})

userSchema.pre('save', async function () {
  if (!this.isModified('password')) {
    return
  }

  const salt = await bcrypt.genSalt(10)
  this.password = await bcrypt.hash(this.password, salt)
})

userSchema.methods.matchPassword = async function (enteredPassword: string) {
  return await bcrypt.compare(enteredPassword, this.password)
}

const User = mongoose.model('User', userSchema)

export default User
