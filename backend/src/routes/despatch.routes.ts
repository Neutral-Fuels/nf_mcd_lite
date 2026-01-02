import { Router, Request, Response, NextFunction } from 'express'
import { authMiddleware } from '../middleware/auth.middleware.js'
import { proxyService } from '../services/proxy.service.js'

const router = Router()

/**
 * POST /api/despatch/new
 * Create a new despatch for empty ROCs
 */
router.post('/new', authMiddleware, async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    console.log('=== Despatch POST Request ===')
    console.log('Request Body:', JSON.stringify(req.body, null, 2))

    const data = await proxyService.proxyRequest(
      'POST',
      '/api/v1/Despatch/newDepatchedEmpty',
      req.token!,
      req.body
    )

    console.log('=== Despatch API Response ===')
    console.log('Response:', JSON.stringify(data, null, 2))

    res.json({
      success: true,
      data,
    })
  } catch (error: any) {
    console.error('Despatch API Error:', error.message)
    next(error)
  }
})

export default router
