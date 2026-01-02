import apiClient from './client'
import type { StoreModel } from '@/types/models'
import type { ApiResponse } from './auth.service'

class StoreAPIService {
  /**
   * Get customer stores by customer ID
   */
  async getCustomerStores(customerId: string): Promise<StoreModel[]> {
    const response = await apiClient.get<ApiResponse<StoreModel[]>>(
      '/stores',
      {
        params: { customerid: customerId }
      }
    )

    if (!response.data.success || !response.data.data) {
      throw new Error(response.data.error?.message || 'Failed to fetch customer stores')
    }

    return response.data.data
  }
}

export const storeAPIService = new StoreAPIService()
