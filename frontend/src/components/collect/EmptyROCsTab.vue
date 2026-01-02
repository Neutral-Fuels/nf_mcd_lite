<template>
  <div class="space-y-4">
    <!-- Input Section -->
    <div class="space-y-2">
      <label class="block text-sm font-medium text-gray-700">
        Empty ROC Number
      </label>
      <div class="flex gap-2">
        <input
          v-model="rocNumber"
          type="text"
          inputmode="numeric"
          pattern="\d{1,4}"
          maxlength="4"
          placeholder="Enter ROC number (max 4 digits)"
          @keyup.enter="handleAdd"
          class="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
          :class="{ 'border-red-500': error }"
        />
        <button
          @click="handleAdd"
          :disabled="!rocNumber"
          class="px-6 py-2 bg-primary text-white rounded-lg hover:bg-blue-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed font-medium"
        >
          Add
        </button>
      </div>
      <p v-if="error" class="text-xs text-red-600">{{ error }}</p>
      <p class="text-xs text-gray-500">
        Enter the ROC number from the empty container being delivered to the store
      </p>
    </div>

    <!-- List Section -->
    <div v-if="collectionStore.emptyROCs.length > 0" class="space-y-2">
      <div class="flex items-center justify-between">
        <h4 class="text-sm font-medium text-gray-700">
          Empty ROCs ({{ collectionStore.emptyROCs.length }})
        </h4>
        <button
          v-if="collectionStore.emptyROCs.length > 0"
          @click="handleClearAll"
          class="text-xs text-red-600 hover:text-red-700"
        >
          Clear All
        </button>
      </div>

      <div class="space-y-2 max-h-64 overflow-y-auto">
        <div
          v-for="(roc, index) in collectionStore.emptyROCs"
          :key="roc.rocNumber"
          class="flex items-center justify-between p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors"
        >
          <div class="flex items-center gap-3">
            <div class="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
              <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                      d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
              </svg>
            </div>
            <div>
              <div class="font-medium text-gray-900">ROC #{{ roc.rocNumber }}</div>
              <div class="text-xs text-gray-500">Empty Container</div>
            </div>
          </div>
          <button
            @click="handleRemove(index)"
            class="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
            aria-label="Remove"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                    d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
            </svg>
          </button>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else class="text-center py-8">
      <svg class="w-16 h-16 text-gray-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
      </svg>
      <p class="text-gray-500">No empty ROCs added yet</p>
      <p class="text-xs text-gray-400 mt-1">Add ROC numbers for empty containers delivered to the store</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useCollectionStore } from '@/stores/collection'
import { useUIStore } from '@/stores/ui'

const collectionStore = useCollectionStore()
const uiStore = useUIStore()

const rocNumber = ref('')
const error = ref('')

function handleAdd() {
  error.value = ''

  if (!rocNumber.value) {
    error.value = 'Please enter a ROC number'
    return
  }

  if (!collectionStore.isValidROCNumber(rocNumber.value)) {
    error.value = 'ROC number must be 1-4 digits'
    return
  }

  if (collectionStore.checkDuplicateROC(rocNumber.value)) {
    error.value = 'This ROC number is already added'
    return
  }

  try {
    collectionStore.addEmptyROC({ rocNumber: rocNumber.value })
    uiStore.showToast(`Empty ROC #${rocNumber.value} added`, 'success')
    rocNumber.value = ''
  } catch (err: any) {
    error.value = err.message || 'Failed to add ROC'
  }
}

function handleRemove(index: number) {
  const roc = collectionStore.emptyROCs[index]
  collectionStore.removeEmptyROC(index)
  uiStore.showToast(`ROC #${roc.rocNumber} removed`, 'info')
}

function handleClearAll() {
  if (confirm(`Remove all ${collectionStore.emptyROCs.length} empty ROCs?`)) {
    while (collectionStore.emptyROCs.length > 0) {
      collectionStore.removeEmptyROC(0)
    }
    uiStore.showToast('All empty ROCs cleared', 'info')
  }
}
</script>
