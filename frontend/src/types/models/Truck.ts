export interface TruckModel {
  id?: string | number
  truckId?: string
  regno: string
  description: string
  customerId: string | number
  isActive: boolean
  isThirdParty?: boolean
  // For compatibility with 3PL trucks
  thirdParty?: boolean
  supplierName?: string
  supplierId?: string | number
}

export interface ThirdPartyTruckModel {
  id?: string | number
  thirdPartyTruckId?: string
  regno: string
  description: string
  customerId: string | number
  isActive: boolean
  supplierName?: string
  supplierId?: string | number
}
