import apiClient from './client'
import type { ApiResponse } from './auth.service'

class DespatchAPIService {
  /**
   * Create a new despatch for empty ROCs
   */
  async createDespatch(despatchData: any): Promise<any> {
    const response = await apiClient.post<ApiResponse<any>>(
      '/despatch/new',
      despatchData
    )

    if (!response.data.success || !response.data.data) {
      throw new Error(response.data.error?.message || 'Failed to create despatch')
    }

    return response.data.data
  }
}

export const despatchAPIService = new DespatchAPIService()
