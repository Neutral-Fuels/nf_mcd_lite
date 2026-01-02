<template>
  <div class="space-y-4">
    <h2 class="text-lg font-semibold text-gray-900">Bulk Delivery</h2>
    <p class="text-sm text-gray-600">Large-scale delivery from multiple stores</p>

    <!-- Loading -->
    <div v-if="loading" class="flex justify-center py-12">
      <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
    </div>

    <!-- No Pending Deliveries -->
    <div v-else-if="deliveryStore.pendingDeliveries.length === 0" class="text-center py-12">
      <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
      </svg>
      <h3 class="mt-2 text-sm font-medium text-gray-900">No bulk deliveries pending</h3>
      <p class="mt-1 text-sm text-gray-500">No ROCs are ready for bulk delivery</p>
    </div>

    <!-- Bulk Delivery List -->
    <div v-else class="space-y-4">
      <!-- Quick Actions -->
      <div class="bg-white rounded-lg shadow-md p-4">
        <div class="flex items-center justify-between mb-3">
          <h3 class="font-medium text-gray-900">Quick Actions</h3>
        </div>
        <div class="flex gap-2">
          <button
            @click="markAllAs('confirmed')"
            class="flex-1 py-2 px-3 rounded-lg bg-green-100 text-green-700 hover:bg-green-200 text-sm font-medium transition-colors"
          >
            Confirm All
          </button>
          <button
            @click="markAllAs('missing')"
            class="flex-1 py-2 px-3 rounded-lg bg-red-100 text-red-700 hover:bg-red-200 text-sm font-medium transition-colors"
          >
            Mark All Missing
          </button>
        </div>
      </div>

      <!-- Grouped by Store -->
      <div
        v-for="(storeGroup, storeName) in groupedByStore"
        :key="storeName"
        class="bg-white rounded-lg shadow-md overflow-hidden"
      >
        <div class="bg-gray-100 px-4 py-3 border-b">
          <div class="flex items-center justify-between">
            <h3 class="font-medium text-gray-900">{{ storeName }}</h3>
            <span class="text-sm text-gray-500">{{ storeGroup.length }} ROCs</span>
          </div>
        </div>

        <div class="divide-y divide-gray-100">
          <div
            v-for="roc in storeGroup"
            :key="roc.ucocollectionid"
            class="p-3 flex items-center justify-between"
            :class="{
              'bg-green-50': roc.state === 'confirmed',
              'bg-red-50': roc.state === 'missing',
              'bg-yellow-50': roc.state === 'disputed'
            }"
          >
            <div>
              <p class="font-medium text-gray-900">ROC #{{ roc.rocnumber }}</p>
              <p class="text-sm text-gray-500">{{ roc.quantity }}L</p>
            </div>
            <div class="flex gap-1">
              <button
                @click="markStatus(roc.ucocollectionid, 'confirmed')"
                class="p-2 rounded-lg transition-colors"
                :class="roc.state === 'confirmed' ? 'bg-green-200 text-green-700' : 'bg-gray-100 text-gray-400 hover:bg-green-100'"
              >
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                </svg>
              </button>
              <button
                @click="markStatus(roc.ucocollectionid, 'missing')"
                class="p-2 rounded-lg transition-colors"
                :class="roc.state === 'missing' ? 'bg-red-200 text-red-700' : 'bg-gray-100 text-gray-400 hover:bg-red-100'"
              >
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Summary -->
      <div class="bg-purple-50 rounded-lg p-4 border border-purple-200">
        <h3 class="font-medium text-purple-900 mb-3">Delivery Summary</h3>
        <div class="grid grid-cols-2 gap-4">
          <div>
            <p class="text-sm text-purple-600">Total ROCs</p>
            <p class="text-2xl font-bold text-purple-900">{{ deliveryStore.pendingDeliveries.length }}</p>
          </div>
          <div>
            <p class="text-sm text-purple-600">Total Stores</p>
            <p class="text-2xl font-bold text-purple-900">{{ Object.keys(groupedByStore).length }}</p>
          </div>
          <div>
            <p class="text-sm text-purple-600">Confirmed</p>
            <p class="text-2xl font-bold text-green-600">{{ confirmedCount }}</p>
          </div>
          <div>
            <p class="text-sm text-purple-600">Missing</p>
            <p class="text-2xl font-bold text-red-600">{{ missingCount }}</p>
          </div>
        </div>
      </div>

      <!-- Submit Button -->
      <button
        @click="showVerificationDialog = true"
        :disabled="!canSubmit || submitting"
        class="w-full py-3 rounded-lg font-semibold text-white transition-colors"
        :class="canSubmit && !submitting ? 'bg-purple-600 hover:bg-purple-700' : 'bg-gray-300 cursor-not-allowed'"
      >
        {{ submitting ? 'Processing...' : 'Complete Bulk Delivery' }}
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
import type { NFStaffApiResponse } from '@/types/models'
import DeliveryVerificationDialog from './DeliveryVerificationDialog.vue'

const router = useRouter()
const deliveryStore = useDeliveryStore()
const uiStore = useUIStore()
const authStore = useAuthStore()

const loading = ref(false)
const submitting = ref(false)
const showVerificationDialog = ref(false)
const nfStaffList = ref<NFStaffApiResponse[]>([])

const groupedByStore = computed(() => {
  const grouped: Record<string, typeof deliveryStore.pendingDeliveries> = {}
  deliveryStore.pendingDeliveries.forEach(roc => {
    const storeName = roc.storename || 'Unknown Store'
    if (!grouped[storeName]) {
      grouped[storeName] = []
    }
    grouped[storeName].push(roc)
  })
  return grouped
})

const confirmedCount = computed(() =>
  deliveryStore.pendingDeliveries.filter(r => r.state === 'confirmed').length
)
const missingCount = computed(() =>
  deliveryStore.pendingDeliveries.filter(r => r.state === 'missing').length
)

const canSubmit = computed(() => {
  return deliveryStore.pendingDeliveries.length > 0 &&
    deliveryStore.pendingDeliveries.every(roc =>
      ['confirmed', 'missing', 'disputed'].includes(roc.state)
    )
})

function markStatus(rocId: number, status: 'confirmed' | 'missing' | 'disputed') {
  deliveryStore.markROCStatus(rocId, status)
}

function markAllAs(status: 'confirmed' | 'missing') {
  deliveryStore.pendingDeliveries.forEach(roc => {
    deliveryStore.markROCStatus(roc.ucocollectionid, status)
  })
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
    console.error('[BulkDelivery] Failed to fetch NF staff:', err)
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

    const deliveryData = {
      containers: deliveryStore.pendingDeliveries.map(roc => ({
        ucocollectionid: roc.ucocollectionid,
        rocnumber: String(roc.rocnumber || ''),
        quantity: roc.quantity,
        state: mapStateToApi(roc.state),
        containertypeid: roc.containertypeid || 1,
        ismissing: roc.state === 'missing'
      })),
      userid: authStore.user?.id || '',
      datetimeofdelivery: localDateTime,
      truckrego: uiStore.selectedTruck?.regno || '',
      staffid: data.staffId,
      comments: data.comments || 'None'
    }

    await deliveryAPIService.createDelivery(deliveryData)

    uiStore.showToast('Bulk delivery completed successfully!', 'success')
    deliveryStore.clearDelivery()
    router.push('/home/dashboard')
  } catch (err: any) {
    uiStore.showToast(err.message || 'Failed to complete bulk delivery', 'error')
  } finally {
    submitting.value = false
  }
}

onMounted(() => {
  fetchPendingDeliveries()
  fetchNfStaff()
})
</script>
