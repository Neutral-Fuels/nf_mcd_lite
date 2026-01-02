<template>
  <div class="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary to-secondary p-4">
    <div class="card w-full max-w-md p-8 shadow-2xl">
      <!-- Logo and Title -->
      <div class="text-center mb-8">
        <img
          src="/assets/mcd_logo.png"
          alt="McDonald's UCO Collection"
          class="w-24 h-24 mx-auto mb-4 object-contain"
        />
        <h1 class="text-3xl font-bold text-primary mb-2">McDonald's</h1>
        <h2 class="text-xl font-semibold text-gray-700">UCO Collection</h2>
        <p class="text-sm text-gray-500 mt-2">Neutral Fuels Driver Portal</p>
      </div>

      <!-- Environment Indicator -->
      <div class="mb-6 text-center">
        <span
          :class="[
            'inline-block px-4 py-1 rounded-full text-xs font-semibold',
            authStore.environment === 'test'
              ? 'bg-red-100 text-red-700'
              : 'bg-green-100 text-green-700'
          ]"
        >
          {{ authStore.environment === 'test' ? 'TEST ENVIRONMENT' : 'PRODUCTION' }}
        </span>
      </div>

      <!-- Error Alert -->
      <div v-if="error" class="mb-4 p-4 bg-red-50 border border-red-200 rounded-lg">
        <p class="text-sm text-red-700">{{ error }}</p>
      </div>

      <!-- Login Form -->
      <form @submit.prevent="handleLogin" class="space-y-6">
        <!-- Username -->
        <div>
          <label for="username" class="block text-sm font-medium text-gray-700 mb-2">
            Username
          </label>
          <input
            id="username"
            v-model="username"
            type="text"
            autocomplete="username"
            required
            class="input-field"
            :disabled="isLoading"
            placeholder="Enter your username"
          />
        </div>

        <!-- Password -->
        <div>
          <label for="password" class="block text-sm font-medium text-gray-700 mb-2">
            Password
          </label>
          <input
            id="password"
            v-model="password"
            type="password"
            autocomplete="current-password"
            required
            class="input-field"
            :disabled="isLoading"
            placeholder="Enter your password"
          />
        </div>

        <!-- Remember Me -->
        <div class="flex items-center">
          <input
            id="remember"
            v-model="rememberMe"
            type="checkbox"
            class="h-4 w-4 text-primary focus:ring-primary border-gray-300 rounded"
            :disabled="isLoading"
          />
          <label for="remember" class="ml-2 block text-sm text-gray-700">
            Remember me (auto-login)
          </label>
        </div>

        <!-- Submit Button -->
        <button
          type="submit"
          class="w-full btn-primary flex items-center justify-center"
          :disabled="isLoading || !username || !password"
        >
          <svg
            v-if="isLoading"
            class="animate-spin -ml-1 mr-3 h-5 w-5 text-white"
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
          >
            <circle
              class="opacity-25"
              cx="12"
              cy="12"
              r="10"
              stroke="currentColor"
              stroke-width="4"
            ></circle>
            <path
              class="opacity-75"
              fill="currentColor"
              d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
            ></path>
          </svg>
          {{ isLoading ? 'Logging in...' : 'Login' }}
        </button>
      </form>

      <!-- Environment Toggle (Development Only) -->
      <div v-if="isDevelopment" class="mt-6 pt-6 border-t border-gray-200">
        <div class="text-center">
          <label class="text-xs text-gray-500 mb-2 block">Development Mode - Switch Environment</label>
          <div class="flex justify-center gap-2">
            <button
              @click="setEnvironment('test')"
              :class="[
                'px-4 py-2 text-xs rounded-lg font-medium transition-colors',
                authStore.environment === 'test'
                  ? 'bg-red-500 text-white'
                  : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
              ]"
            >
              Test
            </button>
            <button
              @click="setEnvironment('production')"
              :class="[
                'px-4 py-2 text-xs rounded-lg font-medium transition-colors',
                authStore.environment === 'production'
                  ? 'bg-green-500 text-white'
                  : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
              ]"
            >
              Production
            </button>
          </div>
        </div>
      </div>

      <!-- Version Info -->
      <div class="mt-6 text-center text-xs text-gray-500">
        Version {{ appVersion }}
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useAuth } from '@/composables/useAuth'
import { useAuthStore } from '@/stores/auth'

const { login, isLoading, error, autoLogin } = useAuth()
const authStore = useAuthStore()

const username = ref('')
const password = ref('')
const rememberMe = ref(false)

const appVersion = import.meta.env.VITE_APP_VERSION || '2.0.0'
const isDevelopment = import.meta.env.DEV

async function handleLogin() {
  await login(username.value, password.value, rememberMe.value)
}

function setEnvironment(env: 'test' | 'production') {
  authStore.setEnvironment(env)
}

// Try auto-login on mount if credentials are saved
onMounted(async () => {
  if (!authStore.isAuthenticated) {
    await autoLogin()
  }
})
</script>
