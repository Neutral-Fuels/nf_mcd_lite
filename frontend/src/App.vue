<template>
  <div id="app" class="min-h-screen bg-gray-50">
    <router-view />
    <Toast />
    <BottomNav v-if="showBottomNav" />
  </div>
</template>

<script setup lang="ts">
import { onMounted, computed } from 'vue'
import { useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useUIStore } from '@/stores/ui'
import Toast from '@/components/common/Toast.vue'
import BottomNav from '@/components/common/BottomNav.vue'

const route = useRoute()
const authStore = useAuthStore()
const uiStore = useUIStore()

// Show bottom nav on main app routes only (dashboard, collect, deliver)
const showBottomNav = computed(() => {
  // Show on /home/* routes (dashboard, collect, deliver)
  // Hide on login, truck selection, store selection
  const hiddenRoutes = ['/login', '/', '/select-truck', '/select-truck-3pl', '/select-new-truck', '/select-new-truck-3pl', '/select-store']
  return authStore.isAuthenticated && !hiddenRoutes.includes(route.path)
})

onMounted(async () => {
  // Load user and truck from storage on app mount
  await authStore.loadFromStorage()
  uiStore.loadSelectedTruck()
  uiStore.loadSelectedStore()

  // Listen for online/offline events
  window.addEventListener('online', () => uiStore.setOnlineStatus(true))
  window.addEventListener('offline', () => uiStore.setOnlineStatus(false))
})
</script>

<style>
#app {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
</style>
