import { Router, Request, Response, NextFunction } from 'express'
import { authService } from '../services/auth.service.js'
import { authMiddleware } from '../middleware/auth.middleware.js'
import logger from '../config/logger.js'

const router = Router()

/**
 * POST /api/auth/login
 * Login with OAuth2 password grant
 */
router.post('/login', async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { username, password } = req.body

    console.log('=== Login Request ===')
    console.log('Username:', username)

    if (!username || !password) {
      res.status(400).json({
        success: false,
        error: { message: 'Username and password are required' },
      })
      return
    }

    const userData = await authService.login(username, password)

    console.log('=== Login Response ===')
    console.log('User Data:', JSON.stringify(userData, null, 2))

    res.json({
      success: true,
      data: userData,
    })
  } catch (error: any) {
    console.error('Login Error:', error.message)
    next(error)
  }
})

/**
 * POST /api/auth/logout
 * Logout and invalidate token
 */
router.post('/logout', authMiddleware, async (req: Request, res: Response, _next: NextFunction): Promise<void> => {
  try {
    const token = req.token!

    await authService.logout(token)

    res.json({
      success: true,
      message: 'Logout successful',
    })
  } catch (error: any) {
    // Even if logout fails on backend, return success to clear frontend session
    logger.warn('Logout API failed but returning success to client')
    res.json({
      success: true,
      message: 'Logout successful',
    })
  }
})

/**
 * GET /api/auth/verify
 * Verify if token is still valid
 */
router.get('/verify', authMiddleware, (_req: Request, res: Response): void => {
  res.json({
    success: true,
    message: 'Token is valid',
  })
})

export default router
