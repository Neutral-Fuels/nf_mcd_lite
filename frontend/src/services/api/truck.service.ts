import apiClient from './client'
import type { TruckModel, ThirdPartyTruckModel } from '@/types/models'
import type { ApiResponse } from './auth.service'

class TruckAPIService {
  /**
   * Get customer trucks by customer ID
   */
  async getCustomerTrucks(customerId: string): Promise<TruckModel[]> {
    const response = await apiClient.get<ApiResponse<TruckModel[]>>(
      '/trucks',
      {
        params: { customerid: customerId }
      }
    )

    if (!response.data.success || !response.data.data) {
      throw new Error(response.data.error?.message || 'Failed to fetch customer trucks')
    }

    return response.data.data
  }

  /**
   * Get third-party trucks by customer ID
   */
  async getThirdPartyTrucks(customerId: string): Promise<ThirdPartyTruckModel[]> {
    const response = await apiClient.get<ApiResponse<ThirdPartyTruckModel[]>>(
      '/trucks/3pl',
      {
        params: { customerid: customerId }
      }
    )

    if (!response.data.success || !response.data.data) {
      throw new Error(response.data.error?.message || 'Failed to fetch third-party trucks')
    }

    return response.data.data
  }
}

export const truckAPIService = new TruckAPIService()
