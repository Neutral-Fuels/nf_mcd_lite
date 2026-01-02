import { Router, Request, Response, NextFunction } from 'express'
import { authMiddleware } from '../middleware/auth.middleware.js'
import { proxyService } from '../services/proxy.service.js'

const router = Router()

/**
 * GET /api/staff/mcd/store/:storeId
 * Get McDonald's staff by store
 */
router.get('/mcd/store/:storeId', authMiddleware, async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { storeId } = req.params

    console.log('=== MCD Staff By Store Request ===')
    console.log('Store ID:', storeId)

    const data = await proxyService.proxyRequest(
      'GET',
      '/api/v1/McdStaff/StaffByStore',
      req.token!,
      undefined,
      { storeId }
    )

    console.log('=== MCD Staff By Store Response ===')
    console.log('Response type:', typeof data)
    console.log('Is array:', Array.isArray(data))
    console.log('Response:', JSON.stringify(data, null, 2))

    res.json({
      success: true,
      data,
    })
  } catch (error: any) {
    console.error('MCD Staff By Store Error:', error.message)
    next(error)
  }
})

/**
 * GET /api/staff/mcd/country
 * Get McDonald's staff by country
 */
router.get('/mcd/country', authMiddleware, async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { countryid } = req.query

    if (!countryid) {
      res.status(400).json({
        success: false,
        error: { message: 'countryid is required' },
      })
      return
    }

    console.log('=== MCD Staff By Country Request ===')
    console.log('Country ID:', countryid)

    const data = await proxyService.proxyRequest(
      'GET',
      '/api/v1/McdStaff/StaffByCountry',
      req.token!,
      undefined,
      { countryid: countryid as string }
    )

    console.log('=== MCD Staff By Country Response ===')
    console.log('Response type:', typeof data)
    console.log('Is array:', Array.isArray(data))
    console.log('Response:', JSON.stringify(data, null, 2))

    res.json({
      success: true,
      data,
    })
  } catch (error: any) {
    console.error('MCD Staff By Country Error:', error.message)
    next(error)
  }
})

/**
 * GET /api/staff/mcd/employee
 * Get McDonald's staff by employee ID
 */
router.get('/mcd/employee', authMiddleware, async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { employeeid } = req.query

    if (!employeeid) {
      res.status(400).json({
        success: false,
        error: { message: 'employeeid is required' },
      })
      return
    }

    console.log('=== Staff Lookup Request ===')
    console.log('Employee ID:', employeeid)

    const data = await proxyService.proxyRequest(
      'GET',
      '/api/v1/McdStaff/StaffMemberByEmployeeId',
      req.token!,
      undefined,
      { employeeid: employeeid as string }
    )

    console.log('=== Staff Lookup Response ===')
    console.log('Response:', JSON.stringify(data, null, 2))

    res.json({
      success: true,
      data,
    })
  } catch (error: any) {
    console.error('Staff Lookup Error:', error.message)
    next(error)
  }
})

/**
 * GET /api/staff/nf/site/:siteId
 * Get Neutral Fuels staff by site
 */
router.get('/nf/site/:siteId', authMiddleware, async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { siteId } = req.params

    console.log('=== NF Staff List Request ===')
    console.log('Site ID:', siteId)

    const data = await proxyService.proxyRequest(
      'GET',
      '/api/v1/NFStaff/StaffBySite',
      req.token!,
      undefined,
      { siteId }
    )

    console.log('=== NF Staff List Response ===')
    console.log('Response:', JSON.stringify(data, null, 2))

    res.json({
      success: true,
      data,
    })
  } catch (error: any) {
    console.error('NF Staff List Error:', error.message)
    next(error)
  }
})

export default router
