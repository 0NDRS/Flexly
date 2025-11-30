import express, { Request, Response } from 'express'
import cors from 'cors'

const app = express()
const port = 3000

app.use(cors())
app.use(express.json())

app.get('/api/analysis', (req: Request, res: Response) => {
  res.json({
    rating: 6.7,
    streak: 67,
    analyticsTracked: 67,
  })
})

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`)
})
