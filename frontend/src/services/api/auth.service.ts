import apiClient from './client'
import type { LoginResponse } from '@/types/models'

export interface LoginCredentials {
  username: string
  password: string
}

export interface ApiResponse<T> {
  success: boolean
  data?: T
  error?: {
    message: string
  }
}

class AuthAPIService {
  async login(credentials: LoginCredentials): Promise<LoginResponse> {
    const response = await apiClient.post<ApiResponse<LoginResponse>>(
      '/auth/login',
      credentials
    )

    if (!response.data.success || !response.data.data) {
      throw new Error(response.data.error?.message || 'Login failed')
    }

    return response.data.data
  }

  async logout(): Promise<void> {
    try {
      await apiClient.post('/auth/logout')
    } catch (error) {
      // Even if logout fails on backend, we still want to clear frontend
      console.warn('Logout API call failed, clearing local session anyway', error)
    }
  }

  async verifyToken(): Promise<boolean> {
    try {
      const response = await apiClient.get<ApiResponse<any>>('/auth/verify')
      return response.data.success
    } catch (error) {
      return false
    }
  }
}

export const authAPIService = new AuthAPIService()
