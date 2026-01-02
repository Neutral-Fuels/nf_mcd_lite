import axios, { AxiosRequestConfig, AxiosResponse, AxiosError } from 'axios'
import { getUcoApiUrl } from '../config/environment.js'
import logger from '../config/logger.js'

export class ProxyService {
  private baseURL: string

  constructor() {
    this.baseURL = getUcoApiUrl()
  }

  async proxyRequest(
    method: string,
    endpoint: string,
    token?: string,
    data?: unknown,
    queryParams?: Record<string, string>
  ): Promise<unknown> {
    try {
      const config: AxiosRequestConfig = {
        method,
        url: `${this.baseURL}${endpoint}`,
        headers: {
          'Content-Type': 'application/json',
        },
        data,
        params: queryParams,
      }

      if (token) {
        config.headers!['Authorization'] = `Bearer ${token}`
      }

      logger.debug(`Proxying ${method} request to ${endpoint}`)

      const response: AxiosResponse = await axios(config)
      return response.data
    } catch (error) {
      if (axios.isAxiosError(error)) {
        const axiosError = error as AxiosError
        logger.error(`Proxy request failed: ${axiosError.message}`, {
          endpoint,
          statusCode: axiosError.response?.status,
          data: axiosError.response?.data,
        })

        throw {
          statusCode: axiosError.response?.status || 500,
          message: axiosError.message,
          data: axiosError.response?.data,
        }
      }
      throw error
    }
  }
}

export const proxyService = new ProxyService()
