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

// Test Route (Deprecated by analysisRoutes, but kept for compatibility if needed)
// app.get('/api/analysis', ...)

// Start Server
app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`)
})
