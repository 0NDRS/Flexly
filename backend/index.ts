import dotenv from 'dotenv'

dotenv.config()

import express, { Request, Response } from 'express'
import cors from 'cors'
import path from 'path'
import connectDB from './config/db'
import configureCloudinary from './config/cloudinary'
import authRoutes from './routes/authRoutes'
import analysisRoutes from './routes/analysisRoutes'
import userRoutes from './routes/userRoutes'
import notificationRoutes from './routes/notificationRoutes'

connectDB()

configureCloudinary()

const app = express()
const port = process.env.PORT || 3000

app.use(cors())
app.use(express.json())
app.use(express.urlencoded({ extended: false }))

app.use('/uploads', express.static(path.join(__dirname, '../uploads')))

app.use('/api/auth', authRoutes)
app.use('/api/analysis', analysisRoutes)
app.use('/api/users', userRoutes)
app.use('/api/notifications', notificationRoutes)

app.use((err: any, req: Request, res: Response, next: any) => {
  console.error(err.stack)
  res.status(500).json({
    message: err.message || 'Internal Server Error',
    stack: process.env.NODE_ENV === 'production' ? null : err.stack,
  })
})

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`)
})
