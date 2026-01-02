import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { NFUserModel } from '@/types/models'
import { STORAGE_KEYS } from '@/utils/constants'

export const useAuthStore = defineStore('auth', () => {
  // State
  const user = ref<NFUserModel | null>(null)
  const token = ref<string | null>(null)
  const loginTime = ref<string | null>(null)
  const environment = ref<'test' | 'production'>('test')

  // Getters
  const isAuthenticated = computed(() => !!token.value && !!user.value)
  const isMcDUser = computed(() => user.value?.isMcDUser === 'True')
  const isThirdPartyUser = computed(() => user.value?.isthirdpartyuser === 'True')
  const fullName = computed(() =>
    user.value ? `${user.value.firstName} ${user.value.lastName}` : ''
  )

  // Actions
  function setUser(userData: NFUserModel) {
    user.value = userData
  }

  function setToken(tokenValue: string) {
    token.value = tokenValue
    localStorage.setItem(STORAGE_KEYS.TOKEN, tokenValue)
  }

  function setLoginTime(time: string) {
    loginTime.value = time
    localStorage.setItem(STORAGE_KEYS.LOGIN_TIME, time)
  }

  function setEnvironment(env: 'test' | 'production') {
    environment.value = env
    localStorage.setItem(STORAGE_KEYS.ENVIRONMENT, env)
  }

  async function loadFromStorage() {
    const storedToken = localStorage.getItem(STORAGE_KEYS.TOKEN)
    const storedUser = localStorage.getItem(STORAGE_KEYS.USER)
    const storedLoginTime = localStorage.getItem(STORAGE_KEYS.LOGIN_TIME)
    const storedEnv = localStorage.getItem(STORAGE_KEYS.ENVIRONMENT)

    if (storedToken) token.value = storedToken
    if (storedUser) user.value = JSON.parse(storedUser)
    if (storedLoginTime) loginTime.value = storedLoginTime
    if (storedEnv) environment.value = storedEnv as 'test' | 'production'
  }

  function saveToStorage() {
    if (user.value) {
      localStorage.setItem(STORAGE_KEYS.USER, JSON.stringify(user.value))
    }
    if (token.value) {
      localStorage.setItem(STORAGE_KEYS.TOKEN, token.value)
    }
    if (loginTime.value) {
      localStorage.setItem(STORAGE_KEYS.LOGIN_TIME, loginTime.value)
    }
    localStorage.setItem(STORAGE_KEYS.ENVIRONMENT, environment.value)
  }

  function clearStorage() {
    localStorage.removeItem(STORAGE_KEYS.TOKEN)
    localStorage.removeItem(STORAGE_KEYS.USER)
    localStorage.removeItem(STORAGE_KEYS.LOGIN_TIME)
    localStorage.removeItem(STORAGE_KEYS.CREDENTIALS)
    localStorage.removeItem(STORAGE_KEYS.SELECTED_TRUCK)

    user.value = null
    token.value = null
    loginTime.value = null
  }

  function checkTokenExpiry(): boolean {
    if (!loginTime.value || !user.value) return false

    const loginTimestamp = new Date(loginTime.value).getTime()
    const expiresIn = user.value.expiresIn * 1000 // Convert to milliseconds
    const currentTime = Date.now()

    return currentTime < loginTimestamp + expiresIn
  }

  async function logout() {
    // Call backend logout endpoint if token exists
    if (token.value) {
      try {
        // Import here to avoid circular dependency
        const { authAPIService } = await import('@/services/api/auth.service')
        await authAPIService.logout()
      } catch (error) {
        console.error('Logout API call failed:', error)
        // Continue with local logout even if API call fails
      }
    }

    // Clear all local storage and state
    clearStorage()
  }

  return {
    // State
    user,
    token,
    loginTime,
    environment,

    // Getters
    isAuthenticated,
    isMcDUser,
    isThirdPartyUser,
    fullName,

    // Actions
    setUser,
    setToken,
    setLoginTime,
    setEnvironment,
    loadFromStorage,
    saveToStorage,
    clearStorage,
    checkTokenExpiry,
    logout,
  }
})
