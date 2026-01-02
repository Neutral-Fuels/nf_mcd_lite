export interface StoreModel {
  id?: string | number
  storeId?: string
  storeName: string
  storeCode: string
  storeNo?: string // Alias for storeCode
  address: string
  city: string
  suburb?: string // Alias for city
  state: string
  postcode: string
  postCode?: string // Alias for postcode
  country: string
  latitude?: number
  longitude?: number
  customerId: string | number
  isActive: boolean
  contactPhone?: string
}
