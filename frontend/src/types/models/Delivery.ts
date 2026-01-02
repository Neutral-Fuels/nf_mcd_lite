export interface DeliveryRocModel {
  ucocollectionid: number
  rocnumber: string
  quantity: number
  state: string
  containertypeid: number
  ismissing: boolean
}

export interface RocDeliveryModel {
  containers: DeliveryRocModel[]
  userid: string
  datetimeofdelivery: string  // ISO8601 format
  truckrego: string
  staffid: number
  comments: string
}

export interface EmptyDespatchRecordModel {
  rocnumbers: string[]
  truckrego: string
  despatchedfromsite: string
  nfstaffid: number
  despatchdate: string  // ISO8601 format
}

export interface PendingDelivery {
  ucocollectionid: number
  rocnumber: string
  storename: string
  collectiondate: string
  quantity: number
  state: string
  containertypeid?: number
}
