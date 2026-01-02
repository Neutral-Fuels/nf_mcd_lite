export interface CollectRocModel {
  rocNumber: string
  quantity: number
  state: string
}

export interface CollectionEmptyRocModel {
  rocNumber: string
}

export interface RocCollectionModel {
  containers: CollectRocModel[]
  emptyROCsSupplied: CollectionEmptyRocModel[]
  truckrego: string
  storeid: string
  supervisorname: string
  supervisorid: number
  ucoreceiptnumber: number
  datetimeofcollection: string  // ISO8601 format
  latitude: number
  longitude: number
  verifycode: string
  comments: string
}

export interface PendingCollection {
  ucocollectionid: number
  collectiondate: string
  storename: string
  storeid: string
  roccount: number
  quantity: number
  truckrego: string
  supervisorname: string
}
