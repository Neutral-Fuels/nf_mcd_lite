import apiClient from './client'
import type { ApiResponse } from './auth.service'
import type { PendingDelivery } from '@/types/models'

class DeliveryAPIService {
  /**
   * Get pending deliveries by truck registration
   */
  async getPendingDeliveries(truckRego: string): Promise<PendingDelivery[]> {
    console.log('[DeliveryAPI] Fetching pending deliveries for truck:', truckRego)

    const response = await apiClient.get<ApiResponse<PendingDelivery[]>>(
      '/collection/pending',
      {
        params: { truckrego: truckRego }
      }
    )

    console.log('[DeliveryAPI] Pending deliveries response:', response.data)

    if (!response.data.success) {
      throw new Error(response.data.error?.message || 'Failed to fetch pending deliveries')
    }

    return response.data.data || []
  }

  /**
   * Create a new delivery
   */
  async createDelivery(deliveryData: any): Promise<any> {
    const response = await apiClient.post<ApiResponse<any>>(
      '/delivery/new',
      deliveryData
    )

    if (!response.data.success || !response.data.data) {
      throw new Error(response.data.error?.message || 'Failed to create delivery')
    }

    return response.data.data
  }
}

export const deliveryAPIService = new DeliveryAPIService()
