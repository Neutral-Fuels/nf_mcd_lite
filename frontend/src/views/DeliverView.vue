<template>
  <div class="min-h-screen bg-gray-50 pb-20">
    <!-- Header -->
    <div class="bg-white shadow-sm sticky top-0 z-10 px-4 py-4 border-b border-gray-200">
      <div class="flex items-center justify-between">
        <div class="flex items-center gap-3">
          <img src="/assets/180.png" alt="NF" class="w-10 h-10 object-contain" />
          <h1 class="text-2xl font-bold text-gray-900">New Delivery</h1>
        </div>
        <button
          v-if="deliveryStore.selectedDeliveryType"
          @click="handleBack"
          class="p-2 rounded-lg hover:bg-gray-100 transition-colors"
          aria-label="Back"
        >
          <svg class="w-6 h-6 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>

      <!-- Truck Info -->
      <div v-if="selectedTruck" class="mt-3 flex items-center text-sm text-gray-600">
        <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M13 16V6a1 1 0 00-1-1H4a1 1 0 00-1 1v10a1 1 0 001 1h1m8-1a1 1 0 01-1 1H9m4-1V8a1 1 0 011-1h2.586a1 1 0 01.707.293l3.414 3.414a1 1 0 01.293.707V16a1 1 0 01-1 1h-1m-6-1a1 1 0 001 1h1M5 17a2 2 0 104 0m-4 0a2 2 0 114 0m6 0a2 2 0 104 0m-4 0a2 2 0 114 0" />
        </svg>
        <span class="font-medium">{{ selectedTruck.regno }}</span>
      </div>
    </div>

    <!-- Main Content -->
    <div class="px-4 py-6">
      <!-- Delivery Type Selection -->
      <div v-if="!deliveryStore.selectedDeliveryType" class="space-y-3">
        <h2 class="text-lg font-semibold text-gray-900 mb-4">Select Delivery Type</h2>

        <!-- From Stores -->
        <button
          @click="selectDeliveryType(DELIVERY_TYPES.FROM_STORES)"
          class="w-full bg-white rounded-lg shadow-md p-4 hover:shadow-lg transition-shadow text-left border-2 border-transparent hover:border-primary"
        >
          <div class="flex items-center">
            <div class="bg-green-100 p-3 rounded-lg mr-4">
              <svg class="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                      d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
              </svg>
            </div>
            <div class="flex-1">
              <h3 class="font-semibold text-gray-900">From Stores</h3>
              <p class="text-sm text-gray-600">Deliver collections from this truck</p>
            </div>
            <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
            </svg>
          </div>
        </button>

        <!-- Bulk Delivery -->
        <button
          @click="selectDeliveryType(DELIVERY_TYPES.BULK_DELIVERY)"
          class="w-full bg-white rounded-lg shadow-md p-4 hover:shadow-lg transition-shadow text-left border-2 border-transparent hover:border-primary"
        >
          <div class="flex items-center">
            <div class="bg-purple-100 p-3 rounded-lg mr-4">
              <svg class="w-6 h-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                      d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
              </svg>
            </div>
            <div class="flex-1">
              <h3 class="font-semibold text-gray-900">Bulk Delivery</h3>
              <p class="text-sm text-gray-600">Large-scale multi-store delivery</p>
            </div>
            <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
            </svg>
          </div>
        </button>

        <!-- Collect Empty ROCs -->
        <button
          @click="selectDeliveryType(DELIVERY_TYPES.COLLECT_EMPTY_ROCS)"
          class="w-full bg-white rounded-lg shadow-md p-4 hover:shadow-lg transition-shadow text-left border-2 border-transparent hover:border-primary"
        >
          <div class="flex items-center">
            <div class="bg-yellow-100 p-3 rounded-lg mr-4">
              <svg class="w-6 h-6 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                      d="M5 8h14M5 8a2 2 0 110-4h14a2 2 0 110 4M5 8v10a2 2 0 002 2h10a2 2 0 002-2V8m-9 4h4" />
              </svg>
            </div>
            <div class="flex-1">
              <h3 class="font-semibold text-gray-900">Collect Empty ROCs</h3>
              <p class="text-sm text-gray-600">Pick up empty containers</p>
            </div>
            <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
            </svg>
          </div>
        </button>
      </div>

      <!-- Delivery Type Components -->
      <FromStores v-else-if="deliveryStore.isFromStores" />
      <BulkDelivery v-else-if="deliveryStore.isBulkDelivery" />
      <CollectEmptyROCs v-else-if="deliveryStore.isCollectEmptyROCs" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useDeliveryStore } from '@/stores/delivery'
import { useUIStore } from '@/stores/ui'
import { DELIVERY_TYPES } from '@/utils/constants'
import FromStores from '@/components/deliver/FromStores.vue'
import BulkDelivery from '@/components/deliver/BulkDelivery.vue'
import CollectEmptyROCs from '@/components/deliver/CollectEmptyROCs.vue'

const deliveryStore = useDeliveryStore()
const uiStore = useUIStore()

const selectedTruck = computed(() => uiStore.selectedTruck)

function selectDeliveryType(type: string) {
  deliveryStore.setDeliveryType(type)
}

function handleBack() {
  deliveryStore.clearDelivery()
}
</script>
