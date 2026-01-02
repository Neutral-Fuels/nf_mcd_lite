<template>
  <div class="bg-white rounded-lg shadow-md p-6">
    <!-- Header -->
    <div class="flex items-center justify-between mb-4">
      <h3 class="text-lg font-semibold text-gray-900">Pending Collections</h3>
      <div class="bg-green-100 text-green-600 p-2 rounded-lg">
        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
        </svg>
      </div>
    </div>

    <!-- Count Display -->
    <div class="mb-2">
      <div class="text-4xl font-bold text-green-600 mb-1">
        {{ count }}
      </div>
      <div class="text-sm text-gray-600">
        {{ count === 1 ? 'Collection' : 'Collections' }}
      </div>
    </div>

    <!-- Subtitle -->
    <div class="text-xs text-gray-500 mt-3 pt-3 border-t border-gray-200">
      Awaiting completion
    </div>
  </div>
</template>

<script setup lang="ts">
interface Props {
  count: number
}

defineProps<Props>()
</script>

<style scoped>
/* Additional custom styles if needed */
</style>
