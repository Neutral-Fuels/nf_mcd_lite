import localforage from 'localforage'

// Configure IndexedDB storage
const secureStorage = localforage.createInstance({
  name: 'mcd-uco-secure',
  storeName: 'credentials',
  description: 'Secure storage for encrypted credentials',
})

export interface EncryptedCredentials {
  username: string
  password: string  // This should be encrypted in production
  timestamp: number
}

class SecureStorageService {
  /**
   * Save credentials for auto-login
   * NOTE: In production, password should be encrypted using Web Crypto API
   */
  async saveCredentials(username: string, password: string): Promise<void> {
    const credentials: EncryptedCredentials = {
      username,
      password, // TODO: Encrypt in production
      timestamp: Date.now(),
    }

    await secureStorage.setItem('user_credentials', credentials)
  }

  /**
   * Get saved credentials for auto-login
   */
  async getCredentials(): Promise<EncryptedCredentials | null> {
    try {
      const credentials = await secureStorage.getItem<EncryptedCredentials>('user_credentials')

      if (!credentials) return null

      // Check if credentials are older than 30 days
      const thirtyDaysInMs = 30 * 24 * 60 * 60 * 1000
      if (Date.now() - credentials.timestamp > thirtyDaysInMs) {
        await this.clearCredentials()
        return null
      }

      return credentials
    } catch (error) {
      console.error('Failed to get credentials:', error)
      return null
    }
  }

  /**
   * Clear saved credentials
   */
  async clearCredentials(): Promise<void> {
    await secureStorage.removeItem('user_credentials')
  }

  /**
   * Clear all secure storage
   */
  async clearAll(): Promise<void> {
    await secureStorage.clear()
  }
}

export const secureStorageService = new SecureStorageService()
