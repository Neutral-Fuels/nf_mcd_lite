import express from 'express'
import cors from 'cors'
import helmet from 'helmet'
import rateLimit from 'express-rate-limit'
import { corsOptions } from './config/cors.js'
import { errorMiddleware } from './middleware/error.middleware.js'
import { loggingMiddleware } from './middleware/logging.middleware.js'
import routes from './routes/index.js'

const app = express()

// Security middleware
app.use(helmet())
app.use(cors(corsOptions))

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per window
  message: 'Too many requests from this IP, please try again later.',
})
app.use('/api/', limiter)

// Body parsing
app.use(express.json())
app.use(express.urlencoded({ extended: true }))

// Logging
app.use(loggingMiddleware)

// Routes
app.use('/api', routes)

// Error handling
app.use(errorMiddleware)

export default app
