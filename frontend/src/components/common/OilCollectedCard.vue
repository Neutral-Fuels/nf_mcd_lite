<template>
  <div class="bg-white rounded-lg shadow-md p-6 mb-4">
    <!-- Header -->
    <div class="flex items-center justify-between mb-4">
      <h3 class="text-lg font-semibold text-gray-900">Oil Collected</h3>
      <div class="bg-primary-light text-primary p-2 rounded-lg">
        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
        </svg>
      </div>
    </div>

    <!-- Total Value -->
    <div class="mb-4">
      <div class="text-4xl font-bold text-primary mb-1">
        {{ formattedTotal }}
      </div>
      <div class="text-sm text-gray-600">
        Liters collected
      </div>
    </div>

    <!-- Progress Bar (if target is provided) -->
    <div v-if="target && target > 0" class="mb-3">
      <div class="flex justify-between text-sm text-gray-600 mb-2">
        <span>Progress</span>
        <span>{{ percentage }}%</span>
      </div>
      <div class="w-full bg-gray-200 rounded-full h-3">
        <div 
          class="h-3 rounded-full transition-all duration-500 ease-out"
          :class="progressColorClass"
          :style="{ width: `${Math.min(percentage, 100)}%` }"
        />
      </div>
      <div class="text-xs text-gray-500 mt-2 text-right">
        Target: {{ formattedTarget }} L
      </div>
    </div>

    <!-- Additional Info -->
    <div v-if="collectionCount !== undefined" class="text-sm text-gray-600 mt-3 pt-3 border-t border-gray-200">
      From {{ collectionCount }} {{ collectionCount === 1 ? 'collection' : 'collections' }}
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

interface Props {
  total: number
  target?: number
  collectionCount?: number
}

const props = withDefaults(defineProps<Props>(), {
  target: 0,
  collectionCount: undefined
})

const formattedTotal = computed(() => {
  return props.total.toLocaleString('en-US', { 
    minimumFractionDigits: 0,
    maximumFractionDigits: 2 
  })
})

const formattedTarget = computed(() => {
  return props.target.toLocaleString('en-US', { 
    minimumFractionDigits: 0,
    maximumFractionDigits: 0 
  })
})

const percentage = computed(() => {
  if (!props.target || props.target === 0) return 0
  return Math.round((props.total / props.target) * 100)
})

const progressColorClass = computed(() => {
  const pct = percentage.value
  if (pct >= 100) return 'bg-green-500'
  if (pct >= 75) return 'bg-primary'
  if (pct >= 50) return 'bg-yellow-500'
  return 'bg-red-500'
})
</script>

<style scoped>
/* Additional custom styles if needed */
</style>
