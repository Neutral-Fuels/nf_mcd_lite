import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { TruckModel, PendingDelivery } from '@/types/models'
import { DELIVERY_TYPES } from '@/utils/constants'

export const useDeliveryStore = defineStore('delivery', () => {
  // State
  const selectedDeliveryType = ref<string | null>(null)
  const selectedSourceTruck = ref<TruckModel | null>(null)
  const pendingDeliveries = ref<PendingDelivery[]>([])
  const isLoading = ref(false)

  // Getters
  const isFromAnotherTruck = computed(() =>
    selectedDeliveryType.value === DELIVERY_TYPES.FROM_ANOTHER_TRUCK
  )
  const isFromStores = computed(() =>
    selectedDeliveryType.value === DELIVERY_TYPES.FROM_STORES
  )
  const isBulkDelivery = computed(() =>
    selectedDeliveryType.value === DELIVERY_TYPES.BULK_DELIVERY
  )
  const isCollectEmptyROCs = computed(() =>
    selectedDeliveryType.value === DELIVERY_TYPES.COLLECT_EMPTY_ROCS
  )

  // Actions
  function setDeliveryType(type: string) {
    selectedDeliveryType.value = type
  }

  function setSourceTruck(truck: TruckModel | null) {
    selectedSourceTruck.value = truck
  }

  function setPendingDeliveries(deliveries: PendingDelivery[]) {
    pendingDeliveries.value = deliveries
  }

  function markROCStatus(rocId: number, status: 'confirmed' | 'missing' | 'disputed') {
    const delivery = pendingDeliveries.value.find(d => d.ucocollectionid === rocId)
    if (delivery) {
      delivery.state = status
    }
  }

  function clearDelivery() {
    selectedDeliveryType.value = null
    selectedSourceTruck.value = null
    pendingDeliveries.value = []
  }

  return {
    // State
    selectedDeliveryType,
    selectedSourceTruck,
    pendingDeliveries,
    isLoading,

    // Getters
    isFromAnotherTruck,
    isFromStores,
    isBulkDelivery,
    isCollectEmptyROCs,

    // Actions
    setDeliveryType,
    setSourceTruck,
    setPendingDeliveries,
    markROCStatus,
    clearDelivery,
  }
})
