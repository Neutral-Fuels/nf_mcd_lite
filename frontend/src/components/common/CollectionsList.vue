<template>
  <div class="bg-white rounded-lg shadow-md overflow-hidden">
    <!-- Header -->
    <div class="bg-gray-50 px-6 py-4 border-b border-gray-200">
      <h3 class="text-lg font-semibold text-gray-900">Pending Collections</h3>
      <p class="text-sm text-gray-600 mt-1">{{ collections.length }} {{ collections.length === 1 ? 'collection' : 'collections' }} pending</p>
    </div>

    <!-- Empty State -->
    <div v-if="collections.length === 0" class="px-6 py-12 text-center">
      <svg class="w-16 h-16 text-gray-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
              d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
      </svg>
      <p class="text-gray-500 text-sm">No pending collections</p>
    </div>

    <!-- Collections List -->
    <div v-else class="divide-y divide-gray-200">
      <div
        v-for="collection in collections"
        :key="collection.ucocollectionid"
        class="px-6 py-4 hover:bg-gray-50 transition-colors cursor-pointer"
        @click="$emit('select', collection)"
      >
        <!-- Store Name & Date -->
        <div class="flex items-start justify-between mb-2">
          <div class="flex-1">
            <h4 class="text-base font-semibold text-gray-900 mb-1">
              {{ collection.storename }}
            </h4>
            <p class="text-xs text-gray-500">
              Store ID: {{ collection.storeid }}
            </p>
          </div>
          <div class="text-right ml-4">
            <div class="text-xs text-gray-500">
              {{ formatDate(collection.collectiondate) }}
            </div>
          </div>
        </div>

        <!-- Collection Stats -->
        <div class="grid grid-cols-3 gap-3 mt-3">
          <div class="bg-primary-light rounded-lg px-3 py-2">
            <div class="text-xs text-gray-600 mb-1">Quantity</div>
            <div class="text-sm font-semibold text-primary">
              {{ formatQuantity(collection.quantity) }} L
            </div>
          </div>
          <div class="bg-blue-50 rounded-lg px-3 py-2">
            <div class="text-xs text-gray-600 mb-1">ROCs</div>
            <div class="text-sm font-semibold text-blue-600">
              {{ collection.roccount }}
            </div>
          </div>
          <div class="bg-gray-100 rounded-lg px-3 py-2">
            <div class="text-xs text-gray-600 mb-1">Truck</div>
            <div class="text-sm font-semibold text-gray-700 truncate">
              {{ collection.truckrego }}
            </div>
          </div>
        </div>

        <!-- Supervisor -->
        <div v-if="collection.supervisorname" class="mt-3 flex items-center text-xs text-gray-600">
          <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                  d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
          </svg>
          <span>Supervisor: {{ collection.supervisorname }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { PendingCollection } from '@/types/models'

interface Props {
  collections: PendingCollection[]
}

defineProps<Props>()

defineEmits<{
  select: [collection: PendingCollection]
}>()

function formatDate(dateString: string): string {
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', { 
    month: 'short', 
    day: 'numeric', 
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

function formatQuantity(quantity: number): string {
  return quantity.toLocaleString('en-US', { 
    minimumFractionDigits: 0,
    maximumFractionDigits: 2 
  })
}
</script>

<style scoped>
/* Additional custom styles if needed */
</style>
