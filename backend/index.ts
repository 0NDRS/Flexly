import express, { Request, Response } from 'express'
import cors from 'cors'
import dotenv from 'dotenv'
import connectDB from './config/db'
import authRoutes from './routes/authRoutes'

// Load environment variables
dotenv.config()

// Connect to MongoDB
connectDB()

const app = express()
const port = process.env.PORT || 3000

// Middleware
app.use(cors()) // Enable CORS
app.use(express.json()) // Parse JSON bodies
app.use(express.urlencoded({ extended: false })) // Parse URL-encoded bodies

// Routes
app.use('/api/auth', authRoutes)

// Test Route
app.get('/api/analysis', (req: Request, res: Response) => {
  res.json({
    rating: 6.7,
    streak: 67,
    analyticsTracked: 67,
  })
})

// Start Server
app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`)
})
