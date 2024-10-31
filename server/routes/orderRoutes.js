// routes/orderRoutes.js
const express = require("express");
const router = express.Router();
const Order = require("../models/Order");
const Table = require("../models/Table");
const DailySales = require("../models/DailySales");
const { authenticate, authenticateCustomer } = require("../middleware/auth");
const BusinessDay = require("../models/BusinessDay"); // BusinessDay 모델 추가
const moment = require("moment-timezone");

const timeZone = "Asia/Seoul";

// Helper function to get the current time in KST
// 수정: getKoreanNow 함수가 moment 객체를 반환하도록 변경
const getKoreanNow = () => moment().tz(timeZone);

// 수정: toKoreanTime 함수 추가
const toKoreanTime = (date) => moment(date).tz(timeZone);
// Helper function to convert Korean time to UTC
const toUTCDate = (date) => {
  return moment.tz(date, timeZone).utc().toDate();
};

// Helper function to convert UTC to Korean time
const toKoreanDate = (date) => {
  return moment.utc(date).tz(timeZone).toDate();
};

// Helper function to get or create an active business day
const getOrCreateActiveBusinessDay = async (restaurantId) => {
  console.log(`[BusinessDay] Searching for active business day for restaurant: ${restaurantId}`);

  let activeBusinessDay = await BusinessDay.findOne({
    restaurantId,
    isActive: true,
  });

  if (activeBusinessDay) {
    console.log(`[BusinessDay] Found active business day: ${activeBusinessDay._id}`);
    return activeBusinessDay;
  }

  console.log(`[BusinessDay] No active business day found. Creating a new one.`);

  try {
    const now = new Date();
    const koreanNow = moment.tz(now, timeZone).format("YYYY-MM-DD HH:mm:ss");
    const newBusinessDay = new BusinessDay({
      restaurantId,
      startTime: toUTCDate(koreanNow),
      isActive: true,
    });

    activeBusinessDay = await newBusinessDay.save();
    console.log(`[BusinessDay] New business day created: ${activeBusinessDay._id}`);
    return activeBusinessDay;
  } catch (error) {
    console.error(`[BusinessDay] Error creating new business day:`, error);
    throw error;
  }
};

// Fetch orders
// Fetch orders
router.get("/", authenticate, async (req, res) => {
  try {
    const { restaurantId, date } = req.query;

    if (!restaurantId) {
      return sendErrorResponse(res, 400, "Restaurant ID is required");
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

    const startOfDay = toKoreanTime(activeBusinessDay.startTime);

    if (date) {
      const endOfDay = startOfDay.clone().endOf("day");
      const orders = await Order.find({
        restaurantId,
        status: "completed",
        createdAt: { $gte: startOfDay.toDate(), $lt: endOfDay.toDate() },
      });

      const totalSales = orders.reduce((sum, order) => sum + order.totalAmount, 0);
      return res.json({
        success: true,
        date: startOfDay.format("YYYY-MM-DD"),
        totalSales,
      });
    } else {
      const activeOrders = await Order.find({
        restaurantId,
        status: { $ne: "completed" },
      }).sort({ createdAt: 1 });

      const activeOrdersInKoreanTime = activeOrders.map((order) => ({
        ...order.toObject(),
        createdAt: toKoreanTime(order.createdAt).format("YYYY-MM-DD HH:mm:ss"),
        updatedAt: toKoreanTime(order.updatedAt).format("YYYY-MM-DD HH:mm:ss"),
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
    console.error("[Order] Failed to fetch orders:", error);
    return sendErrorResponse(res, 500, "Failed to fetch orders", error.message);
  }
});

// Create a new order
router.post("/", authenticate, async (req, res) => {
  try {
    const orderData = req.body;
    console.log("Received order data:", orderData);

    if (!orderData.restaurantId) {
      return sendErrorResponse(res, 403, "Unauthorized access");
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
      tableId: orderData.tableId,
      items: orderData.items.map(({ id, name, price, quantity }) => ({
        id,
        name,
        price,
        quantity,
      })),
      status: orderData.status || "pending",
      totalAmount,
      user: orderData.userId,
    };

    const newOrder = new Order(orderForSaving);
    const savedOrder = await newOrder.save();
    console.log("Order saved successfully:", savedOrder);

    req.app.get("io").to(orderData.restaurantId).emit("newOrder", savedOrder);

    return res.status(201).json({ success: true, data: savedOrder });
  } catch (error) {
    console.error("Failed to create order:", error);
    if (error.name === "ValidationError") {
      return sendErrorResponse(res, 400, "Validation failed", error.errors);
    }
    return sendErrorResponse(res, 500, "Failed to create order", error.message);
  }
});

// Update orders
router.patch("/", authenticate, async (req, res) => {
  try {
    const { restaurantId, tableId, action, orderId, newStatus } = req.body;
    const now = moment().tz(timeZone);
    const activeBusinessDay = await BusinessDay.findOne({
      restaurantId,
      businessDate: {
        $gte: now.startOf("day").toDate(),
        $lte: now.endOf("day").toDate(),
      },
      isActive: true,
    });

    if (!activeBusinessDay) {
      return res.status(400).json({ error: "No active business day found" });
    }

    if (action === "completeCall") {
      const order = await Order.findOne({ _id: orderId, restaurantId: restaurantId });

      if (!order) {
        return res.status(404).json({ error: "Order not found" });
      }

      // Check if the order contains only items with price 0
      const isAllItemsFree = order.items.every((item) => item.price === 0);

      if (!isAllItemsFree) {
        return res.status(400).json({ error: "The order contains items with non-zero prices" });
      }

      // Update the order status to completed
      order.status = "completed";
      await order.save();

      // Get updated queue information
      const updatedQueue = await Order.find({
        restaurantId: order.restaurantId,
        status: { $in: ["pending", "preparing"] },
      }).sort("createdAt");

      return res.json({
        message: "Call completed and order status updated",
        order,
        updatedQueue,
      });
    } else if (action === "completeAllOrders") {
      const orders = await Order.find({ restaurantId, tableId, status: { $ne: "completed" } });

      const activeBusinessDay = await getOrCreateActiveBusinessDay(restaurantId);

      // 모든 주문에 대한 총 금액과 아이템 판매 정보를 계산
      let totalSalesIncrement = 0;
      const allItemSales = [];

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

      // Update table status to 'empty'
      await Table.findOneAndUpdate({ restaurantId, tableId }, { $set: { status: "empty" } });

      return res.json({
        message: "All orders completed and table status updated",
        modifiedCount: orders.length,
      });
    } else {
      // Handle the update of a single order
      const order = await Order.findByIdAndUpdate(
        orderId,
        { $set: { status: newStatus } },
        { new: true }
      );

      if (!order) {
        return res.status(404).json({ error: "Order not found" });
      }

      if (newStatus === "completed") {
        const activeBusinessDay = await getOrCreateActiveBusinessDay(order.restaurantId);

        // Update DailySales for single order completion
        await DailySales.findOneAndUpdate(
          {
            restaurantId: order.restaurantId,
            businessDayId: activeBusinessDay._id,
            date: activeBusinessDay.businessDate,
          },
          {
            $inc: { totalSales: order.totalAmount },
            $push: {
              itemSales: {
                $each: order.items.map((item) => ({
                  itemId: item.id,
                  name: item.name,
                  quantity: item.quantity,
                  price: item.price,
                  sales: item.price * item.quantity,
                })),
              },
            },
          },
          { upsert: true, new: true }
        );
      }

      // Get updated queue information
      const updatedQueue = await Order.find({
        restaurantId: order.restaurantId,
        status: { $in: ["pending", "preparing"] },
      }).sort("createdAt");

      return res.json({
        message: "Order updated",
        order,
        updatedQueue,
        meta: {
          businessDayId: activeBusinessDay._id,
          isActive: activeBusinessDay.isActive,
        },
      });
    }
  } catch (error) {
    console.error("Failed to update order(s):", error);
    return res.status(500).json({ error: "Failed to update order(s)", details: error.message });
  }
});

// 손님 주문 생성
router.post("/customer", authenticateCustomer, async (req, res) => {
  try {
    const orderData = req.body;
    console.log("Received customer order data:", JSON.stringify(orderData, null, 2));

    if (!orderData.restaurantId) {
      return res.status(403).json({ error: "Restaurant ID is required" });
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
      return res.status(400).json({ error: "No active business day found for this restaurant" });
    }

    const orderForSaving = {
      restaurantId: orderData.restaurantId,
      businessDayId: activeBusinessDay._id,
      tableId: orderData.tableId,
      items: orderData.items.map(({ id, name, price, quantity, selectedOptions = [] }) => ({
        id,
        name,
        price,
        quantity,
        selectedOptions, // 기본값으로 빈 배열 사용
      })),
      status: "pending",
      totalAmount,
      user: req.user.uid, // Firebase UID
      isComplimentaryOrder: orderData.isComplimentaryOrder || false, // 추가
    };

    console.log("Order data for saving:", JSON.stringify(orderForSaving, null, 2));

    const newOrder = new Order(orderForSaving);

    // Validate the order before saving
    const validationError = newOrder.validateSync();
    if (validationError) {
      console.error("Validation error:", validationError);
      return res.status(400).json({
        error: "Validation failed",
        details: Object.values(validationError.errors).map((err) => ({
          field: err.path,
          message: err.message,
        })),
      });
    }

    const savedOrder = await newOrder.save();
    console.log("Customer order saved successfully:", JSON.stringify(savedOrder, null, 2));

    // req.app.get("io").to(orderData.restaurantId).emit("newOrder", savedOrder);

    return res.status(201).json({ success: true, data: savedOrder });
  } catch (error) {
    console.error("Failed to create customer order:", error);
    if (error.name === "ValidationError") {
      return res.status(400).json({
        error: "Validation failed",
        details: Object.values(error.errors).map((err) => ({
          field: err.path,
          message: err.message,
        })),
      });
    }
    return res.status(500).json({ error: "Failed to create order", details: error.message });
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

    const customerOrders = await Order.find({
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
