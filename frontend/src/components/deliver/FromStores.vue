<template>
  <div class="space-y-4">
    <h2 class="text-lg font-semibold text-gray-900">Deliver from Stores</h2>
    <p class="text-sm text-gray-600">Deliver ROC collections from your current truck</p>

    <!-- Loading -->
    <div v-if="loading" class="flex justify-center py-12">
      <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
    </div>

    <!-- No Pending Deliveries -->
    <div v-else-if="deliveryStore.pendingDeliveries.length === 0" class="text-center py-12">
      <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
      </svg>
      <h3 class="mt-2 text-sm font-medium text-gray-900">No pending deliveries</h3>
      <p class="mt-1 text-sm text-gray-500">No ROCs are pending delivery from your truck</p>
    </div>

    <!-- Pending Deliveries List -->
    <div v-else class="space-y-4">
      <div class="bg-white rounded-lg shadow-md p-4">
        <div class="flex items-center justify-between mb-3">
          <h3 class="font-medium text-gray-900">Pending ROCs</h3>
          <span class="text-sm text-gray-500">{{ deliveryStore.pendingDeliveries.length }} items</span>
        </div>

        <div class="space-y-2 max-h-96 overflow-y-auto">
          <div
            v-for="roc in deliveryStore.pendingDeliveries"
            :key="roc.ucocollectionid"
            class="p-3 rounded-lg border"
            :class="getROCStatusClass(roc.state)"
          >
            <div class="flex items-center justify-between">
              <div class="flex-1">
                <div class="flex items-center gap-2">
                  <p class="font-medium">ROC #{{ roc.rocnumber }}</p>
                  <span
                    v-if="roc.state && ['confirmed', 'missing', 'disputed'].includes(roc.state)"
                    class="px-2 py-0.5 text-xs rounded-full"
                    :class="{
                      'bg-green-100 text-green-700': roc.state === 'confirmed',
                      'bg-red-100 text-red-700': roc.state === 'missing',
                      'bg-yellow-100 text-yellow-700': roc.state === 'disputed'
                    }"
                  >
                    {{ roc.state }}
                  </span>
                </div>
                <p class="text-sm text-gray-600">{{ roc.storename }}</p>
                <p class="text-xs text-gray-500">{{ roc.quantity }}L - {{ formatDate(roc.collectiondate) }}</p>
              </div>
              <div class="flex gap-1">
                <button
                  @click="markStatus(roc.ucocollectionid, 'confirmed')"
                  class="p-2 rounded-lg transition-colors"
                  :class="roc.state === 'confirmed' ? 'bg-green-100 text-green-600' : 'bg-gray-100 text-gray-400 hover:bg-green-50 hover:text-green-500'"
                  title="Confirmed"
                >
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                  </svg>
                </button>
                <button
                  @click="markStatus(roc.ucocollectionid, 'missing')"
                  class="p-2 rounded-lg transition-colors"
                  :class="roc.state === 'missing' ? 'bg-red-100 text-red-600' : 'bg-gray-100 text-gray-400 hover:bg-red-50 hover:text-red-500'"
                  title="Missing"
                >
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
                <button
                  @click="markStatus(roc.ucocollectionid, 'disputed')"
                  class="p-2 rounded-lg transition-colors"
                  :class="roc.state === 'disputed' ? 'bg-yellow-100 text-yellow-600' : 'bg-gray-100 text-gray-400 hover:bg-yellow-50 hover:text-yellow-500'"
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

      <!-- Summary -->
      <div class="bg-gray-100 rounded-lg p-4">
        <div class="grid grid-cols-3 gap-4 text-center">
          <div>
            <p class="text-2xl font-bold text-green-600">{{ confirmedCount }}</p>
            <p class="text-xs text-gray-600">Confirmed</p>
          </div>
          <div>
            <p class="text-2xl font-bold text-red-600">{{ missingCount }}</p>
            <p class="text-xs text-gray-600">Missing</p>
          </div>
          <div>
            <p class="text-2xl font-bold text-yellow-600">{{ disputedCount }}</p>
            <p class="text-xs text-gray-600">Disputed</p>
          </div>
        </div>
      </div>

      <!-- Submit Button -->
      <button
        @click="showVerificationDialog = true"
        :disabled="!canSubmit || submitting"
        class="w-full py-3 rounded-lg font-semibold text-white transition-colors"
        :class="canSubmit && !submitting ? 'bg-primary hover:bg-blue-700' : 'bg-gray-300 cursor-not-allowed'"
      >
        {{ submitting ? 'Submitting...' : 'Complete Delivery' }}
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
import { deliveryAPIService, staffAPIService } from '@/services/api'
import DeliveryVerificationDialog from './DeliveryVerificationDialog.vue'
import type { NFStaffApiResponse } from '@/types/models'

const router = useRouter()
const deliveryStore = useDeliveryStore()
const uiStore = useUIStore()
const authStore = useAuthStore()

const loading = ref(false)
const submitting = ref(false)
const showVerificationDialog = ref(false)
const nfStaffList = ref<NFStaffApiResponse[]>([])

const confirmedCount = computed(() =>
  deliveryStore.pendingDeliveries.filter(r => r.state === 'confirmed').length
)
const missingCount = computed(() =>
  deliveryStore.pendingDeliveries.filter(r => r.state === 'missing').length
)
const disputedCount = computed(() =>
  deliveryStore.pendingDeliveries.filter(r => r.state === 'disputed').length
)

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

function formatDate(dateStr: string) {
  try {
    return new Date(dateStr).toLocaleDateString()
  } catch {
    return dateStr
  }
}

function markStatus(rocId: number, status: 'confirmed' | 'missing' | 'disputed') {
  deliveryStore.markROCStatus(rocId, status)
}

async function fetchPendingDeliveries() {
  const truckRego = uiStore.selectedTruck?.regno
  if (!truckRego) return

  try {
    loading.value = true
    const pending = await deliveryAPIService.getPendingDeliveries(truckRego)
    deliveryStore.setPendingDeliveries(pending)
  } catch (err: any) {
    uiStore.showToast('Failed to load pending deliveries', 'error')
  } finally {
    loading.value = false
  }
}

async function fetchNfStaff() {
  const siteId = authStore.user?.siteId
  if (!siteId) {
    console.warn('[FromStores] No siteId found for user')
    return
  }

  try {
    console.log('[FromStores] Fetching NF staff for site:', siteId)
    const response = await staffAPIService.getNfStaffBySite(siteId)

    // Handle response - may be wrapped in { staff: [...] }
    if (response && typeof response === 'object') {
      if ('staff' in response && Array.isArray((response as any).staff)) {
        nfStaffList.value = (response as any).staff
      } else if (Array.isArray(response)) {
        nfStaffList.value = response as unknown as NFStaffApiResponse[]
      }
    }
    console.log('[FromStores] NF staff loaded:', nfStaffList.value.length)
  } catch (err: any) {
    console.error('[FromStores] Failed to fetch NF staff:', err)
    uiStore.showToast('Failed to load staff list', 'warning')
  }
}

async function handleVerified(data: { staffId: number, comments: string }) {
  try {
    submitting.value = true

    // Map state values to API expected format
    // UI uses: 'confirmed', 'missing', 'disputed'
    // API expects: 'Ok', 'Missing', 'Disputed'
    const mapStateToApi = (state: string) => {
      switch (state) {
        case 'confirmed': return 'Ok'
        case 'missing': return 'Missing'
        case 'disputed': return 'Disputed'
        default: return 'Ok'
      }
    }

    // Format local datetime (without Z suffix)
    const now = new Date()
    const localDateTime = new Date(now.getTime() - now.getTimezoneOffset() * 60000)
      .toISOString()
      .replace('Z', '')

    // Build delivery data matching working Postman format
    const deliveryData = {
      containers: deliveryStore.pendingDeliveries.map(roc => ({
        ucocollectionid: roc.ucocollectionid,
        rocnumber: String(roc.rocnumber || ''),
        quantity: roc.quantity,
        state: mapStateToApi(roc.state),
        containertypeid: roc.containertypeid || 1,
        ismissing: roc.state === 'missing'
      })),
      comments: data.comments || 'None',
      datetimeofdelivery: localDateTime,
      staffid: data.staffId,
      truckrego: uiStore.selectedTruck?.regno || '',
      userid: authStore.user?.id || ''
    }

    await deliveryAPIService.createDelivery(deliveryData)

    uiStore.showToast('Delivery completed successfully!', 'success')
    deliveryStore.clearDelivery()
    router.push('/home/dashboard')
  } catch (err: any) {
    uiStore.showToast(err.message || 'Failed to complete delivery', 'error')
  } finally {
    submitting.value = false
  }
}

onMounted(() => {
  fetchPendingDeliveries()
  fetchNfStaff()
})
</script>
