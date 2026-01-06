import mongoose from 'mongoose'
import bcrypt from 'bcryptjs'

// Define the User Schema
const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Please add a name'],
  },
  email: {
    type: String,
    required: [true, 'Please add an email'],
    unique: true,
    // Regex for email validation
    match: [
      /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/,
      'Please add a valid email',
    ],
  },
  username: {
    type: String,
    unique: true,
    sparse: true, // Allows null/undefined to not conflict
  },
  bio: {
    type: String,
    default: '',
  },
  followers: {
    type: Number,
    default: 0,
  },
  following: {
    type: Number,
    default: 0,
  },
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
  profilePicture: {
    type: String,
    default: '',
  },
  password: {
    type: String,
    required: [true, 'Please add a password'],
    minlength: 6,
    select: false, // Don't return password by default in queries
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
})

// Middleware: Encrypt password using bcrypt before saving
userSchema.pre('save', async function () {
  // Only hash the password if it has been modified (or is new)
  if (!this.isModified('password')) {
    return
  }

  const salt = await bcrypt.genSalt(10)
  this.password = await bcrypt.hash(this.password, salt)
})

// Method: Match user entered password to hashed password in database
userSchema.methods.matchPassword = async function (enteredPassword: string) {
  return await bcrypt.compare(enteredPassword, this.password)
}

const User = mongoose.model('User', userSchema)

export default User
