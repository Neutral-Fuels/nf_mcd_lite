import { Router, Request, Response, NextFunction } from 'express'
import { authMiddleware } from '../middleware/auth.middleware.js'
import { proxyService } from '../services/proxy.service.js'

const router = Router()

/**
 * GET /api/trucks
 * Get list of trucks for a customer
 */
router.get('/', authMiddleware, async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { customerid } = req.query

    console.log('=== Trucks Request ===')
    console.log('Customer ID:', customerid)

    if (!customerid) {
      res.status(400).json({
        success: false,
        error: { message: 'customerid is required' },
      })
      return
    }

    const data = await proxyService.proxyRequest(
      'GET',
      '/api/v1/Customer/Trucks',
      req.token!,
      undefined,
      { customerid: customerid as string }
    )

    console.log('=== Trucks Response ===')
    console.log('Response type:', typeof data)
    console.log('Is array:', Array.isArray(data))
    console.log('Response:', JSON.stringify(data, null, 2))

    // Transform string array to truck objects
    // Production API returns array of strings (registration numbers)
    // Frontend expects array of truck objects
    let trucks: any[] = []
    if (Array.isArray(data)) {
      trucks = data.map((item: any, index: number) => {
        // If item is a string (just regno), create minimal truck object
        if (typeof item === 'string') {
          return {
            id: index + 1,
            regno: item,
            description: item, // Use regno as description for now
            customerId: customerid,
            isActive: true,
            isThirdParty: false,
          }
        }
        // If item is already an object, use it as is (for test env compatibility)
        return item
      })
    }

    res.json({
      success: true,
      data: trucks,
    })
  } catch (error: any) {
    console.error('Trucks Error:', error.message)
    next(error)
  }
})

/**
 * GET /api/trucks/3pl
 * Get list of third-party trucks for a customer
 */
router.get('/3pl', authMiddleware, async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { customerid } = req.query

    console.log('=== 3PL Trucks Request ===')
    console.log('Customer ID:', customerid)

    if (!customerid) {
      res.status(400).json({
        success: false,
        error: { message: 'customerid is required' },
      })
      return
    }

    const data = await proxyService.proxyRequest(
      'GET',
      '/api/v1/Customer/ThirdPartyTrucks',
      req.token!,
      undefined,
      { customerid: customerid as string }
    )

    console.log('=== 3PL Trucks Response ===')
    console.log('Response type:', typeof data)
    console.log('Is array:', Array.isArray(data))
    console.log('Response:', JSON.stringify(data, null, 2))

    // Transform string array to truck objects
    // Production API returns array of strings (registration numbers)
    // Frontend expects array of truck objects
    let trucks: any[] = []
    if (Array.isArray(data)) {
      trucks = data.map((item: any, index: number) => {
        // If item is a string (just regno), create minimal truck object
        if (typeof item === 'string') {
          return {
            id: index + 1,
            regno: item,
            description: item, // Use regno as description for now
            customerId: customerid,
            isActive: true,
            isThirdParty: true,
            supplierName: 'Third Party',
          }
        }
        // If item is already an object, use it as is (for test env compatibility)
        return item
      })
    }

    res.json({
      success: true,
      data: trucks,
    })
  } catch (error: any) {
    console.error('3PL Trucks Error:', error.message)
    next(error)
  }
})

export default router
