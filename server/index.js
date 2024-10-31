// index.js
require("dotenv").config();
const express = require("express");
const http = require("http");
const { Server } = require("socket.io");
const cors = require("cors");
const helmet = require("helmet");
const dbConnect = require("./lib/mongoose");
const jwt = require("jsonwebtoken");
const admin = require("firebase-admin");
const QuickOrder = require("./models/QuickOrder");
// Import routes
const menuRoutes = require("./routes/menuRoutes");
const orderRoutes = require("./routes/orderRoutes");
const authRoutes = require("./routes/authRoutes");
const salesRoutes = require("./routes/salesRoutes");
const tableRoutes = require("./routes/tableRoutes");
const quickOrderRoutes = require("./routes/quickOrderRoutes");
const businessDayRoutes = require("./routes/businessDayRoutes");
const restaurantRoutes = require("./routes/restaurantRoutes");
const userAuthRoutes = require("./routes/userAuthRoutes");
const visitRoutes = require("./routes/visitRoutes");
const app = express();
const server = http.createServer(app);

// Environment variables
const CORS_ORIGIN = process.env.CORS_ORIGIN || "http://localhost:3000";
const WS_HOST = process.env.WS_HOST || "localhost";
const WS_PORT = process.env.WS_PORT || 58566;
const API_URL = process.env.API_URL || "http://localhost:5000";
const JWT_SECRET = process.env.JWT_SECRET_KEY;

// Firebase Admin SDK 초기화
const serviceAccount = require("./lib/serviceAccountKey.json");
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});
// 추가: FCM 토큰 저장소
const fcmTokens = new Map();

// 추가: FCM 메시지 전송 함수
async function sendFCMMessage(fcmToken, title, body, data = {}) {
  try {
    console.log("Sending FCM message to token:", fcmToken);
    console.log("Message data:", { title, body, data });

    const message = {
      token: fcmToken,
      notification: {
        title,
        body,
      },
      data: {
        ...data,
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      android: {
        priority: "high",
        notification: {
          channelId: "quick_order_notifications",
          sound: "default",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
          },
        },
      },
    };

    const response = await admin.messaging().send(message);
    console.log("Successfully sent FCM message:", response);
    return response;
  } catch (error) {
    console.error("Error sending FCM message:", error);
    console.error("Error details:", error.errorInfo);
    throw error;
  }
}
/**
 *
 */
// Middleware
app.use(cors({ origin: CORS_ORIGIN, credentials: true }));
app.use(express.json());
app.use(
  helmet.contentSecurityPolicy({
    directives: {
      defaultSrc: ["'self'"],
      connectSrc: [
        "'self'",
        API_URL,
        `ws://${WS_HOST}:${WS_PORT}`,
        `wss://${WS_HOST}:${WS_PORT}`,
        `http://${WS_HOST}:${WS_PORT}`,
        `https://${WS_HOST}:${WS_PORT}`,
        "ws://127.0.0.1:58566",
        "wss://127.0.0.1:58566",
      ],
      scriptSrc: ["'self'"],
      styleSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "blob:"],
    },
  })
);

// Connect to MongoDB
dbConnect()
  .then(() => console.log("Connected to MongoDB"))
  .catch((err) => console.error("Failed to connect to MongoDB", err));

// Socket.IO setup
const io = new Server(server, {
  cors: {
    origin: CORS_ORIGIN,
    methods: ["GET", "POST", "PUT", "DELETE"],
    credentials: true,
  },
  transports: ["websocket", "polling"],
});

// Socket.IO 인스턴스를 app에 저장
app.set("io", io);

// Active connections map
const activeConnections = new Map();

function verifyToken(token, callback) {
  jwt.verify(token, JWT_SECRET, callback);
}

// Socket middleware for authentication
io.use((socket, next) => {
  const auth = socket.handshake.auth;
  const restaurantId = auth.restaurantId;
  const connectionType = auth.connectionType;
  const token = auth.token;
  const fcmToken = auth.fcmToken; // 명시적으로 선언
  const userId = auth.userId; // userId 추가
  if (!restaurantId || !connectionType) {
    return next(new Error("Invalid connection parameters"));
  }
  // FCM 토큰 처리
  if (connectionType === "customer") {
    // fcmToken이 있을 때만 저장
    if (fcmToken) {
      if (!fcmTokens.has(restaurantId)) {
        fcmTokens.set(restaurantId, new Map());
      }
      // fcmTokens.get(restaurantId).set(socket.id, fcmToken);
      fcmTokens.get(restaurantId).set(socket.id, {
        fcmToken,
        userId: auth.userId, // userId도 함께 저장
      });
      console.log(`Stored FCM token for socket ${socket.id} in restaurant ${restaurantId}`);
    }
  }
  /**
   *
   */
  if (connectionType === "admin") {
    if (!token) {
      return next(new Error("Authentication required for admin connection"));
    }
    verifyToken(token, (err, decoded) => {
      if (err) return next(new Error("Invalid token"));
      if (decoded.restaurantId !== restaurantId) {
        return next(new Error("Invalid restaurant ID"));
      }
      // userId도 소켓에 저장
      socket.userId = userId; // 추가: userId를 소켓 인스턴스에 저장
      socket.restaurantId = restaurantId;
      socket.isAdmin = true;
      next();
    });
  } else if (connectionType === "customer") {
    // userId도 소켓에 저장
    socket.userId = userId; // 추가: userId를 소켓 인스턴스에 저장
    socket.restaurantId = restaurantId;
    socket.isAdmin = false;
    next();
  } else {
    return next(new Error("Invalid connection type"));
  }
});

// Socket connection handler
io.on("connection", (socket) => {
  console.log(
    `New ${socket.isAdmin ? "admin" : "customer"} connection for restaurant: ${socket.restaurantId}`
  );

  if (!activeConnections.has(socket.restaurantId)) {
    activeConnections.set(socket.restaurantId, new Set());
  }
  activeConnections.get(socket.restaurantId).add(socket);

  socket.join(socket.restaurantId);
  /**
   *
   */
  // 추가: FCM 토큰 업데이트 이벤트 핸들러
  socket.on("updateFCMToken", (data) => {
    if (!fcmTokens.has(data.restaurantId)) {
      fcmTokens.set(data.restaurantId, new Map());
    }
    fcmTokens.get(data.restaurantId).set(socket.id, data.fcmToken);
    console.log(`FCM token updated for socket ${socket.id} in restaurant ${data.restaurantId}`);
  });
  // New order event handler
  socket.on("newOrder", (data, callback) => {
    console.log("Received new order:", data);
    if (typeof callback === "function") {
      callback({ success: true, message: "주문이 성공적으로 처리되었습니다." });
    }

    if (!data.isQuickOrder) {
      io.to(data.restaurantId).emit("newOrder", data);
    } else {
      console.log("Received QuickOrder in newOrder event, redirecting...");
      io.to(data.restaurantId).emit("newQuickOrder", data);
    }
  });

  // New quick order event handler
  socket.on("newQuickOrder", async (data, callback) => {
    console.log("Received new quick order:", data);
    let savedOrder = null; // 변수 선언 추가
    try {
      // FCM 토큰이 있으면 저장하고 DB에도 저장
      if (data.fcmToken) {
        // 메모리에 FCM 토큰 저장
        if (!fcmTokens.has(socket.restaurantId)) {
          fcmTokens.set(socket.restaurantId, new Map());
        }
        fcmTokens.get(socket.restaurantId).set(socket.id, data.fcmToken);

        // _id가 이미 있는 경우 해당 주문을 찾아서 fcmToken만 업데이트
        if (data._id) {
          savedOrder = await QuickOrder.findByIdAndUpdate(
            data._id,
            { fcmToken: data.fcmToken },
            { new: true }
          );
        }

        if (!savedOrder) {
          // 새로운 주문인 경우 생성
          savedOrder = await QuickOrder.create({
            ...data,
            fcmToken: data.fcmToken,
          });
        }

        // 주문 처리 성공 응답
        if (typeof callback === "function") {
          callback({ success: true, message: "주문이 성공적으로 처리되었습니다." });
        }

        // 레스토랑에 주문 알림 전송 - DB에서 생성된 주문 데이터 전송
        io.to(socket.restaurantId).emit("newQuickOrder", savedOrder);
      } else {
        throw new Error("FCM token is required for quick orders");
      }
    } catch (error) {
      console.error("Error processing quick order:", error);
      if (typeof callback === "function") {
        callback({ success: false, message: "주문 처리 중 오류가 발생했습니다." });
      }
    }
  });

  // 픽업 준비 알림 이벤트 핸들러
  socket.on("sendPickupNotification", async (data) => {
    try {
      const { orderId, userId, restaurantId, businessName, message, orderNumber, orderDetails } =
        data;
      console.log("Sending pickup notification for order:", orderId, "to user:", userId);

      // 주문 정보에서 FCM 토큰 조회
      const order = await QuickOrder.findById(orderId);

      // 주문에서 FCM 토큰을 찾은 경우 푸시 알림 전송
      if (order && order.fcmToken) {
        try {
          console.log("Found FCM token in order:", order.fcmToken);
          await sendFCMMessage(
            order.fcmToken,
            "주문 완료",
            message || "주문하신 음식이 준비되었습니다. 카운터에서 수령해주세요.",
            {
              orderId: orderId.toString(),
              restaurantId: restaurantId.toString(),
              businessName: businessName || "", // null/undefined 방지
              type: "pickup_ready",
              orderNumber: orderNumber.toString(),
              orderDetails: orderDetails.toString(),
              timestamp: new Date().toISOString(),
            }
          );

          console.log("Successfully sent pickup notification");

          // 소켓 이벤트도 발송
          const userSockets = Array.from(io.sockets.sockets.values()).filter(
            (socket) => socket.userId === userId && socket.restaurantId === restaurantId
          );

          userSockets.forEach((socket) => {
            socket.emit("pickupReady", {
              orderId,
              message,
              businessName,
              orderNumber,
              orderDetails,
              timestamp: new Date().toISOString(),
            });
          });
        } catch (fcmError) {
          console.error("Failed to send FCM notification:", fcmError);
        }
      } else {
        console.error("No FCM token found in order:", orderId);
      }
    } catch (error) {
      console.error("Error in sendPickupNotification:", error);
    }
  });

  // Status update event handler
  socket.on("statusUpdate", (data) => {
    io.to(data.restaurantId).emit("statusUpdate", data);
  });

  // Table reset event handler
  socket.on("tableReset", (data) => {
    io.to(data.restaurantId).emit("tableReset", data.tableId);
  });

  // Logout event handler
  socket.on("logout", (data) => {
    console.log(`User logged out for restaurant: ${data.restaurantId}`);
    removeFromActiveConnections(socket);
    socket.disconnect(true);
  });

  // Disconnect event handler
  socket.on("disconnect", () => {
    console.log(
      `${socket.isAdmin ? "Admin" : "Customer"} disconnected for restaurant ${socket.restaurantId}`
    );
    // FCM 토큰 정리
    const restaurantTokens = fcmTokens.get(socket.restaurantId);
    if (restaurantTokens) {
      restaurantTokens.delete(socket.id);
      if (restaurantTokens.size === 0) {
        fcmTokens.delete(socket.restaurantId);
      }
    }

    removeFromActiveConnections(socket);
  });

  // Error handling
  socket.on("error", (error) => {
    console.error(`Socket error for restaurant ${socket.restaurantId}:`, error);
  });
});

function removeFromActiveConnections(socket) {
  const connections = activeConnections.get(socket.restaurantId);
  if (connections) {
    connections.delete(socket);
    if (connections.size === 0) {
      activeConnections.delete(socket.restaurantId);
      console.log(`Removed all connections for restaurant ${socket.restaurantId}`);
    }
  }
}

// Make io accessible to our router
app.use((req, res, next) => {
  req.io = io;
  next();
});

// Routes
app.use("/api/menu", menuRoutes);
app.use("/api/orders", orderRoutes);
app.use("/api/auth", authRoutes);
app.use("/api/sales", salesRoutes);
app.use("/api/tables", tableRoutes);
app.use("/api/quick-orders", quickOrderRoutes);
app.use("/api/business-day", businessDayRoutes);
app.use("/api/restaurants", restaurantRoutes);
app.use("/api/user-auth", userAuthRoutes);
app.use("/api/visits", visitRoutes);

// Error handling middleware
app.use((err, req, res, next) => {
  console.error("Error details:", err);
  res.status(500).json({
    message: "An unexpected error occurred",
    error: err.message,
    stack: process.env.NODE_ENV === "production" ? "🥞" : err.stack,
  });
});

// Periodic connection check
setInterval(() => {
  activeConnections.forEach((connections, restaurantId) => {
    connections.forEach((socket) => {
      if (!socket.connected) {
        console.log(`Removing inactive connection for restaurant ${restaurantId}`);
        connections.delete(socket);
      }
    });
    if (connections.size === 0) {
      console.log(`Removing empty connection set for restaurant ${restaurantId}`);
      activeConnections.delete(restaurantId);
    }
  });
}, 60000); // Run every minute

const PORT = process.env.PORT || 5000;
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

// // index.js
// require("dotenv").config();
// const express = require("express");
// const http = require("http");
// const { Server } = require("socket.io");
// const cors = require("cors");
// const helmet = require("helmet");
// const dbConnect = require("./lib/mongoose");
// const jwt = require("jsonwebtoken");
// const admin = require("firebase-admin");

// // Import routes
// const menuRoutes = require("./routes/menuRoutes");
// const orderRoutes = require("./routes/orderRoutes");
// const authRoutes = require("./routes/authRoutes");
// const salesRoutes = require("./routes/salesRoutes");
// const tableRoutes = require("./routes/tableRoutes");
// const quickOrderRoutes = require("./routes/quickOrderRoutes");
// const businessDayRoutes = require("./routes/businessDayRoutes");
// const restaurantRoutes = require("./routes/restaurantRoutes");
// const userAuthRoutes = require("./routes/userAuthRoutes");
// const visitRoutes = require("./routes/visitRoutes");
// const app = express();
// const server = http.createServer(app);

// // Environment variables
// const CORS_ORIGIN = process.env.CORS_ORIGIN || "http://localhost:3000";
// const WS_HOST = process.env.WS_HOST || "localhost";
// const WS_PORT = process.env.WS_PORT || 58566;
// const API_URL = process.env.API_URL || "http://localhost:5000";
// const JWT_SECRET = process.env.JWT_SECRET_KEY;

// // Firebase Admin SDK 초기화
// const serviceAccount = require("./lib/serviceAccountKey.json");
// admin.initializeApp({
//   credential: admin.credential.cert(serviceAccount),
// });

// // Middleware
// app.use(cors({ origin: CORS_ORIGIN, credentials: true }));
// app.use(express.json());
// app.use(
//   helmet.contentSecurityPolicy({
//     directives: {
//       defaultSrc: ["'self'"],
//       connectSrc: [
//         "'self'",
//         API_URL,
//         `ws://${WS_HOST}:${WS_PORT}`,
//         `wss://${WS_HOST}:${WS_PORT}`,
//         `http://${WS_HOST}:${WS_PORT}`,
//         `https://${WS_HOST}:${WS_PORT}`,
//         "ws://127.0.0.1:58566",
//         "wss://127.0.0.1:58566",
//       ],
//       scriptSrc: ["'self'"],
//       styleSrc: ["'self'"],
//       imgSrc: ["'self'", "data:", "blob:"],
//     },
//   })
// );

// // Connect to MongoDB
// dbConnect()
//   .then(() => console.log("Connected to MongoDB"))
//   .catch((err) => console.error("Failed to connect to MongoDB", err));

// // Socket.IO setup
// const io = new Server(server, {
//   cors: {
//     origin: CORS_ORIGIN,
//     methods: ["GET", "POST", "PUT", "DELETE"],
//     credentials: true,
//   },
//   transports: ["websocket", "polling"],
// });

// // Socket.IO 인스턴스를 app에 저장
// app.set("io", io);

// // Active connections map
// const activeConnections = new Map();

// function verifyToken(token, callback) {
//   jwt.verify(token, JWT_SECRET, callback);
// }

// // Socket middleware for authentication
// io.use((socket, next) => {
//   const { restaurantId, connectionType, token } = socket.handshake.auth;

//   if (!restaurantId || !connectionType) {
//     return next(new Error("Invalid connection parameters"));
//   }

//   if (connectionType === "admin") {
//     if (!token) {
//       return next(new Error("Authentication required for admin connection"));
//     }
//     verifyToken(token, (err, decoded) => {
//       if (err) return next(new Error("Invalid token"));
//       if (decoded.restaurantId !== restaurantId) {
//         return next(new Error("Invalid restaurant ID"));
//       }
//       socket.restaurantId = restaurantId;
//       socket.isAdmin = true;
//       next();
//     });
//   } else if (connectionType === "customer") {
//     socket.restaurantId = restaurantId;
//     socket.isAdmin = false;
//     next();
//   } else {
//     return next(new Error("Invalid connection type"));
//   }
// });

// // Socket connection handler
// io.on("connection", (socket) => {
//   console.log(
//     `New ${socket.isAdmin ? "admin" : "customer"} connection for restaurant: ${socket.restaurantId}`
//   );

//   if (!activeConnections.has(socket.restaurantId)) {
//     activeConnections.set(socket.restaurantId, new Set());
//   }
//   activeConnections.get(socket.restaurantId).add(socket);

//   socket.join(socket.restaurantId);

//   // New order event handler
//   socket.on("newOrder", (data, callback) => {
//     console.log("Received new order:", data);
//     if (typeof callback === "function") {
//       callback({ success: true, message: "주문이 성공적으로 처리되었습니다." });
//     }

//     if (!data.isQuickOrder) {
//       io.to(data.restaurantId).emit("newOrder", data);
//     } else {
//       console.log("Received QuickOrder in newOrder event, redirecting...");
//       io.to(data.restaurantId).emit("newQuickOrder", data);
//     }
//   });

//   // New quick order event handler
//   socket.on("newQuickOrder", (data, callback) => {
//     console.log("Received new quick order:", data);
//     if (typeof callback === "function") {
//       callback({ success: true, message: "주문이 성공적으로 처리되었습니다." });
//     }
//     io.to(data.restaurantId).emit("newQuickOrder", data);
//   });

//   // Status update event handler
//   socket.on("statusUpdate", (data) => {
//     io.to(data.restaurantId).emit("statusUpdate", data);
//   });

//   // Table reset event handler
//   socket.on("tableReset", (data) => {
//     io.to(data.restaurantId).emit("tableReset", data.tableId);
//   });

//   // Logout event handler
//   socket.on("logout", (data) => {
//     console.log(`User logged out for restaurant: ${data.restaurantId}`);
//     removeFromActiveConnections(socket);
//     socket.disconnect(true);
//   });

//   // Disconnect event handler
//   socket.on("disconnect", () => {
//     console.log(
//       `${socket.isAdmin ? "Admin" : "Customer"} disconnected for restaurant ${socket.restaurantId}`
//     );
//     removeFromActiveConnections(socket);
//   });

//   // Error handling
//   socket.on("error", (error) => {
//     console.error(`Socket error for restaurant ${socket.restaurantId}:`, error);
//   });
// });

// function removeFromActiveConnections(socket) {
//   const connections = activeConnections.get(socket.restaurantId);
//   if (connections) {
//     connections.delete(socket);
//     if (connections.size === 0) {
//       activeConnections.delete(socket.restaurantId);
//       console.log(`Removed all connections for restaurant ${socket.restaurantId}`);
//     }
//   }
// }

// // Make io accessible to our router
// app.use((req, res, next) => {
//   req.io = io;
//   next();
// });

// // Routes
// app.use("/api/menu", menuRoutes);
// app.use("/api/orders", orderRoutes);
// app.use("/api/auth", authRoutes);
// app.use("/api/sales", salesRoutes);
// app.use("/api/tables", tableRoutes);
// app.use("/api/quick-orders", quickOrderRoutes);
// app.use("/api/business-day", businessDayRoutes);
// app.use("/api/restaurants", restaurantRoutes);
// app.use("/api/user-auth", userAuthRoutes);
// app.use("/api/visits", visitRoutes);

// // Error handling middleware
// app.use((err, req, res, next) => {
//   console.error("Error details:", err);
//   res.status(500).json({
//     message: "An unexpected error occurred",
//     error: err.message,
//     stack: process.env.NODE_ENV === "production" ? "🥞" : err.stack,
//   });
// });

// // Periodic connection check
// setInterval(() => {
//   activeConnections.forEach((connections, restaurantId) => {
//     connections.forEach((socket) => {
//       if (!socket.connected) {
//         console.log(`Removing inactive connection for restaurant ${restaurantId}`);
//         connections.delete(socket);
//       }
//     });
//     if (connections.size === 0) {
//       console.log(`Removing empty connection set for restaurant ${restaurantId}`);
//       activeConnections.delete(restaurantId);
//     }
//   });
// }, 60000); // Run every minute

// const PORT = process.env.PORT || 5000;
// server.listen(PORT, () => {
//   console.log(`Server running on port ${PORT}`);
// });
