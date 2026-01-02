import { Request, Response, NextFunction } from 'express'
import logger from '../config/logger.js'

export interface ApiError extends Error {
  statusCode?: number
  isOperational?: boolean
}

export function errorMiddleware(
  err: ApiError,
  _req: Request,
  res: Response,
  _next: NextFunction
) {
  const statusCode = err.statusCode || 500
  const message = err.message || 'Internal Server Error'

  logger.error(`Error ${statusCode}: ${message}`, {
    stack: err.stack,
    isOperational: err.isOperational,
  })

  res.status(statusCode).json({
    success: false,
    error: {
      message,
      ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
    },
  })
}
