export interface NFUserModel {
  accessToken: string
  tokenType: string
  expiresIn: number
  id: string
  username: string
  email: string
  licenseNo: string
  firstName: string
  lastName: string
  isMcDUser: 'True' | 'False'
  customerId: string
  customerName: string
  countryId: string
  countryIso: string
  siteId: string
  timeZoneName: string
  customerHasTruck: 'True' | 'False'
  isthirdpartyuser: 'True' | 'False'
}

export interface LoginRequest {
  grant_type: 'password'
  username: string
  password: string
}

export interface LoginResponse extends NFUserModel {
  access_token: string
  token_type: string
  expires_in: number
  '.issued': string
  '.expires': string
}
