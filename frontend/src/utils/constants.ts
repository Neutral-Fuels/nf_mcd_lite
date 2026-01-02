export const APP_CONFIG = {
  mobileAppCode: 'MCDUCOWEB',
  mobileAppVersion: '2.0.0',
  buildNumber: '1',
}

export const API_ENDPOINTS = {
  test: 'https://nf-test-ucoapi.neutralfuels.net',
  production: 'https://ucoapi.neutralfuels.net',
}

export const THEME_COLORS = {
  primary: '#258AFF',
  secondary: '#52CB00',
  widgetOrange: 'rgba(244, 152, 35, 0.7)',
  widgetPink: 'rgba(212, 97, 210, 0.7)',
  widgetBlue: 'rgba(36, 200, 248, 0.7)',
  widgetGrey: 'rgba(133, 155, 144, 0.3)',
}

export const STORAGE_KEYS = {
  TOKEN: 'auth_token',
  USER: 'auth_user',
  LOGIN_TIME: 'login_time',
  CREDENTIALS: 'encrypted_credentials',
  SELECTED_TRUCK: 'selected_truck',
  SELECTED_STORE: 'selected_store',
  ENVIRONMENT: 'api_environment',
}

export const VALIDATION_RULES = {
  ROC_NUMBER_MAX_LENGTH: 4,
  QUANTITY_MAX_LENGTH: 5,
  QUANTITY_NEW_MAX_LENGTH: 3,
  STAFF_ID_MIN_LENGTH: 1,
}

export const ROC_STATES = {
  OK: 'Ok',
  DAMAGED: 'Damaged',
  MISSING: 'Missing',
  DISPUTED: 'Disputed',
  CONFIRMED: 'Confirmed',
}

export const DELIVERY_TYPES = {
  FROM_ANOTHER_TRUCK: 'FROM_ANOTHER_TRUCK',
  FROM_STORES: 'FROM_STORES',
  BULK_DELIVERY: 'BULK_DELIVERY',
  COLLECT_EMPTY_ROCS: 'COLLECT_EMPTY_ROCS',
}

export const CONTAINER_TYPE_IDS = {
  STANDARD: 1,
  LARGE: 2,
}
