import dotenv from 'dotenv'
// Load environment variables first
dotenv.config()

import express, { Request, Response } from 'express'
import cors from 'cors'
import path from 'path'
import connectDB from './config/db'
import configureCloudinary from './config/cloudinary'
import authRoutes from './routes/authRoutes'
import analysisRoutes from './routes/analysisRoutes'
import userRoutes from './routes/userRoutes'

// Connect to MongoDB
connectDB()

// Configure Cloudinary
configureCloudinary()

const app = express()
const port = process.env.PORT || 3000

// Middleware
app.use(cors()) // Enable CORS
app.use(express.json()) // Parse JSON bodies
app.use(express.urlencoded({ extended: false })) // Parse URL-encoded bodies

// Serve uploaded images statically
app.use('/uploads', express.static(path.join(__dirname, '../uploads')))

// Routes
app.use('/api/auth', authRoutes)
app.use('/api/analysis', analysisRoutes)
app.use('/api/users', userRoutes)

// Error Handler
app.use((err: any, req: Request, res: Response, next: any) => {
  console.error(err.stack)
  res.status(500).json({
    message: err.message || 'Internal Server Error',
    stack: process.env.NODE_ENV === 'production' ? null : err.stack,
  })
})

// Start Server
app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`)
})
