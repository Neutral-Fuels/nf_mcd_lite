/**
 * API Services - Phase 3
 * Centralized exports for all API service modules
 */

export { authAPIService } from './auth.service'
export { truckAPIService } from './truck.service'
export { storeAPIService } from './store.service'
export { staffAPIService } from './staff.service'
export { collectionAPIService } from './collection.service'
export { deliveryAPIService } from './delivery.service'
export { despatchAPIService } from './despatch.service'
export { systemAPIService } from './system.service'

// Re-export types
export type { LoginCredentials, ApiResponse } from './auth.service'
export type { MobileAppVersion } from './system.service'
