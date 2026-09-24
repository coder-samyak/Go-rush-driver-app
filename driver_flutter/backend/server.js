const dns = require('dns');
const http = require('http');
const { Server } = require('socket.io');
try {
  dns.setServers(['8.8.8.8', '1.1.1.1']);
} catch (e) {}
const app = require('./src/app');
const config = require('./src/config/env');
const { connectDB, disconnectDB } = require('./src/config/db');

const PORT = config.port;

/**
 * Start the GoRush Driver Backend Server
 */
const startServer = async () => {
  console.log('====================================================');
  console.log('       GoRush Driver Partner Backend Service        ');
  console.log('====================================================');
  console.log(`[Config] Environment : ${config.env}`);
  console.log(`[Config] Target Port : ${PORT}`);
  console.log(`[Config] Database    : ${config.db.name}`);

  // 1. Initialize MongoDB Connection
  await connectDB();

  // 2. Start Express HTTP Server
  const server = http.createServer(app);
  const io = new Server(server, {
    cors: { origin: '*', methods: ['GET', 'POST'] },
  });
  app.locals.io = io;
  io.on('connection', (socket) => {
    socket.on('driver:join', ({ driverId }) => {
      if (driverId) socket.join(`driver:${driverId}`);
    });
    socket.on('driver:availability', ({ online }) => {
      if (online) socket.join('drivers:online');
      else socket.leave('drivers:online');
    });
    socket.on('ride:join', ({ rideId }) => {
      if (rideId) socket.join(`ride:${rideId}`);
    });
    socket.on('support:join', () => socket.join('support:inbox'));
  });
  server.listen(PORT, '0.0.0.0', () => {
    console.log(`\n🚀 [Server] GoRush Driver Backend running on http://localhost:${PORT}`);
    console.log(`🩺 [Health] Health Check endpoint: http://localhost:${PORT}/api/health\n`);
  });

  // Graceful Shutdown Handler
  const shutdown = async (signal) => {
    console.log(`\n[Server] Received ${signal}. Initiating graceful shutdown...`);
    server.close(async () => {
      console.log('[Server] HTTP server closed.');
      await disconnectDB();
      console.log('[Server] Shutdown complete.');
      process.exit(0);
    });

    // Force exit after 10s if graceful shutdown hangs
    setTimeout(() => {
      console.error('[Server] Forced shutdown timeout expired.');
      process.exit(1);
    }, 10000);
  };

  process.on('SIGTERM', () => shutdown('SIGTERM'));
  process.on('SIGINT', () => shutdown('SIGINT'));

  // Global exception safety net
  process.on('unhandledRejection', (reason, promise) => {
    console.error('⚠️ [Process] Unhandled Rejection at:', promise, 'reason:', reason);
  });

  process.on('uncaughtException', (error) => {
    console.error('❌ [Process] Uncaught Exception:', error);
  });
};

startServer();
