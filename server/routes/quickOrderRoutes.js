// file: \Flutter-Next-Ordering-System\server\routes\quickOrderRoutes.js

const express = require("express");
const router = express.Router();
const QuickOrder = require("../models/QuickOrder");
const Restaurant = require("../models/Restaurant");
const DailySales = require("../models/DailySales");
const { authenticate, authenticateCustomer } = require("../middleware/auth");
const BusinessDay = require("../models/BusinessDay");
const moment = require("moment-timezone");

const timeZone = "Asia/Seoul";

// Helper functions updated and consolidated
const getKoreanNow = () => moment().tz(timeZone);
const toKoreanTime = (date) => moment(date).tz(timeZone);
const toUTCDate = (date) => moment.tz(date, timeZone).utc().toDate();

const sendErrorResponse = (res, statusCode, message, details = null) => {
  const response = { success: false, error: message };
  if (details) response.details = details;
  return res.status(statusCode).json(response);
};

// Updated getOrCreateActiveBusinessDay function
// const getOrCreateActiveBusinessDay = async (restaurantId) => {
//   console.log(`[BusinessDay] Searching for active business day for restaurant: ${restaurantId}`);

//   let activeBusinessDay = await BusinessDay.findOne({
//     restaurantId,
//     isActive: true,
//   });

//   if (activeBusinessDay) {
//     console.log(`[BusinessDay] Found active business day: ${activeBusinessDay._id}`);
//     return activeBusinessDay;
//   }

//   console.log(`[BusinessDay] No active business day found. Creating a new one.`);

//   try {
//     const koreanNow = getKoreanNow();
//     const newBusinessDay = new BusinessDay({
//       restaurantId,
//       startTime: toUTCDate(koreanNow),
//       isActive: true,
//     });

//     activeBusinessDay = await newBusinessDay.save();
//     console.log(`[BusinessDay] New business day created: ${activeBusinessDay._id}`);
//     return activeBusinessDay;
//   } catch (error) {
//     console.error(`[BusinessDay] Error creating new business day:`, error);
//     throw error;
//   }
// };

// Updated GET route
router.get("/", authenticate, async (req, res) => {
  try {
    const { restaurantId, date } = req.query;
    console.log("[QuickOrder] GET request params:", { restaurantId, date });

    if (!restaurantId) {
      return res.status(400).json({ success: false, error: "Restaurant ID is required" });
    }

    // 비즈니스 데이 확인 및 시작
    // const activeBusinessDay = await BusinessDay.findOne({
    //   restaurantId,
    //   isActive: true,
    // });
    // 수정된 코드:
    const now = moment().tz(timeZone);
    const activeBusinessDay = await BusinessDay.findOne({
      restaurantId,
      businessDate: {
        $gte: now.clone().startOf("day").toDate(),
        $lte: now.clone().endOf("day").toDate(),
      },
      isActive: true,
    });

    if (!activeBusinessDay) {
      return res.status(200).json({
        success: true,
        status: "no_active_business_day",
        message: "No active business day found",
      });
    }
    /**
     *
     */
    const startOfDay = moment(activeBusinessDay.startTime).tz(timeZone);
    const endOfDay = moment(startOfDay).endOf("day");

    console.log("[QuickOrder] Querying orders from", startOfDay.format(), "to", endOfDay.format());

    if (date) {
      const orders = await QuickOrder.find({
        restaurantId,
        status: "completed",
        createdAt: { $gte: startOfDay.toDate(), $lt: endOfDay.toDate() },
      });

      console.log("[QuickOrder] Found", orders.length, "completed orders");

      const totalSales = orders.reduce((sum, order) => sum + order.totalAmount, 0);
      return res.json({
        success: true,
        date: startOfDay.format("YYYY-MM-DD"),
        totalSales,
      });
    } else {
      const activeOrders = await QuickOrder.find({
        restaurantId,
        status: { $ne: "completed" },
      }).sort({ createdAt: 1 });

      console.log("[QuickOrder] Found", activeOrders.length, "active orders");

      const activeOrdersInKoreanTime = activeOrders.map((order) => ({
        ...order.toObject(),
        createdAt: moment(order.createdAt).tz(timeZone).format("YYYY-MM-DD HH:mm:ss"),
        updatedAt: moment(order.updatedAt).tz(timeZone).format("YYYY-MM-DD HH:mm:ss"),
      }));

      return res.json({
        success: true,
        data: activeOrdersInKoreanTime,
        meta: {
          businessDayId: activeBusinessDay._id,
          businessDayStart: startOfDay.format(),
        },
      });
    }
  } catch (error) {
    console.error("[QuickOrder] Failed to fetch quick orders:", error);
    return res.status(500).json({
      success: false,
      error: "Failed to fetch quick orders",
      details: error.message,
    });
  }
});

// Updated POST route
router.post("/", authenticate, async (req, res) => {
  try {
    const orderData = req.body;
    console.log("Received order data:", orderData);

    if (!orderData.restaurantId) {
      return sendErrorResponse(res, 403, "Unauthorized access");
    }

    const restaurant = await Restaurant.findOne({ restaurantId: orderData.restaurantId });
    if (!restaurant) {
      console.log("Restaurant not found:", orderData.restaurantId);
      return sendErrorResponse(res, 404, "Restaurant not found");
    }

    if (restaurant.hasTables) {
      console.log(
        "Attempt to create quick order for restaurant with tables:",
        orderData.restaurantId
      );
      return sendErrorResponse(res, 400, "This endpoint is for quick orders only");
    }

    const totalAmount = orderData.items.reduce(
      (total, item) => total + item.price * item.quantity,
      0
    );
    console.log("Calculated total amount:", totalAmount);

    // 비즈니스 데이 확인 및 시작
    // const activeBusinessDay = await getOrCreateActiveBusinessDay(orderData.restaurantId);
    console.log("Before finding activeBusinessDay");
    const now = moment().tz(timeZone);
    let activeBusinessDay = await BusinessDay.findOne({
      restaurantId: orderData.restaurantId,
      businessDate: {
        $gte: now.clone().startOf("day").toDate(),
        $lte: now.clone().endOf("day").toDate(),
      },
      isActive: true,
    });
    setImmediate(() => {
      console.log("ActiveBusinessDay (async):", activeBusinessDay);
    });
    if (!activeBusinessDay) {
      activeBusinessDay = new BusinessDay({
        restaurantId: orderData.restaurantId,
        startTime: now.toDate(),
        businessDate: now.startOf("day").toDate(),
        isActive: true,
      });
      await activeBusinessDay.save();
    }

    const orderForSaving = {
      restaurantId: orderData.restaurantId,
      businessDayId: activeBusinessDay._id,
      items: orderData.items.map(({ id, name, price, quantity }) => ({
        id,
        name,
        price,
        quantity,
      })),
      status: orderData.status || "pending",
      totalAmount,
      user: orderData.userId, // 사용자 ID 추가
    };

    const newOrder = new QuickOrder(orderForSaving);
    const savedOrder = await newOrder.save();
    console.log("Order saved successfully:", savedOrder);

    req.app.get("io").to(orderData.restaurantId).emit("newQuickOrder", savedOrder);

    return res.status(201).json({ success: true, data: savedOrder });
  } catch (error) {
    console.error("Failed to create quick order:", error);
    if (error.name === "ValidationError") {
      return sendErrorResponse(res, 400, "Validation failed", error.errors);
    }
    return sendErrorResponse(res, 500, "Failed to create quick order", error.message);
  }
});

// Updated PATCH route
router.patch("/", authenticate, async (req, res) => {
  try {
    const { orderId, newStatus, action } = req.body;
    console.log("PATCH request data:", { orderId, newStatus, action });

    if (action === "completeAllOrders") {
      const restaurantId = req.user.restaurantId;
      // const activeBusinessDay = await getOrCreateActiveBusinessDay(restaurantId);
      const now = moment().tz(timeZone);
      const activeBusinessDay = await BusinessDay.findOne({
        restaurantId,
        businessDate: {
          $gte: now.clone().startOf("day").toDate(),
          $lte: now.clone().endOf("day").toDate(),
        },
        isActive: true,
      });

      if (!activeBusinessDay) {
        return res.status(400).json({ success: false, error: "No active business day found" });
      }
      const orders = await QuickOrder.find({ restaurantId, status: { $ne: "completed" } });

      for (const order of orders) {
        order.status = "completed";
        await order.save();

        totalSalesIncrement += order.totalAmount;
        allItemSales.push(
          ...order.items.map((item) => ({
            itemId: item.id,
            name: item.name,
            quantity: item.quantity,
            price: item.price,
            sales: item.price * item.quantity,
          }))
        );
      }

      // DailySales 업데이트 (한 번만 수행)
      await DailySales.findOneAndUpdate(
        {
          restaurantId,
          businessDayId: activeBusinessDay._id,
          date: activeBusinessDay.businessDate,
        },
        {
          $inc: { totalSales: totalSalesIncrement },
          $push: {
            itemSales: {
              $each: allItemSales,
            },
          },
        },
        { upsert: true, new: true }
      );

      return res.json({
        success: true,
        message: "All orders completed",
        modifiedCount: orders.length,
        meta: {
          businessDayId: activeBusinessDay._id,
          isActive: activeBusinessDay.isActive,
        },
      });
    } else {
      if (!orderId || !newStatus) {
        return sendErrorResponse(res, 400, "Order ID and new status are required");
      }

      const order = await QuickOrder.findById(orderId);
      if (!order) {
        console.log("Quick order not found:", orderId);
        return sendErrorResponse(res, 404, "Quick order not found");
      }

      if (order.restaurantId !== req.user.restaurantId) {
        console.log("Unauthorized access attempt:", { orderId, userId: req.user.restaurantId });
        return sendErrorResponse(res, 403, "Unauthorized access");
      }

      // const activeBusinessDay = await getOrCreateActiveBusinessDay(order.restaurantId);
      const now = moment().tz(timeZone);
      const activeBusinessDay = await BusinessDay.findOne({
        restaurantId: order.restaurantId,
        businessDate: {
          $gte: now.clone().startOf("day").toDate(),
          $lte: now.clone().endOf("day").toDate(),
        },
        isActive: true,
      });

      if (!activeBusinessDay) {
        return res.status(400).json({ success: false, error: "No active business day found" });
      }
      const oldStatus = order.status;
      order.status = newStatus;
      order.businessDayId = activeBusinessDay._id;
      await order.save();
      console.log("Order status updated:", {
        orderId,
        oldStatus,
        newStatus,
        businessDayId: activeBusinessDay._id,
      });

      if (newStatus === "completed" && oldStatus !== "completed") {
        await DailySales.findOneAndUpdate(
          {
            restaurantId: order.restaurantId,
            businessDayId: activeBusinessDay._id,
            date: activeBusinessDay.businessDate,
          },
          {
            $inc: { totalSales: order.totalAmount },
            $push: {
              itemSales: order.items.map((item) => ({
                itemId: item.id,
                name: item.name,
                quantity: item.quantity,
                price: item.price,
                sales: item.price * item.quantity,
              })),
            },
          },
          { upsert: true, new: true }
        );

        console.log("DailySales updated for completed order:", {
          orderId,
          totalAmount: order.totalAmount,
        });

        const updateResult = await QuickOrder.updateMany(
          { restaurantId: order.restaurantId, queuePosition: { $gt: order.queuePosition } },
          { $inc: { queuePosition: -1 } }
        );
        console.log("Queue positions updated:", updateResult);
      }

      const updatedQueue = await QuickOrder.find({
        restaurantId: order.restaurantId,
        status: { $in: ["pending", "preparing"] },
      }).sort("queuePosition");

      console.log("Updated queue length:", updatedQueue.length);

      return res.json({
        success: true,
        data: { order, updatedQueue },
        message: "Quick order updated successfully",
        meta: {
          businessDayId: activeBusinessDay._id,
          isActive: activeBusinessDay.isActive,
        },
      });
    }
  } catch (error) {
    console.error("Failed to update quick order:", error);
    return sendErrorResponse(res, 500, "Failed to update quick order", error.message);
  }
});

// 손님 주문 생성
router.post("/customer", authenticateCustomer, async (req, res) => {
  try {
    const orderData = req.body;
    console.log("Received quick order data:", JSON.stringify(orderData, null, 2));

    if (!orderData.restaurantId) {
      return sendErrorResponse(res, 403, "Restaurant ID is required");
    }

    const restaurant = await Restaurant.findOne({ restaurantId: orderData.restaurantId });
    if (!restaurant) {
      console.log("Restaurant not found:", orderData.restaurantId);
      return sendErrorResponse(res, 404, "Restaurant not found");
    }

    if (restaurant.hasTables) {
      console.log(
        "Attempt to create quick order for restaurant with tables:",
        orderData.restaurantId
      );
      return sendErrorResponse(res, 400, "This endpoint is for quick orders only");
    }

    const totalAmount = orderData.items.reduce(
      (total, item) => total + item.price * item.quantity,
      0
    );
    console.log("Calculated total amount:", totalAmount);

    const now = getKoreanNow();
    let activeBusinessDay = await BusinessDay.findOne({
      restaurantId: orderData.restaurantId,
      businessDate: {
        $gte: now.startOf("day").toDate(),
        $lte: now.endOf("day").toDate(),
      },
      isActive: true,
    });

    if (!activeBusinessDay) {
      activeBusinessDay = new BusinessDay({
        restaurantId: orderData.restaurantId,
        startTime: now.toDate(),
        businessDate: now.startOf("day").toDate(),
        isActive: true,
      });
      await activeBusinessDay.save();
    }

    const orderForSaving = {
      restaurantId: orderData.restaurantId,
      businessDayId: activeBusinessDay._id,
      items: orderData.items.map(({ id, name, price, quantity, selectedOptions = [] }) => ({
        id,
        name,
        price,
        quantity,
        selectedOptions, // 기본값으로 빈 배열 사용
      })),
      status: orderData.status || "pending",
      totalAmount,
      user: req.user.uid, // Firebase UID 또는 사용자 ID
      fcmToken: orderData.fcmToken, // 추가: FCM 토큰 저장
    };

    console.log("QuickOrder data for saving:", JSON.stringify(orderForSaving, null, 2));

    const newOrder = new QuickOrder(orderForSaving);

    // Validate the order before saving
    const validationError = newOrder.validateSync();
    if (validationError) {
      console.error("Validation error:", validationError);
      return sendErrorResponse(
        res,
        400,
        "Validation failed",
        Object.values(validationError.errors).map((err) => ({
          field: err.path,
          message: err.message,
        }))
      );
    }

    const savedOrder = await newOrder.save();
    console.log("QuickOrder saved successfully:", JSON.stringify(savedOrder, null, 2));
    req.app.get("io").to(orderData.restaurantId).emit("newOrder", savedOrder);
    // try {
    //   const io = req.app.get("io");
    //   if (io) {
    //     io.to(orderData.restaurantId).emit("newQuickOrder", savedOrder);
    //     console.log("Emitted newQuickOrder event");
    //   } else {
    //     console.warn("Socket.io instance not found");
    //   }
    // } catch (socketError) {
    //   console.error("Failed to emit socket event:", socketError);
    // }

    return res.status(201).json({ success: true, data: savedOrder });
  } catch (error) {
    console.error("Failed to create quick order:", error);
    if (error.name === "ValidationError") {
      return sendErrorResponse(
        res,
        400,
        "Validation failed",
        Object.values(error.errors).map((err) => ({
          field: err.path,
          message: err.message,
        }))
      );
    }
    return sendErrorResponse(res, 500, "Failed to create quick order", error.message);
  }
});

// 손님 주문 조회
router.get("/customer", authenticateCustomer, async (req, res) => {
  try {
    const { restaurantId } = req.query;
    const userId = req.user.uid; // Firebase UID

    if (!restaurantId) {
      return res.status(400).json({ error: "Restaurant ID is required" });
    }

    const now = getKoreanNow();
    const activeBusinessDay = await BusinessDay.findOne({
      restaurantId,
      businessDate: {
        $gte: now.startOf("day").toDate(),
        $lte: now.endOf("day").toDate(),
      },
      isActive: true,
    });

    if (!activeBusinessDay) {
      return res.status(200).json({
        success: true,
        status: "no_active_business_day",
        message: "No active business day found",
      });
    }

    const customerOrders = await QuickOrder.find({
      restaurantId,
      user: userId,
      businessDayId: activeBusinessDay._id,
    }).sort({ createdAt: -1 }); // 최신 주문부터 정렬

    const customerOrdersInKoreanTime = customerOrders.map((order) => ({
      ...order.toObject(),
      createdAt: toKoreanTime(order.createdAt).format("YYYY-MM-DD HH:mm:ss"),
      updatedAt: toKoreanTime(order.updatedAt).format("YYYY-MM-DD HH:mm:ss"),
    }));

    return res.json({
      success: true,
      data: customerOrdersInKoreanTime,
      meta: {
        businessDayId: activeBusinessDay._id,
        businessDayStart: toKoreanTime(activeBusinessDay.startTime).format(),
      },
    });
  } catch (error) {
    console.error("[Order] Failed to fetch customer orders:", error);
    return res.status(500).json({ error: "Failed to fetch orders", details: error.message });
  }
});

module.exports = router;
