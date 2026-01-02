<template>
  <div class="min-h-screen bg-gray-50 pb-20">
    <!-- Header -->
    <div class="bg-white shadow-sm sticky top-0 z-10 px-4 py-4 border-b border-gray-200">
      <div class="flex items-center justify-between">
        <div class="flex items-center gap-3">
          <img src="/assets/180.png" alt="NF" class="w-10 h-10 object-contain" />
          <h1 class="text-2xl font-bold text-gray-900">Dashboard</h1>
        </div>
        <div class="flex items-center gap-2">
          <button
            @click="refreshData"
            :disabled="loading"
            class="p-2 rounded-lg hover:bg-gray-100 transition-colors disabled:opacity-50"
            aria-label="Refresh data"
          >
            <svg
              class="w-6 h-6 text-gray-600"
              :class="{ 'animate-spin': loading }"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"
              />
            </svg>
          </button>
          <button
            @click="handleLogout"
            class="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors text-sm font-medium"
          >
            Logout
          </button>
        </div>
      </div>

      <!-- Selected Truck Info -->
      <div v-if="selectedTruck" class="mt-3 flex items-center justify-between text-sm text-gray-600">
        <div class="flex items-center">
          <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                  d="M13 16V6a1 1 0 00-1-1H4a1 1 0 00-1 1v10a1 1 0 001 1h1m8-1a1 1 0 01-1 1H9m4-1V8a1 1 0 011-1h2.586a1 1 0 01.707.293l3.414 3.414a1 1 0 01.293.707V16a1 1 0 01-1 1h-1m-6-1a1 1 0 001 1h1M5 17a2 2 0 104 0m-4 0a2 2 0 114 0m6 0a2 2 0 104 0m-4 0a2 2 0 114 0" />
          </svg>
          <span class="font-medium">{{ selectedTruck.regno }}</span>
          <span v-if="selectedTruck.description && selectedTruck.description !== selectedTruck.regno" class="ml-2 text-gray-500">
            - {{ selectedTruck.description }}
          </span>
        </div>
        <button
          @click="changeTruck"
          class="text-primary hover:text-blue-700 font-medium underline"
        >
          Change Truck
        </button>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading && !dashboardStore.collections.length" class="flex justify-center items-center py-20">
      <div class="text-center">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-primary mx-auto mb-4"></div>
        <p class="text-gray-600">Loading dashboard data...</p>
      </div>
    </div>

    <!-- Error State -->
    <div v-else-if="error && !dashboardStore.collections.length" class="px-4 py-8">
      <div class="bg-red-50 border border-red-200 rounded-lg p-4 text-center">
        <svg class="w-12 h-12 text-red-400 mx-auto mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        <p class="text-red-800 font-medium">{{ error }}</p>
        <button
          @click="refreshData"
          class="mt-4 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
        >
          Retry
        </button>
      </div>
    </div>

    <!-- No Truck Selected -->
    <div v-else-if="!selectedTruck" class="px-4 py-8">
      <div class="bg-yellow-50 border border-yellow-200 rounded-lg p-6 text-center">
        <svg class="w-16 h-16 text-yellow-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M13 16V6a1 1 0 00-1-1H4a1 1 0 00-1 1v10a1 1 0 001 1h1m8-1a1 1 0 01-1 1H9m4-1V8a1 1 0 011-1h2.586a1 1 0 01.707.293l3.414 3.414a1 1 0 01.293.707V16a1 1 0 01-1 1h-1m-6-1a1 1 0 001 1h1M5 17a2 2 0 104 0m-4 0a2 2 0 114 0m6 0a2 2 0 104 0m-4 0a2 2 0 114 0" />
        </svg>
        <h3 class="text-lg font-semibold text-gray-900 mb-2">No Truck Selected</h3>
        <p class="text-gray-600 mb-4">Please select a truck to view dashboard</p>
        <button
          @click="router.push('/select-truck')"
          class="px-6 py-2 bg-primary text-white rounded-lg hover:bg-blue-600 transition-colors"
        >
          Select Truck
        </button>
      </div>
    </div>

    <!-- Dashboard Content -->
    <div v-else class="px-4 py-6 space-y-4">
      <!-- User Profile Card -->
      <UserProfileCard v-if="authStore.user" :user="authStore.user" />

      <!-- Statistics Grid -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <OilCollectedCard
          :total="dashboardStore.totalOilCollected"
          :collection-count="dashboardStore.totalCollections"
        />
        <CollectionsTodayCard :count="dashboardStore.totalCollections" />
        <ROCsCollectedCard
          :count="dashboardStore.totalROCs"
          :from-collections="dashboardStore.totalCollections"
        />
      </div>

      <!-- Collections List -->
      <CollectionsList
        :collections="dashboardStore.collectionsByDate"
        @select="handleCollectionSelect"
      />

      <!-- Last Updated -->
      <div v-if="dashboardStore.lastFetched" class="text-center text-xs text-gray-500 py-4">
        Last updated: {{ formatLastFetched(dashboardStore.lastFetched) }}
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, computed, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useUIStore } from '@/stores/ui'
import { useDashboardStore } from '@/stores/dashboard'
import UserProfileCard from '@/components/common/UserProfileCard.vue'
import OilCollectedCard from '@/components/common/OilCollectedCard.vue'
import CollectionsTodayCard from '@/components/common/CollectionsTodayCard.vue'
import ROCsCollectedCard from '@/components/common/ROCsCollectedCard.vue'
import CollectionsList from '@/components/common/CollectionsList.vue'
import type { PendingCollection } from '@/types/models'

const router = useRouter()
const authStore = useAuthStore()
const uiStore = useUIStore()
const dashboardStore = useDashboardStore()

const selectedTruck = computed(() => uiStore.selectedTruck)
const loading = computed(() => dashboardStore.loading)
const error = computed(() => dashboardStore.error)

// Watch for truck changes and refetch collections
watch(selectedTruck, async (newTruck, oldTruck) => {
  // Only fetch if truck actually changed and new truck exists
  if (newTruck && newTruck.regno !== oldTruck?.regno) {
    await dashboardStore.fetchPendingCollections(true) // Force refresh
  }
})

async function refreshData() {
  if (selectedTruck.value) {
    await dashboardStore.refreshCollections()
  }
}

async function handleLogout() {
  await authStore.logout()
  router.push('/login')
}

function changeTruck() {
  // Clear selected truck and navigate to truck selection
  uiStore.setSelectedTruck(null)
  router.push('/select-truck')
}

function handleCollectionSelect(collection: PendingCollection) {
  console.log('Collection selected:', collection)
  // Future: Navigate to collection details or start collection process
}

function formatLastFetched(date: Date): string {
  const now = new Date()
  const diff = now.getTime() - date.getTime()
  const seconds = Math.floor(diff / 1000)
  const minutes = Math.floor(seconds / 60)

  if (seconds < 60) return 'Just now'
  if (minutes < 60) return `${minutes} ${minutes === 1 ? 'minute' : 'minutes'} ago`

  return date.toLocaleTimeString('en-US', {
    hour: '2-digit',
    minute: '2-digit'
  })
}

// Fetch data on mount
onMounted(async () => {
  if (selectedTruck.value) {
    await dashboardStore.fetchPendingCollections()
  }
})
</script>

<style scoped>
/* Additional custom styles if needed */
</style>
