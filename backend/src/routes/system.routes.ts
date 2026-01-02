import { Router, Request, Response, NextFunction } from 'express'
import { authMiddleware } from '../middleware/auth.middleware.js'
import { proxyService } from '../services/proxy.service.js'

const router = Router()

/**
 * GET /api/system/version
 * Get current mobile app version information
 */
router.get('/version', authMiddleware, async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const data = await proxyService.proxyRequest(
      'GET',
      '/api/v1/System/MobileApps',
      req.token!
    )

    res.json({
      success: true,
      data,
    })
  } catch (error: any) {
    next(error)
  }
})

export default router
