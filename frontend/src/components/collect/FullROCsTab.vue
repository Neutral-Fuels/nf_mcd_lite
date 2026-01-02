<template>
  <div class="space-y-4">
    <!-- Input Form -->
    <div class="space-y-3 p-4 bg-gray-50 rounded-lg">
      <!-- ROC Number -->
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">
          Full ROC Number *
        </label>
        <input
          v-model="formData.rocNumber"
          type="text"
          inputmode="numeric"
          pattern="\d{1,4}"
          maxlength="4"
          placeholder="ROC number (max 4 digits)"
          class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
          :class="{ 'border-red-500': errors.rocNumber }"
        />
        <p v-if="errors.rocNumber" class="text-xs text-red-600 mt-1">{{ errors.rocNumber }}</p>
      </div>

      <!-- Quantity -->
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">
          Quantity (Litres) *
        </label>
        <input
          v-model.number="formData.quantity"
          type="number"
          inputmode="decimal"
          min="0"
          step="0.1"
          placeholder="Enter quantity in litres"
          class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
          :class="{ 'border-red-500': errors.quantity }"
        />
        <p v-if="errors.quantity" class="text-xs text-red-600 mt-1">{{ errors.quantity }}</p>
      </div>

      <!-- State -->
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">
          ROC State *
        </label>
        <select
          v-model="formData.state"
          class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
        >
          <option value="Ok">Ok - Good condition</option>
          <option value="Damaged">Damaged - Needs attention</option>
          <option value="Dirty">Dirty - Needs cleaning</option>
        </select>
      </div>

      <!-- Add Button -->
      <button
        @click="handleAdd"
        :disabled="!isFormValid"
        class="w-full py-2 bg-primary text-white rounded-lg hover:bg-blue-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed font-medium"
      >
        Add Full ROC
      </button>
    </div>

    <!-- List Section -->
    <div v-if="collectionStore.fullROCs.length > 0" class="space-y-2">
      <div class="flex items-center justify-between">
        <h4 class="text-sm font-medium text-gray-700">
          Full ROCs ({{ collectionStore.fullROCs.length }})
        </h4>
        <button
          v-if="collectionStore.fullROCs.length > 0"
          @click="handleClearAll"
          class="text-xs text-red-600 hover:text-red-700"
        >
          Clear All
        </button>
      </div>

      <div class="space-y-2 max-h-96 overflow-y-auto">
        <div
          v-for="(roc, index) in collectionStore.fullROCs"
          :key="roc.rocNumber"
          class="p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors"
        >
          <div class="flex items-start justify-between">
            <div class="flex-1">
              <div class="flex items-center gap-2 mb-2">
                <div class="w-10 h-10 bg-green-100 rounded-full flex items-center justify-center">
                  <svg class="w-5 h-5 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                          d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                  </svg>
                </div>
                <div class="flex-1">
                  <div class="font-semibold text-gray-900">ROC #{{ roc.rocNumber }}</div>
                  <div class="text-sm text-gray-600">{{ roc.quantity }} Litres</div>
                </div>
              </div>
              <div class="flex items-center gap-4 text-xs text-gray-600">
                <span class="flex items-center gap-1">
                  <span class="font-medium">State:</span>
                  <span :class="{
                    'text-green-600': roc.state === 'Ok',
                    'text-yellow-600': roc.state === 'Dirty',
                    'text-red-600': roc.state === 'Damaged'
                  }">
                    {{ roc.state }}
                  </span>
                </span>
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
    </div>

    <!-- Empty State -->
    <div v-else class="text-center py-8">
      <svg class="w-16 h-16 text-gray-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
      </svg>
      <p class="text-gray-500">No full ROCs added yet</p>
      <p class="text-xs text-gray-400 mt-1">Add ROC details for containers collected from the store</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useCollectionStore } from '@/stores/collection'
import { useUIStore } from '@/stores/ui'
import type { CollectRocModel } from '@/types/models'

const collectionStore = useCollectionStore()
const uiStore = useUIStore()

const formData = ref<Omit<CollectRocModel, 'rocNumber'> & { rocNumber: string }>({
  rocNumber: '',
  quantity: 0,
  state: 'Ok'
})

const errors = ref<Partial<Record<keyof typeof formData.value, string>>>({})

const isFormValid = computed(() =>
  formData.value.rocNumber.length > 0 &&
  formData.value.quantity > 0
)

function validateForm(): boolean {
  errors.value = {}

  if (!formData.value.rocNumber) {
    errors.value.rocNumber = 'ROC number is required'
    return false
  }

  if (!collectionStore.isValidROCNumber(formData.value.rocNumber)) {
    errors.value.rocNumber = 'ROC number must be 1-4 digits'
    return false
  }

  if (collectionStore.checkDuplicateROC(formData.value.rocNumber)) {
    errors.value.rocNumber = 'This ROC number is already added'
    return false
  }

  if (!formData.value.quantity || formData.value.quantity <= 0) {
    errors.value.quantity = 'Quantity must be greater than 0'
    return false
  }

  return true
}

function handleAdd() {
  if (!validateForm()) {
    return
  }

  try {
    const roc: CollectRocModel = {
      rocNumber: formData.value.rocNumber,
      quantity: formData.value.quantity,
      state: formData.value.state
    }

    collectionStore.addFullROC(roc)
    uiStore.showToast(`Full ROC #${roc.rocNumber} added (${roc.quantity}L)`, 'success')

    // Reset form
    formData.value = {
      rocNumber: '',
      quantity: 0,
      state: 'Ok'
    }
    errors.value = {}
  } catch (err: any) {
    errors.value.rocNumber = err.message || 'Failed to add ROC'
  }
}

function handleRemove(index: number) {
  const roc = collectionStore.fullROCs[index]
  collectionStore.removeFullROC(index)
  uiStore.showToast(`ROC #${roc.rocNumber} removed`, 'info')
}

function handleClearAll() {
  if (confirm(`Remove all ${collectionStore.fullROCs.length} full ROCs?`)) {
    while (collectionStore.fullROCs.length > 0) {
      collectionStore.removeFullROC(0)
    }
    uiStore.showToast('All full ROCs cleared', 'info')
  }
}
</script>
