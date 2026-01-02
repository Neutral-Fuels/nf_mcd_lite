// Mapped/normalized model for internal use
export interface McdStaffModel {
  staffId: number
  employeeId: string
  firstName: string
  lastName: string
  fullName: string
  storeId: string
  isActive: boolean
}

// Mapped/normalized model for internal use
export interface NFStaffModel {
  staffId: number
  employeeId: string
  firstName: string
  lastName: string
  fullName: string
  siteId: string
  isActive: boolean
}

export interface StaffVerification {
  staffId: number
  employeeId: string
  fullName: string
  verifyCode: string
}

// API Response types - matching production API format
// Used for Collection verification
export interface McdStaffApiResponse {
  mcdstaffid: number       // Used as supervisorid in collection
  employeeid: number       // What staff member enters for verification (number from API)
  employeename: string     // Used as supervisorname in collection
  position?: string        // Staff position
  storeid?: string
  isactive?: boolean
}

// API Response for staff list from /api/v1/McdStaff/StaffMemberByEmployeeId
export interface McdStaffLookupResponse {
  staff: McdStaffApiResponse[]
}

// Used for Delivery verification
export interface NFStaffApiResponse {
  staffid: number          // Used in delivery submission
  employeeid: string       // What NF staff enters for verification
  firstname?: string
  lastname?: string
  siteid?: string
  isactive?: boolean
}

// API Response for staff list from /api/v1/NFStaff/StaffBySite
export interface NFStaffListResponse {
  staff: NFStaffApiResponse[]
}
