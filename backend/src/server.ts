import http from 'http'
import app from './app.js'
import { config } from './config/environment.js'
import logger from './config/logger.js'

const server = http.createServer(app)

// WebSocket will be initialized here in Phase 9
// import { setupWebSocket } from './websocket/server.js'
// const io = setupWebSocket(server)

server.listen(config.port, () => {
  logger.info(`Server running on port ${config.port}`)
  logger.info(`Environment: ${config.environment}`)
  logger.info(`UCO API: ${config.environment === 'production' ? config.ucoApiProdUrl : config.ucoApiTestUrl}`)
  logger.info(`Frontend URL: ${config.frontendUrl}`)
})

// Graceful shutdown
process.on('SIGTERM', () => {
  logger.info('SIGTERM received, shutting down gracefully')
  server.close(() => {
    logger.info('Server closed')
    process.exit(0)
  })
})
