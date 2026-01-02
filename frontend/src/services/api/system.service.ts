import apiClient from './client'
import type { ApiResponse } from './auth.service'

export interface MobileAppVersion {
  id: number
  version: string
  platform: string
  minVersion?: string
  forceUpdate?: boolean
  releaseDate?: string
}

class SystemAPIService {
  /**
   * Get current mobile app version information
   */
  async getVersion(): Promise<MobileAppVersion> {
    const response = await apiClient.get<ApiResponse<MobileAppVersion>>(
      '/system/version'
    )

    if (!response.data.success || !response.data.data) {
      throw new Error(response.data.error?.message || 'Failed to fetch version information')
    }

    return response.data.data
  }
}

export const systemAPIService = new SystemAPIService()
