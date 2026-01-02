<template>
  <div class="space-y-4">
    <h2 class="text-lg font-semibold text-gray-900">Transfer from Another Truck</h2>
    <p class="text-sm text-gray-600">Select the source truck to transfer ROCs from</p>

    <!-- Source Truck Selection -->
    <div v-if="!deliveryStore.selectedSourceTruck" class="bg-white rounded-lg shadow-md p-4">
      <h3 class="font-medium text-gray-900 mb-3">Select Source Truck</h3>

      <!-- Search -->
      <div class="relative mb-4">
        <input
          v-model="searchQuery"
          type="text"
          placeholder="Search trucks..."
          class="w-full px-4 py-2 pl-10 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
        />
        <svg class="absolute left-3 top-2.5 w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
        </svg>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="flex justify-center py-8">
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
      </div>

      <!-- Truck List -->
      <div v-else class="space-y-2 max-h-60 overflow-y-auto">
        <button
          v-for="truck in filteredTrucks"
          :key="truck.id"
          @click="selectSourceTruck(truck)"
          class="w-full p-3 text-left rounded-lg border border-gray-200 hover:border-primary hover:bg-blue-50 transition-colors"
        >
          <div class="font-medium text-gray-900">{{ truck.regno }}</div>
          <div class="text-sm text-gray-500">{{ truck.description || 'No description' }}</div>
        </button>
        <p v-if="filteredTrucks.length === 0" class="text-center text-gray-500 py-4">
          No trucks found
        </p>
      </div>
    </div>

    <!-- Selected Source Truck & Pending ROCs -->
    <div v-else class="space-y-4">
      <!-- Source Truck Info -->
      <div class="bg-blue-50 rounded-lg p-4 border border-blue-200">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm text-blue-600">Source Truck</p>
            <p class="font-semibold text-blue-900">{{ deliveryStore.selectedSourceTruck.regno }}</p>
          </div>
          <button
            @click="deliveryStore.setSourceTruck(null)"
            class="text-blue-600 hover:text-blue-800 text-sm underline"
          >
            Change
          </button>
        </div>
      </div>

      <!-- Pending ROCs from Source Truck -->
      <div class="bg-white rounded-lg shadow-md p-4">
        <h3 class="font-medium text-gray-900 mb-3">Pending ROCs to Transfer</h3>

        <div v-if="loadingPending" class="flex justify-center py-8">
          <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
        </div>

        <div v-else-if="deliveryStore.pendingDeliveries.length === 0" class="text-center py-8 text-gray-500">
          No pending ROCs from this truck
        </div>

        <div v-else class="space-y-2 max-h-80 overflow-y-auto">
          <div
            v-for="roc in deliveryStore.pendingDeliveries"
            :key="roc.ucocollectionid"
            class="p-3 rounded-lg border"
            :class="getROCStatusClass(roc.state)"
          >
            <div class="flex items-center justify-between">
              <div>
                <p class="font-medium">ROC #{{ roc.rocnumber }}</p>
                <p class="text-sm text-gray-600">{{ roc.storename }}</p>
                <p class="text-xs text-gray-500">{{ roc.quantity }}L - {{ roc.collectiondate }}</p>
              </div>
              <div class="flex gap-1">
                <button
                  @click="markStatus(roc.ucocollectionid, 'confirmed')"
                  class="p-2 rounded-lg"
                  :class="roc.state === 'confirmed' ? 'bg-green-100 text-green-600' : 'bg-gray-100 text-gray-400 hover:bg-green-50'"
                  title="Confirmed"
                >
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                  </svg>
                </button>
                <button
                  @click="markStatus(roc.ucocollectionid, 'missing')"
                  class="p-2 rounded-lg"
                  :class="roc.state === 'missing' ? 'bg-red-100 text-red-600' : 'bg-gray-100 text-gray-400 hover:bg-red-50'"
                  title="Missing"
                >
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
                <button
                  @click="markStatus(roc.ucocollectionid, 'disputed')"
                  class="p-2 rounded-lg"
                  :class="roc.state === 'disputed' ? 'bg-yellow-100 text-yellow-600' : 'bg-gray-100 text-gray-400 hover:bg-yellow-50'"
                  title="Disputed"
                >
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                  </svg>
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Submit Button -->
      <button
        @click="showVerificationDialog = true"
        :disabled="!canSubmit"
        class="w-full py-3 rounded-lg font-semibold text-white transition-colors"
        :class="canSubmit ? 'bg-primary hover:bg-blue-700' : 'bg-gray-300 cursor-not-allowed'"
      >
        Complete Transfer
      </button>
    </div>

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
import { truckAPIService, deliveryAPIService, staffAPIService } from '@/services/api'
import type { TruckModel, NFStaffApiResponse } from '@/types/models'
import DeliveryVerificationDialog from './DeliveryVerificationDialog.vue'

const router = useRouter()
const deliveryStore = useDeliveryStore()
const uiStore = useUIStore()
const authStore = useAuthStore()

const trucks = ref<TruckModel[]>([])
const searchQuery = ref('')
const loading = ref(false)
const loadingPending = ref(false)
const showVerificationDialog = ref(false)
const nfStaffList = ref<NFStaffApiResponse[]>([])

const filteredTrucks = computed(() => {
  if (!searchQuery.value) return trucks.value
  const query = searchQuery.value.toLowerCase()
  return trucks.value.filter(truck =>
    truck.regno.toLowerCase().includes(query) ||
    truck.description?.toLowerCase().includes(query)
  )
})

const canSubmit = computed(() => {
  return deliveryStore.pendingDeliveries.length > 0 &&
    deliveryStore.pendingDeliveries.every(roc =>
      ['confirmed', 'missing', 'disputed'].includes(roc.state)
    )
})

function getROCStatusClass(status: string) {
  switch (status) {
    case 'confirmed': return 'border-green-200 bg-green-50'
    case 'missing': return 'border-red-200 bg-red-50'
    case 'disputed': return 'border-yellow-200 bg-yellow-50'
    default: return 'border-gray-200'
  }
}

async function fetchTrucks() {
  const customerId = authStore.user?.customerId
  if (!customerId) return

  try {
    loading.value = true
    trucks.value = await truckAPIService.getCustomerTrucks(customerId.toString())
  } catch (err: any) {
    uiStore.showToast('Failed to load trucks', 'error')
  } finally {
    loading.value = false
  }
}

function selectSourceTruck(truck: TruckModel) {
  deliveryStore.setSourceTruck(truck)
  fetchPendingROCs(truck.regno)
}

async function fetchPendingROCs(truckRego: string) {
  try {
    loadingPending.value = true
    const pending = await deliveryAPIService.getPendingDeliveries(truckRego)
    deliveryStore.setPendingDeliveries(pending)
  } catch (err: any) {
    uiStore.showToast('Failed to load pending ROCs', 'error')
  } finally {
    loadingPending.value = false
  }
}

function markStatus(rocId: number, status: 'confirmed' | 'missing' | 'disputed') {
  deliveryStore.markROCStatus(rocId, status)
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
    console.error('[FromAnotherTruck] Failed to fetch NF staff:', err)
  }
}

async function handleVerified(data: { staffId: number, comments: string }) {
  try {
    // Build delivery data for transfer
    const confirmedROCs = deliveryStore.pendingDeliveries.filter(roc => roc.state === 'confirmed')
    const missingROCs = deliveryStore.pendingDeliveries.filter(roc => roc.state === 'missing')
    const disputedROCs = deliveryStore.pendingDeliveries.filter(roc => roc.state === 'disputed')

    // Submit the transfer with staff verification
    const deliveryData = {
      sourceTruckId: deliveryStore.selectedSourceTruck?.id,
      confirmedROCs: confirmedROCs.map(roc => roc.ucocollectionid),
      missingROCs: missingROCs.map(roc => roc.ucocollectionid),
      disputedROCs: disputedROCs.map(roc => roc.ucocollectionid),
      staffid: data.staffId,
      comments: data.comments
    }

    await deliveryAPIService.createDelivery(deliveryData)

    uiStore.showToast('Transfer completed successfully!', 'success')
    deliveryStore.clearDelivery()
    router.push('/home/dashboard')
  } catch (err: any) {
    uiStore.showToast('Failed to complete transfer', 'error')
  }
}

onMounted(() => {
  fetchTrucks()
  fetchNfStaff()
})
</script>
