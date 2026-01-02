<template>
  <div
    class="bg-white rounded-lg shadow-md p-4 mb-3 cursor-pointer hover:shadow-lg transition-shadow border-2"
    :class="isSelected ? 'border-primary' : 'border-transparent'"
    @click="$emit('select', store)"
  >
    <div class="flex items-start justify-between">
      <!-- Store Logo -->
      <div class="flex-shrink-0 mr-3">
        <img
          src="/assets/mcd_logo.png"
          alt="McDonald's"
          class="w-12 h-12 rounded-full object-contain bg-yellow-50 p-1"
        />
      </div>

      <div class="flex-1">
        <div class="flex items-center gap-2 mb-1">
          <h3 class="text-lg font-semibold text-gray-900">
            {{ store.storeCode || store.storeNo }}
          </h3>
          <span
            v-if="isSelected"
            class="px-2 py-0.5 text-xs font-medium bg-green-100 text-green-800 rounded"
          >
            Selected
          </span>
        </div>

        <p v-if="store.storeName" class="text-base font-medium text-gray-700 mb-2">
          {{ store.storeName }}
        </p>

        <div class="space-y-1">
          <div v-if="store.address" class="flex items-start gap-1 text-sm text-gray-600">
            <svg class="w-4 h-4 mt-0.5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
            </svg>
            <span>{{ store.address }}</span>
          </div>

          <div v-if="store.city || store.suburb" class="flex items-center gap-1 text-sm text-gray-600 ml-5">
            <span>{{ store.city || store.suburb }}</span>
            <span v-if="store.state">, {{ store.state }}</span>
            <span v-if="store.postcode || store.postCode"> {{ store.postcode || store.postCode }}</span>
          </div>

          <div v-if="store.contactPhone" class="flex items-center gap-1 text-sm text-gray-600">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
            </svg>
            <span>{{ store.contactPhone }}</span>
          </div>
        </div>
      </div>

      <div class="ml-4">
        <svg class="w-6 h-6 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
        </svg>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { StoreModel } from '@/types/models'

interface Props {
  store: StoreModel
  isSelected?: boolean
}

withDefaults(defineProps<Props>(), {
  isSelected: false
})

defineEmits<{
  select: [store: StoreModel]
}>()
</script>
