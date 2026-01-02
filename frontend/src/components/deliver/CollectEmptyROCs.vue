<template>
  <div class="space-y-4">
    <h2 class="text-lg font-semibold text-gray-900">Collect Empty ROCs</h2>
    <p class="text-sm text-gray-600">Pick up empty containers for return</p>

    <!-- Add ROC Section -->
    <div class="bg-white rounded-lg shadow-md p-4">
      <h3 class="font-medium text-gray-900 mb-3">Add Empty ROC</h3>

      <div class="flex gap-2">
        <div class="flex-1">
          <input
            v-model="newROCNumber"
            type="text"
            inputmode="numeric"
            pattern="[0-9]*"
            maxlength="4"
            placeholder="ROC number (1-4 digits)"
            class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
            @keyup.enter="addROC"
          />
        </div>
        <button
          @click="addROC"
          :disabled="!isValidROC"
          class="px-4 py-2 rounded-lg font-medium transition-colors"
          :class="isValidROC ? 'bg-primary text-white hover:bg-blue-700' : 'bg-gray-200 text-gray-400 cursor-not-allowed'"
        >
          Add
        </button>
      </div>
      <p v-if="error" class="text-sm text-red-600 mt-2">{{ error }}</p>
    </div>

    <!-- Empty ROCs List -->
    <div class="bg-white rounded-lg shadow-md p-4">
      <div class="flex items-center justify-between mb-3">
        <h3 class="font-medium text-gray-900">Empty ROCs to Collect</h3>
        <button
          v-if="emptyROCs.length > 0"
          @click="clearAll"
          class="text-sm text-red-600 hover:text-red-800"
        >
          Clear All
        </button>
      </div>

      <!-- Empty State -->
      <div v-if="emptyROCs.length === 0" class="text-center py-8 text-gray-500">
        <svg class="mx-auto h-10 w-10 text-gray-400 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 8h14M5 8a2 2 0 110-4h14a2 2 0 110 4M5 8v10a2 2 0 002 2h10a2 2 0 002-2V8m-9 4h4" />
        </svg>
        <p>No empty ROCs added yet</p>
      </div>

      <!-- ROC List -->
      <div v-else class="space-y-2 max-h-60 overflow-y-auto">
        <div
          v-for="(roc, index) in emptyROCs"
          :key="index"
          class="flex items-center justify-between p-3 bg-yellow-50 rounded-lg border border-yellow-200"
        >
          <div class="flex items-center">
            <svg class="w-5 h-5 text-yellow-600 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 8h14M5 8a2 2 0 110-4h14a2 2 0 110 4M5 8v10a2 2 0 002 2h10a2 2 0 002-2V8m-9 4h4" />
            </svg>
            <span class="font-medium text-gray-900">ROC #{{ roc }}</span>
          </div>
          <button
            @click="removeROC(index)"
            class="p-1 text-gray-400 hover:text-red-600 transition-colors"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
      </div>
    </div>

    <!-- Summary -->
    <div v-if="emptyROCs.length > 0" class="bg-yellow-50 rounded-lg p-4 border border-yellow-200">
      <div class="flex items-center justify-between">
        <div>
          <p class="text-sm text-yellow-700">Total Empty ROCs</p>
          <p class="text-3xl font-bold text-yellow-900">{{ emptyROCs.length }}</p>
        </div>
        <svg class="w-12 h-12 text-yellow-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 8h14M5 8a2 2 0 110-4h14a2 2 0 110 4M5 8v10a2 2 0 002 2h10a2 2 0 002-2V8m-9 4h4" />
        </svg>
      </div>
    </div>

    <!-- Submit Button -->
    <button
      v-if="emptyROCs.length > 0"
      @click="showVerificationDialog = true"
      :disabled="!canSubmit || submitting"
      class="w-full py-3 rounded-lg font-semibold text-white transition-colors"
      :class="canSubmit && !submitting ? 'bg-yellow-500 hover:bg-yellow-600' : 'bg-gray-300 cursor-not-allowed'"
    >
      {{ submitting ? 'Processing...' : 'Despatch Empty ROCs' }}
    </button>

    <!-- Delivery Verification Dialog -->
    <DeliveryVerificationDialog
      v-model:show="showVerificationDialog"
      :nf-staff-list="nfStaffList"
      @verified="handleVerified"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useDeliveryStore } from '@/stores/delivery'
import { useUIStore } from '@/stores/ui'
import { useAuthStore } from '@/stores/auth'
import { despatchAPIService, staffAPIService } from '@/services/api'
import type { NFStaffApiResponse } from '@/types/models'
import DeliveryVerificationDialog from './DeliveryVerificationDialog.vue'

const router = useRouter()
const deliveryStore = useDeliveryStore()
const uiStore = useUIStore()
const authStore = useAuthStore()

const emptyROCs = ref<string[]>([])
const newROCNumber = ref('')
const error = ref('')
const submitting = ref(false)
const showVerificationDialog = ref(false)
const nfStaffList = ref<NFStaffApiResponse[]>([])

const isValidROC = computed(() => {
  return /^\d{1,4}$/.test(newROCNumber.value) && !emptyROCs.value.includes(newROCNumber.value)
})

const canSubmit = computed(() => {
  return emptyROCs.value.length > 0
})

function addROC() {
  error.value = ''

  if (!newROCNumber.value.trim()) {
    error.value = 'Please enter a ROC number'
    return
  }

  if (!/^\d{1,4}$/.test(newROCNumber.value)) {
    error.value = 'ROC number must be 1-4 digits'
    return
  }

  if (emptyROCs.value.includes(newROCNumber.value)) {
    error.value = 'This ROC number is already added'
    return
  }

  emptyROCs.value.push(newROCNumber.value)
  newROCNumber.value = ''
}

function removeROC(index: number) {
  emptyROCs.value.splice(index, 1)
}

function clearAll() {
  emptyROCs.value = []
}

async function fetchNfStaff() {
  const siteId = authStore.user?.siteId
  if (!siteId) return

  try {
    const response = await staffAPIService.getNfStaffBySite(siteId.toString())

    // Handle different response formats
    if (response && typeof response === 'object') {
      if ('staff' in response && Array.isArray((response as any).staff)) {
        nfStaffList.value = (response as any).staff
      } else if (Array.isArray(response)) {
        nfStaffList.value = response as unknown as NFStaffApiResponse[]
      }
    }
  } catch (err: any) {
    console.error('[CollectEmptyROCs] Failed to fetch NF staff:', err)
  }
}

async function handleVerified(data: { staffId: number, comments: string }) {
  try {
    submitting.value = true

    // Format local datetime (without Z suffix)
    const now = new Date()
    const localDateTime = new Date(now.getTime() - now.getTimezoneOffset() * 60000)
      .toISOString()
      .replace('Z', '')

    const despatchData = {
      rocnumbers: emptyROCs.value,
      truckrego: uiStore.selectedTruck?.regno || '',
      despatchedfromsite: authStore.user?.siteId || 'NF Depot',
      nfstaffid: data.staffId,
      comments: data.comments || 'None',
      despatchdate: localDateTime
    }

    await despatchAPIService.createDespatch(despatchData)

    uiStore.showToast(`${emptyROCs.value.length} empty ROCs despatched successfully!`, 'success')
    deliveryStore.clearDelivery()
    router.push('/home/dashboard')
  } catch (err: any) {
    uiStore.showToast(err.message || 'Failed to despatch empty ROCs', 'error')
  } finally {
    submitting.value = false
  }
}

onMounted(() => {
  fetchNfStaff()
})
</script>
