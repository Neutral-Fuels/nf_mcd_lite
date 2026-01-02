<template>
  <nav class="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 shadow-lg z-40 safe-area-bottom">
    <div class="flex items-center justify-around h-16 max-w-screen-xl mx-auto">
      <!-- Home Button -->
      <router-link
        to="/home/dashboard"
        class="flex flex-col items-center justify-center flex-1 h-full transition-colors"
        :class="isActive('/home/dashboard') ? 'text-primary' : 'text-gray-600 hover:text-gray-900'"
      >
        <svg class="w-6 h-6 mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"
          />
        </svg>
        <span class="text-xs font-medium">Home</span>
      </router-link>

      <!-- Collect Button -->
      <button
        @click="handleCollect"
        class="flex flex-col items-center justify-center flex-1 h-full transition-colors"
        :class="isActive('/home/collect') ? 'text-primary' : 'text-gray-600 hover:text-gray-900'"
      >
        <svg class="w-6 h-6 mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4"
          />
        </svg>
        <span class="text-xs font-medium">Collect</span>
      </button>

      <!-- Deliver Button -->
      <button
        @click="handleDeliver"
        class="flex flex-col items-center justify-center flex-1 h-full transition-colors"
        :class="isActive('/home/deliver') ? 'text-primary' : 'text-gray-600 hover:text-gray-900'"
      >
        <svg class="w-6 h-6 mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M13 16V6a1 1 0 00-1-1H4a1 1 0 00-1 1v10a1 1 0 001 1h1m8-1a1 1 0 01-1 1H9m4-1V8a1 1 0 011-1h2.586a1 1 0 01.707.293l3.414 3.414a1 1 0 01.293.707V16a1 1 0 01-1 1h-1m-6-1a1 1 0 001 1h1M5 17a2 2 0 104 0m-4 0a2 2 0 114 0m6 0a2 2 0 104 0m-4 0a2 2 0 114 0"
          />
        </svg>
        <span class="text-xs font-medium">Deliver</span>
      </button>
    </div>
  </nav>
</template>

<script setup lang="ts">
import { useRoute, useRouter } from 'vue-router'
import { useUIStore } from '@/stores/ui'
import { useCollectionStore } from '@/stores/collection'

const route = useRoute()
const router = useRouter()
const uiStore = useUIStore()
const collectionStore = useCollectionStore()

function isActive(path: string): boolean {
  return route.path === path || route.path.startsWith(path + '/')
}

function handleCollect() {
  // Check if truck is selected
  if (!uiStore.selectedTruck) {
    uiStore.showToast('Please select a truck first', 'warning')
    router.push('/select-truck')
    return
  }

  // Clear any previous collection data when starting new collection
  collectionStore.clearCollection()

  // Navigate to collect view
  router.push('/home/collect')
}

function handleDeliver() {
  // Check if truck is selected
  if (!uiStore.selectedTruck) {
    uiStore.showToast('Please select a truck first', 'warning')
    router.push('/select-truck')
    return
  }

  // Navigate to deliver view
  router.push('/home/deliver')
}
</script>

<style scoped>
/* Safe area for iOS devices with notch */
.safe-area-bottom {
  padding-bottom: env(safe-area-inset-bottom);
}

/* Active state animation */
.router-link-active {
  position: relative;
}

.router-link-active::before {
  content: '';
  position: absolute;
  top: 0;
  left: 50%;
  transform: translateX(-50%);
  width: 40px;
  height: 3px;
  background-color: currentColor;
  border-radius: 0 0 3px 3px;
}
</style>
