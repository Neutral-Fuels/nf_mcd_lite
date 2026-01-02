import { defineStore } from 'pinia'
import { ref } from 'vue'
import type { TruckModel, StoreModel } from '@/types/models'
import { STORAGE_KEYS } from '@/utils/constants'

export const useUIStore = defineStore('ui', () => {
  // State
  const activeTab = ref(0)
  const selectedTruck = ref<TruckModel | null>(null)
  const selectedStore = ref<StoreModel | null>(null)
  const isOnline = ref(navigator.onLine)
  const showLoadingSpinner = ref(false)
  const toast = ref<{
    show: boolean
    message: string
    type: 'success' | 'error' | 'info' | 'warning'
  }>({
    show: false,
    message: '',
    type: 'info'
  })

  // Actions
  function setActiveTab(tab: number) {
    activeTab.value = tab
  }

  function setSelectedTruck(truck: TruckModel | null) {
    selectedTruck.value = truck
    if (truck) {
      localStorage.setItem(STORAGE_KEYS.SELECTED_TRUCK, JSON.stringify(truck))
    } else {
      localStorage.removeItem(STORAGE_KEYS.SELECTED_TRUCK)
    }
  }

  function loadSelectedTruck() {
    const stored = localStorage.getItem(STORAGE_KEYS.SELECTED_TRUCK)
    if (stored) {
      selectedTruck.value = JSON.parse(stored)
    }
  }

  function setSelectedStore(store: StoreModel | null) {
    selectedStore.value = store
    if (store) {
      localStorage.setItem(STORAGE_KEYS.SELECTED_STORE, JSON.stringify(store))
    } else {
      localStorage.removeItem(STORAGE_KEYS.SELECTED_STORE)
    }
  }

  function loadSelectedStore() {
    const stored = localStorage.getItem(STORAGE_KEYS.SELECTED_STORE)
    if (stored) {
      selectedStore.value = JSON.parse(stored)
    }
  }

  function setOnlineStatus(status: boolean) {
    isOnline.value = status
  }

  function showToast(message: string, type: 'success' | 'error' | 'info' | 'warning' = 'info') {
    toast.value = { show: true, message, type }
    setTimeout(() => {
      toast.value.show = false
    }, 3000)
  }

  function hideToast() {
    toast.value.show = false
  }

  function setLoadingSpinner(show: boolean) {
    showLoadingSpinner.value = show
  }

  return {
    // State
    activeTab,
    selectedTruck,
    selectedStore,
    isOnline,
    showLoadingSpinner,
    toast,

    // Actions
    setActiveTab,
    setSelectedTruck,
    loadSelectedTruck,
    setSelectedStore,
    loadSelectedStore,
    setOnlineStatus,
    showToast,
    hideToast,
    setLoadingSpinner,
  }
})
