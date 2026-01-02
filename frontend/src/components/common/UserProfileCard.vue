<template>
  <div class="bg-white rounded-lg shadow-md p-6 mb-4">
    <!-- User Name and Info -->
    <div class="flex items-start justify-between mb-4">
      <div class="flex-1">
        <h2 class="text-2xl font-bold text-gray-900 mb-1">
          {{ fullName }}
        </h2>
        <p class="text-sm text-gray-600">{{ user.username }}</p>
      </div>
      
      <!-- License Badge -->
      <div v-if="user.licenseNo" class="ml-4">
        <div class="bg-primary-light text-primary px-3 py-1 rounded-lg text-xs font-medium">
          License: {{ user.licenseNo }}
        </div>
      </div>
    </div>

    <!-- User Details Grid -->
    <div class="grid grid-cols-1 gap-3 text-sm">
      <!-- Email -->
      <div v-if="user.email" class="flex items-center">
        <svg class="w-4 h-4 text-gray-400 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
        </svg>
        <span class="text-gray-700">{{ user.email }}</span>
      </div>

      <!-- Customer Name -->
      <div v-if="user.customerName" class="flex items-center">
        <svg class="w-4 h-4 text-gray-400 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
        </svg>
        <span class="text-gray-700">{{ user.customerName }}</span>
      </div>

      <!-- Time Zone -->
      <div v-if="user.timeZoneName" class="flex items-center">
        <svg class="w-4 h-4 text-gray-400 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        <span class="text-gray-700">{{ user.timeZoneName }}</span>
      </div>
    </div>

    <!-- User Type Badges -->
    <div class="flex flex-wrap gap-2 mt-4">
      <span v-if="user.isMcDUser === 'True'" 
            class="px-3 py-1 text-xs font-medium bg-yellow-100 text-yellow-800 rounded-full">
        McDonald's User
      </span>
      <span v-if="user.isthirdpartyuser === 'True'" 
            class="px-3 py-1 text-xs font-medium bg-blue-100 text-blue-800 rounded-full">
        3PL User
      </span>
      <span v-if="user.customerHasTruck === 'True'" 
            class="px-3 py-1 text-xs font-medium bg-green-100 text-green-800 rounded-full">
        Has Truck
      </span>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import type { NFUserModel } from '@/types/models'

interface Props {
  user: NFUserModel
}

const props = defineProps<Props>()

const fullName = computed(() => {
  return `${props.user.firstName} ${props.user.lastName}`.trim()
})
</script>

<style scoped>
/* Additional custom styles if needed */
</style>
