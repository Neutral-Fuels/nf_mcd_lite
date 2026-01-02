import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useUIStore } from '@/stores/ui'
import { authAPIService } from '@/services/api/auth.service'
import { secureStorageService } from '@/services/storage/indexedDB'
import type { LoginResponse } from '@/types/models'

export function useAuth() {
  const router = useRouter()
  const authStore = useAuthStore()
  const uiStore = useUIStore()

  const isLoading = ref(false)
  const error = ref<string | null>(null)

  // Computed
  const isAuthenticated = computed(() => authStore.isAuthenticated)
  const user = computed(() => authStore.user)

  /**
   * Login with username and password
   */
  async function login(username: string, password: string, rememberMe = false): Promise<boolean> {
    try {
      isLoading.value = true
      error.value = null

      // Call API
      const userData: LoginResponse = await authAPIService.login({ username, password })

      // Store user data - handle both camelCase and lowercase field names from different API environments
      authStore.setUser({
        accessToken: userData.access_token,
        tokenType: userData.token_type,
        expiresIn: userData.expires_in,
        id: userData.id,
        username: userData.username,
        email: userData.email,
        licenseNo: (userData as any).licenseno || userData.licenseNo,
        firstName: (userData as any).firstname || userData.firstName,
        lastName: (userData as any).lastname || userData.lastName,
        isMcDUser: (userData as any).ismcduser || userData.isMcDUser,
        customerId: (userData as any).customerid || userData.customerId,
        customerName: (userData as any).customername || userData.customerName,
        countryId: (userData as any).countryid || userData.countryId,
        countryIso: (userData as any).countryiso || userData.countryIso,
        siteId: (userData as any).siteid || userData.siteId,
        timeZoneName: (userData as any).timezonename || userData.timeZoneName,
        customerHasTruck: (userData as any).customerhastrucks || userData.customerHasTruck,
        isthirdpartyuser: (userData as any).isthirdpartyuser || userData.isthirdpartyuser,
      })

      // Store token
      authStore.setToken(userData.access_token)

      // Store login time for expiry calculation
      authStore.setLoginTime(new Date().toISOString())

      // Save to storage
      authStore.saveToStorage()

      // Save credentials for auto-login if remember me is checked
      if (rememberMe) {
        await secureStorageService.saveCredentials(username, password)
      }

      uiStore.showToast(`Welcome back, ${(userData as any).firstname || userData.firstName}!`, 'success')

      // Navigate to dashboard
      await router.push('/home/dashboard')

      return true
    } catch (err: any) {
      const errorMessage = err.response?.data?.error?.message || err.message || 'Login failed'
      error.value = errorMessage
      uiStore.showToast(errorMessage, 'error')
      return false
    } finally {
      isLoading.value = false
    }
  }

  /**
   * Logout
   */
  async function logout(): Promise<void> {
    try {
      isLoading.value = true

      // Call API to invalidate token on backend
      await authAPIService.logout()
    } catch (err) {
      console.warn('Logout API failed, clearing local session anyway', err)
    } finally {
      // Clear storage
      authStore.clearStorage()
      await secureStorageService.clearCredentials()

      uiStore.showToast('Logged out successfully', 'info')

      // Navigate to login
      await router.push('/login')

      isLoading.value = false
    }
  }

  /**
   * Auto-login using saved credentials
   */
  async function autoLogin(): Promise<boolean> {
    try {
      const credentials = await secureStorageService.getCredentials()

      if (!credentials) {
        return false
      }

      console.log('Auto-login with saved credentials')
      return await login(credentials.username, credentials.password, true)
    } catch (err) {
      console.error('Auto-login failed:', err)
      return false
    }
  }

  /**
   * Check if token is expired
   */
  function checkTokenExpiry(): boolean {
    return authStore.checkTokenExpiry()
  }

  /**
   * Verify token with backend
   */
  async function verifyToken(): Promise<boolean> {
    try {
      return await authAPIService.verifyToken()
    } catch (err) {
      return false
    }
  }

  return {
    // State
    isLoading,
    error,

    // Computed
    isAuthenticated,
    user,

    // Methods
    login,
    logout,
    autoLogin,
    checkTokenExpiry,
    verifyToken,
  }
}
