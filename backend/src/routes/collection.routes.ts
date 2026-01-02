import { Router, Request, Response, NextFunction } from 'express'
import { authMiddleware } from '../middleware/auth.middleware.js'
import { proxyService } from '../services/proxy.service.js'

const router = Router()

/**
 * GET /api/collection/pending
 * Get pending collections by truck registration
 */
router.get('/pending', authMiddleware, async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { truckrego, isallclientcollections } = req.query

    if (!truckrego) {
      res.status(400).json({
        success: false,
        error: { message: 'truckrego is required' },
      })
      return
    }

    const data = await proxyService.proxyRequest(
      'GET',
      '/api/v1/ROCCollection/CollectionsPendingByTruckRego',
      req.token!,
      undefined,
      {
        truckrego: truckrego as string,
        isallclientcollections: isallclientcollections as string || 'false'
      }
    )

    console.log('=== Collection Pending API Response ===')
    console.log('Truck Rego:', truckrego)
    console.log('Raw Response:', JSON.stringify(data, null, 2))

    // Transform collections data from production API format to expected frontend format
    // Production API returns: { Collections: [...] } with containers array
    // Frontend expects: [...] with each container as a separate PendingDelivery item
    let collections: any[] = []

    if (data && typeof data === 'object' && 'Collections' in data && Array.isArray((data as any).Collections)) {
      // Flatten: each container becomes a separate pending delivery item
      (data as any).Collections.forEach((collection: any) => {
        const containers = collection.containers || []

        if (containers.length > 0) {
          // Each container is a separate delivery item
          containers.forEach((container: any) => {
            collections.push({
              ucocollectionid: container.ucocollectionid || collection.ucocollectionid,
              rocnumber: String(container.rocnumber || ''),
              collectiondate: collection.datetimeofcollection,
              storename: collection.store_name,
              storeid: collection.storeid,
              quantity: container.quantity || 0,
              truckrego: collection.truckrego,
              supervisorname: collection.supervisorname,
              containertypeid: container.containertypeid || 1,
              state: '', // Will be set by user in UI
            })
          })
        } else {
          // Collection without containers (edge case)
          collections.push({
            ucocollectionid: collection.ucocollectionid,
            rocnumber: '',
            collectiondate: collection.datetimeofcollection,
            storename: collection.store_name,
            storeid: collection.storeid,
            quantity: 0,
            truckrego: collection.truckrego,
            supervisorname: collection.supervisorname,
            state: '',
          })
        }
      })
    } else if (Array.isArray(data)) {
      // Fallback for test environment if it returns an array directly
      collections = data
    }

    console.log('=== Transformed Collections ===')
    console.log('Total items:', collections.length)
    console.log('Sample item:', collections[0] ? JSON.stringify(collections[0], null, 2) : 'none')

    res.json({
      success: true,
      data: collections,
    })
  } catch (error: any) {
    console.error('Collection Pending Error:', error.message)
    next(error)
  }
})

/**
 * GET /api/collection/empty-rocs/:storeId
 * Get empty ROCs at a store
 */
router.get('/empty-rocs/:storeId', authMiddleware, async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { storeId } = req.params

    console.log('=== Empty ROCs Request ===')
    console.log('Store ID:', storeId)

    const data = await proxyService.proxyRequest(
      'GET',
      '/api/v1/ROCCollection/EmptyRocsAtStore',
      req.token!,
      undefined,
      { storeid: storeId }
    )

    console.log('=== Empty ROCs Response ===')
    console.log('Response type:', typeof data)
    console.log('Is array:', Array.isArray(data))
    console.log('Response:', JSON.stringify(data, null, 2))

    res.json({
      success: true,
      data,
    })
  } catch (error: any) {
    console.error('Empty ROCs Error:', error.message)
    next(error)
  }
})

/**
 * POST /api/collection/new
 * Create a new collection
 */
router.post('/new', authMiddleware, async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    console.log('=== New Collection Request ===')
    console.log('Environment:', process.env.ENVIRONMENT)
    console.log('Target API:', process.env.ENVIRONMENT === 'production' ? process.env.UCO_API_PROD_URL : process.env.UCO_API_TEST_URL)
    console.log('Request Body:', JSON.stringify(req.body, null, 2))

    const data = await proxyService.proxyRequest(
      'POST',
      '/api/v1/ROCCollection/newCollection',
      req.token!,
      req.body
    )

    console.log('=== New Collection Response ===')
    console.log('Response:', JSON.stringify(data, null, 2))

    // Emit WebSocket event (Phase 9)
    // req.app.get('io').emit('collection:created', data)

    res.json({
      success: true,
      data,
    })
  } catch (error: any) {
    console.error('=== New Collection Error ===')
    console.error('Error message:', error.message)
    console.error('Error status:', error.statusCode)
    console.error('Error data:', JSON.stringify(error.data, null, 2))
    console.error('Full error:', JSON.stringify(error, null, 2))
    next(error)
  }
})

export default router
