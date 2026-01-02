<template>
  <div
    class="bg-white rounded-lg shadow-md p-4 mb-3 cursor-pointer hover:shadow-lg transition-shadow border-2"
    :class="isSelected ? 'border-primary' : 'border-transparent'"
    @click="$emit('select', truck)"
  >
    <div class="flex items-start justify-between">
      <div class="flex-1">
        <div class="flex items-center gap-2 mb-1">
          <h3 class="text-lg font-semibold text-gray-900">
            {{ truck.regno }}
          </h3>
          <span
            v-if="isThirdParty"
            class="px-2 py-0.5 text-xs font-medium bg-blue-100 text-blue-800 rounded"
          >
            3PL
          </span>
          <span
            v-if="isSelected"
            class="px-2 py-0.5 text-xs font-medium bg-green-100 text-green-800 rounded"
          >
            Selected
          </span>
        </div>

        <p v-if="truck.description" class="text-sm text-gray-600 mb-2">
          {{ truck.description }}
        </p>

        <div v-if="isThirdParty && truck.supplierName" class="flex items-center gap-1 text-sm text-gray-500">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
          </svg>
          <span>{{ truck.supplierName }}</span>
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
import { computed } from 'vue'
import type { TruckModel, ThirdPartyTruckModel } from '@/types/models'

interface Props {
  truck: TruckModel | ThirdPartyTruckModel
  isSelected?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  isSelected: false
})

defineEmits<{
  select: [truck: TruckModel | ThirdPartyTruckModel]
}>()

const isThirdParty = computed(() => {
  return props.truck && typeof props.truck === 'object' && 'supplierName' in props.truck
})
</script>
