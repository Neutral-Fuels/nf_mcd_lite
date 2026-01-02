import apiClient from './client'
import type { RocCollectionModel, CollectionEmptyRocModel } from '@/types/models'
import type { ApiResponse } from './auth.service'

class CollectionAPIService {
  /**
   * Get pending collections by truck registration
   */
  async getPendingCollections(
    truckRego: string,
    isAllClientCollections: boolean = false
  ): Promise<RocCollectionModel[]> {
    const response = await apiClient.get<ApiResponse<RocCollectionModel[]>>(
      '/collection/pending',
      {
        params: {
          truckrego: truckRego,
          isallclientcollections: isAllClientCollections.toString()
        }
      }
    )

    if (!response.data.success || !response.data.data) {
      throw new Error(response.data.error?.message || 'Failed to fetch pending collections')
    }

    return response.data.data
  }

  /**
   * Get empty ROCs at a store
   */
  async getEmptyRocsAtStore(storeId: string): Promise<CollectionEmptyRocModel[]> {
    const response = await apiClient.get<ApiResponse<CollectionEmptyRocModel[]>>(
      `/collection/empty-rocs/${storeId}`
    )

    if (!response.data.success || !response.data.data) {
      throw new Error(response.data.error?.message || 'Failed to fetch empty ROCs at store')
    }

    return response.data.data
  }

  /**
   * Create a new collection
   */
  async createCollection(collectionData: any): Promise<any> {
    const response = await apiClient.post<ApiResponse<any>>(
      '/collection/new',
      collectionData
    )

    if (!response.data.success || !response.data.data) {
      throw new Error(response.data.error?.message || 'Failed to create collection')
    }

    return response.data.data
  }
}

export const collectionAPIService = new CollectionAPIService()
