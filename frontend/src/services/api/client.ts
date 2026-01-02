import axios, { AxiosInstance, AxiosError, InternalAxiosRequestConfig } from 'axios'
import { useAuthStore } from '@/stores/auth'
import { useUIStore } from '@/stores/ui'

// Create axios instance
const apiClient: AxiosInstance = axios.create({
  baseURL: import.meta.env.VITE_BACKEND_URL || 'http://localhost:3000/api',
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
  },
})

// Request interceptor - Add auth token
apiClient.interceptors.request.use(
  (config: InternalAxiosRequestConfig) => {
    const authStore = useAuthStore()

    if (authStore.token && config.headers) {
      config.headers.Authorization = `Bearer ${authStore.token}`
    }

    return config
  },
  (error: AxiosError) => {
    return Promise.reject(error)
  }
)

// Response interceptor - Handle errors
apiClient.interceptors.response.use(
  response => response,
  async (error: AxiosError) => {
    const authStore = useAuthStore()
    const uiStore = useUIStore()

    if (error.response?.status === 401) {
      // Unauthorized - clear auth and redirect to login
      authStore.clearStorage()
      window.location.href = '/login'
      uiStore.showToast('Session expired. Please login again.', 'error')
    } else if (error.response?.status === 403) {
      uiStore.showToast('Access denied', 'error')
    } else if (error.response && error.response.status >= 500) {
      uiStore.showToast('Server error. Please try again later.', 'error')
    } else if (!error.response) {
      // Network error
      uiStore.showToast('Network error. Please check your connection.', 'error')
    }

    return Promise.reject(error)
  }
)

export default apiClient
