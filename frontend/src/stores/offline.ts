import { defineStore } from 'pinia'
import { ref } from 'vue'

export interface QueuedRequest {
  id: string
  url: string
  method: string
  data: any
  timestamp: number
  retryCount: number
}

export const useOfflineStore = defineStore('offline', () => {
  // State
  const queue = ref<QueuedRequest[]>([])
  const isSyncing = ref(false)

  // Actions
  function queueRequest(request: Omit<QueuedRequest, 'id' | 'timestamp' | 'retryCount'>) {
    const queuedRequest: QueuedRequest = {
      ...request,
      id: `${Date.now()}-${Math.random()}`,
      timestamp: Date.now(),
      retryCount: 0
    }
    queue.value.push(queuedRequest)
    saveQueueToStorage()
  }

  function removeFromQueue(id: string) {
    const index = queue.value.findIndex(req => req.id === id)
    if (index !== -1) {
      queue.value.splice(index, 1)
      saveQueueToStorage()
    }
  }

  function incrementRetry(id: string) {
    const request = queue.value.find(req => req.id === id)
    if (request) {
      request.retryCount++
      saveQueueToStorage()
    }
  }

  function clearQueue() {
    queue.value = []
    localStorage.removeItem('offline_queue')
  }

  function saveQueueToStorage() {
    localStorage.setItem('offline_queue', JSON.stringify(queue.value))
  }

  function loadQueueFromStorage() {
    const stored = localStorage.getItem('offline_queue')
    if (stored) {
      queue.value = JSON.parse(stored)
    }
  }

  function setIsSyncing(syncing: boolean) {
    isSyncing.value = syncing
  }

  return {
    // State
    queue,
    isSyncing,

    // Actions
    queueRequest,
    removeFromQueue,
    incrementRetry,
    clearQueue,
    saveQueueToStorage,
    loadQueueFromStorage,
    setIsSyncing,
  }
})
