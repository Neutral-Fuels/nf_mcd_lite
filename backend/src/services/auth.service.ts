import axios, { AxiosError } from 'axios'
import { getUcoApiUrl } from '../config/environment.js'
import logger from '../config/logger.js'

export interface LoginRequest {
  grant_type: 'password'
  username: string
  password: string
}

export interface LoginResponse {
  access_token: string
  token_type: string
  expires_in: number
  id: string
  username: string
  email: string
  licenseNo: string
  firstName: string
  lastName: string
  isMcDUser: 'True' | 'False'
  customerId: string
  customerName: string
  countryId: string
  countryIso: string
  siteId: string
  timeZoneName: string
  customerHasTruck: 'True' | 'False'
  isthirdpartyuser: 'True' | 'False'
  '.issued': string
  '.expires': string
}

export class AuthService {
  private baseURL: string

  constructor() {
    this.baseURL = getUcoApiUrl()
  }

  async login(username: string, password: string): Promise<LoginResponse> {
    try {
      const loginData: LoginRequest = {
        grant_type: 'password',
        username,
        password,
      }

      logger.info(`Login attempt for user: ${username}`)

      const response = await axios.post<LoginResponse>(
        `${this.baseURL}/api/v1/Token`,
        new URLSearchParams(loginData as any).toString(),
        {
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        }
      )

      const userData = response.data

      // Note: McDonald's user validation removed for production compatibility
      // Production API may return different values for isMcDUser
      logger.info(`Login successful for user: ${username}`)

      return userData
    } catch (error) {
      if (axios.isAxiosError(error)) {
        const axiosError = error as AxiosError
        logger.error(`Login failed for user ${username}:`, {
          status: axiosError.response?.status,
          statusText: axiosError.response?.statusText,
          message: axiosError.message,
          data: axiosError.response?.data,
          url: axiosError.config?.url,
        })

        if (axiosError.response?.status === 400) {
          throw {
            statusCode: 401,
            message: 'Invalid username or password',
            isOperational: true,
          }
        }

        throw {
          statusCode: axiosError.response?.status || 500,
          message: 'Authentication failed. Please try again.',
          isOperational: true,
        }
      }

      throw error
    }
  }

  async logout(token: string): Promise<void> {
    try {
      logger.info('Logout request received')

      await axios.post(
        `${this.baseURL}/api/v1/Users/Logout`,
        {},
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      )

      logger.info('Logout successful')
    } catch (error) {
      if (axios.isAxiosError(error)) {
        const axiosError = error as AxiosError
        logger.error('Logout failed:', {
          status: axiosError.response?.status,
          message: axiosError.message,
        })
      }
      // Don't throw error on logout failure - still clear local session
      logger.warn('Logout API call failed, but proceeding with local session cleanup')
    }
  }
}

export const authService = new AuthService()
