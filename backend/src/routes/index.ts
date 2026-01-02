import { Router } from 'express'
import authRoutes from './auth.routes.js'
import truckRoutes from './truck.routes.js'
import storeRoutes from './store.routes.js'
import staffRoutes from './staff.routes.js'
import collectionRoutes from './collection.routes.js'
import deliveryRoutes from './delivery.routes.js'
import despatchRoutes from './despatch.routes.js'
import systemRoutes from './system.routes.js'

const router = Router()

// Health check endpoint
router.get('/health', (_req, res) => {
  res.json({
    success: true,
    message: 'McDonald\'s UCO API is running',
    timestamp: new Date().toISOString(),
  })
})

// Authentication routes (Phase 2)
router.use('/auth', authRoutes)

// Core API routes (Phase 3)
router.use('/trucks', truckRoutes)
router.use('/stores', storeRoutes)
router.use('/staff', staffRoutes)
router.use('/collection', collectionRoutes)
router.use('/delivery', deliveryRoutes)
router.use('/despatch', despatchRoutes)
router.use('/system', systemRoutes)

export default router
