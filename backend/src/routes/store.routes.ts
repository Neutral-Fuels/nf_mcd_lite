import { Router, Request, Response, NextFunction } from 'express'
import { authMiddleware } from '../middleware/auth.middleware.js'
import { proxyService } from '../services/proxy.service.js'

const router = Router()

/**
 * GET /api/stores
 * Get list of stores for a customer
 */
router.get('/', authMiddleware, async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { customerid } = req.query

    console.log('=== Stores Request ===')
    console.log('Customer ID:', customerid)

    if (!customerid) {
      res.status(400).json({
        success: false,
        error: { message: 'customerid is required' },
      })
      return
    }

    const response = await proxyService.proxyRequest(
      'GET',
      '/api/v1/Customer/Stores',
      req.token!,
      undefined,
      { customerid: customerid as string }
    ) as any

    console.log('=== Stores Response ===')
    console.log('Response type:', typeof response)
    console.log('Response:', JSON.stringify(response, null, 2))

    // Extract stores array from response
    const stores = response.stores || []

    // Map field names from snake_case to camelCase
    const mappedStores = stores.map((store: any) => ({
      id: store.storeid,
      storeId: store.storeid,
      storeName: store.store_name,
      storeCode: store.storenumber?.toString(),
      storeNo: store.storenumber?.toString(),
      address: store.address || '',
      city: store.city || '',
      suburb: store.city || '',
      state: store.state || '',
      postcode: store.postcode || '',
      postCode: store.postcode || '',
      country: store.country || '',
      latitude: store.latitude,
      longitude: store.longitude,
      customerId: customerid as string,
      isActive: true,
      contactPhone: store.contactphone || ''
    }))

    res.json({
      success: true,
      data: mappedStores,
    })
  } catch (error: any) {
    console.error('Stores Error:', error.message)
    next(error)
  }
})

export default router
