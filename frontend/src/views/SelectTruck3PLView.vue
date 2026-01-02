<template>
  <div class="min-h-screen bg-gray-50 pb-20">
    <!-- Header -->
    <div class="bg-white shadow-sm sticky top-0 z-10">
      <div class="px-4 py-4">
        <div class="flex items-center justify-between mb-4">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Select 3PL Truck</h1>
            <p class="text-sm text-gray-500 mt-1">Third-party logistics trucks</p>
          </div>
          <button
            @click="router.back()"
            class="text-gray-600 hover:text-gray-900"
          >
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <!-- Search Bar -->
        <div class="relative">
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Search by registration, supplier, or description..."
            class="w-full px-4 py-2 pl-10 pr-4 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
          />
          <svg class="absolute left-3 top-2.5 w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
          </svg>
        </div>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="flex justify-center items-center py-20">
      <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="px-4 py-8">
      <div class="bg-red-50 border border-red-200 rounded-lg p-4">
        <div class="flex items-start gap-3">
          <svg class="w-6 h-6 text-red-600 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <div>
            <h3 class="text-sm font-medium text-red-800">Error loading 3PL trucks</h3>
            <p class="text-sm text-red-700 mt-1">{{ error }}</p>
            <button
              @click="fetchThirdPartyTrucks()"
              class="mt-3 text-sm font-medium text-red-600 hover:text-red-500"
            >
              Try again
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Trucks List -->
    <div v-else class="px-4 py-4">
      <!-- Empty State -->
      <div v-if="filteredThirdPartyTrucks.length === 0" class="text-center py-12">
        <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
        </svg>
        <h3 class="mt-2 text-sm font-medium text-gray-900">No 3PL trucks found</h3>
        <p class="mt-1 text-sm text-gray-500">
          {{ searchQuery ? 'Try adjusting your search' : 'No third-party trucks available for your account' }}
        </p>
      </div>

      <!-- Truck Cards -->
      <div v-else class="space-y-3">
        <p class="text-sm text-gray-500 mb-3">
          {{ filteredThirdPartyTrucks.length }} 3PL truck{{ filteredThirdPartyTrucks.length !== 1 ? 's' : '' }} available
        </p>
        <TruckCard
          v-for="truck in filteredThirdPartyTrucks"
          :key="truck.id"
          :truck="truck"
          :is-selected="uiStore.selectedTruck?.id === truck.id"
          @select="selectTruck(truck)"
        />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useTruck } from '@/composables/useTruck'
import { useUIStore } from '@/stores/ui'
import TruckCard from '@/components/common/TruckCard.vue'

const router = useRouter()
const uiStore = useUIStore()

const {
  loading,
  error,
  searchQuery,
  filteredThirdPartyTrucks,
  fetchThirdPartyTrucks,
  selectTruck,
} = useTruck()

onMounted(async () => {
  await fetchThirdPartyTrucks()
})
</script>
