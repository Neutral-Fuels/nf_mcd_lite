import apiClient from './client'
import type { McdStaffModel, NFStaffModel } from '@/types/models'
import type { ApiResponse } from './auth.service'

class StaffAPIService {
  /**
   * Get McDonald's staff by store ID
   */
  async getMcdStaffByStore(storeId: string): Promise<McdStaffModel[]> {
    const response = await apiClient.get<ApiResponse<McdStaffModel[]>>(
      `/staff/mcd/store/${storeId}`
    )

    if (!response.data.success || !response.data.data) {
      throw new Error(response.data.error?.message || 'Failed to fetch McDonald\'s staff by store')
    }

    return response.data.data
  }

  /**
   * Get McDonald's staff by country ID
   */
  async getMcdStaffByCountry(countryId: string): Promise<McdStaffModel[]> {
    const response = await apiClient.get<ApiResponse<McdStaffModel[]>>(
      '/staff/mcd/country',
      {
        params: { countryid: countryId }
      }
    )

    if (!response.data.success || !response.data.data) {
      throw new Error(response.data.error?.message || 'Failed to fetch McDonald\'s staff by country')
    }

    return response.data.data
  }

  /**
   * Get McDonald's staff by employee ID
   */
  async getMcdStaffByEmployeeId(employeeId: string): Promise<McdStaffModel> {
    const response = await apiClient.get<ApiResponse<McdStaffModel>>(
      '/staff/mcd/employee',
      {
        params: { employeeid: employeeId }
      }
    )

    if (!response.data.success || !response.data.data) {
      throw new Error(response.data.error?.message || 'Failed to fetch McDonald\'s staff by employee ID')
    }

    return response.data.data
  }

  /**
   * Get Neutral Fuels staff by site ID
   */
  async getNfStaffBySite(siteId: string): Promise<NFStaffModel[]> {
    const response = await apiClient.get<ApiResponse<NFStaffModel[]>>(
      `/staff/nf/site/${siteId}`
    )

    if (!response.data.success || !response.data.data) {
      throw new Error(response.data.error?.message || 'Failed to fetch Neutral Fuels staff by site')
    }

    return response.data.data
  }
}

export const staffAPIService = new StaffAPIService()
