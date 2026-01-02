import { Router, Request, Response, NextFunction } from 'express'
import { authMiddleware } from '../middleware/auth.middleware.js'
import { proxyService } from '../services/proxy.service.js'

const router = Router()

/**
 * POST /api/delivery/new
 * Create a new delivery
 */
router.post('/new', authMiddleware, async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    console.log('=== Delivery POST Request ===')
    console.log('Request Body:', JSON.stringify(req.body, null, 2))

    const data = await proxyService.proxyRequest(
      'POST',
      '/api/v1/ROCDelivery/newDelivery',
      req.token!,
      req.body
    )

    console.log('=== Delivery API Response ===')
    console.log('Response:', JSON.stringify(data, null, 2))

    // Emit WebSocket event (Phase 9)
    // req.app.get('io').emit('delivery:created', data)

    res.json({
      success: true,
      data,
    })
  } catch (error: any) {
    console.error('Delivery API Error:', error.message)
    next(error)
  }
})

export default router
