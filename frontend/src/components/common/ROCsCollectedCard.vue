<template>
  <div class="bg-white rounded-lg shadow-md p-6">
    <!-- Header -->
    <div class="flex items-center justify-between mb-4">
      <h3 class="text-lg font-semibold text-gray-900">ROCs Collected</h3>
      <div class="bg-blue-100 text-blue-600 p-2 rounded-lg">
        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
        </svg>
      </div>
    </div>

    <!-- Count Display -->
    <div class="mb-2">
      <div class="text-4xl font-bold text-blue-600 mb-1">
        {{ count }}
      </div>
      <div class="text-sm text-gray-600">
        {{ count === 1 ? 'Container' : 'Containers' }}
      </div>
    </div>

    <!-- Additional Info -->
    <div v-if="fromCollections !== undefined" class="text-xs text-gray-500 mt-3 pt-3 border-t border-gray-200">
      From {{ fromCollections }} {{ fromCollections === 1 ? 'collection' : 'collections' }}
    </div>
  </div>
</template>

<script setup lang="ts">
interface Props {
  count: number
  fromCollections?: number
}

withDefaults(defineProps<Props>(), {
  fromCollections: undefined
})
</script>

<style scoped>
/* Additional custom styles if needed */
</style>
