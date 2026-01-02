import { Request, Response, NextFunction } from 'express'

// Extend Express Request type to include token
declare global {
  namespace Express {
    interface Request {
      token?: string
    }
  }
}

export function authMiddleware(req: Request, res: Response, next: NextFunction): void {
  const authHeader = req.headers.authorization

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    res.status(401).json({
      success: false,
      error: { message: 'Authorization token required' },
    })
    return
  }

  const token = authHeader.substring(7)
  req.token = token

  next()
}
