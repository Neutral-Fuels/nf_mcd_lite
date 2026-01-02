import dotenv from 'dotenv'

dotenv.config()

export const config = {
  nodeEnv: process.env.NODE_ENV || 'development',
  port: parseInt(process.env.PORT || '3000', 10),
  environment: (process.env.ENVIRONMENT || 'test') as 'test' | 'production',

  // UCO API URLs
  ucoApiTestUrl: process.env.UCO_API_TEST_URL || 'https://nf-test-ucoapi.neutralfuels.net',
  ucoApiProdUrl: process.env.UCO_API_PROD_URL || 'https://ucoapi.neutralfuels.net',

  // Frontend URL for CORS
  frontendUrl: process.env.FRONTEND_URL || 'http://localhost:5173',

  // Redis
  redisHost: process.env.REDIS_HOST || 'localhost',
  redisPort: parseInt(process.env.REDIS_PORT || '6379', 10),

  // Logging
  logLevel: process.env.LOG_LEVEL || 'debug',
}

export function getUcoApiUrl(): string {
  return config.environment === 'production' ? config.ucoApiProdUrl : config.ucoApiTestUrl
}
