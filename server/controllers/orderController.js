// controllers/orderController.js
const express = require("express");
const router = express.Router();
const Order = require("../models/Order");
const { authenticate } = require("../middleware/auth");

router.get("/", authenticate, async (req, res) => {
  try {
    const { restaurantId, date } = req.query;

    if (!restaurantId) {
      return res.status(400).json({ error: "Restaurant ID is required" });
    }

    if (date) {
      const startOfDay = new Date(date);
      startOfDay.setUTCHours(0, 0, 0, 0);
      const endOfDay = new Date(date);
      endOfDay.setUTCHours(23, 59, 59, 999);

      const orders = await Order.find({
        restaurantId,
        status: "completed",
        createdAt: { $gte: startOfDay, $lt: endOfDay },
      });

      const totalSales = orders.reduce((sum, order) => sum + order.totalAmount, 0);
      return res.json({ date, totalSales });
    } else {
      const activeOrders = await Order.find({
        restaurantId,
        status: { $ne: "completed" },
      }).sort({ createdAt: 1 });
      return res.json(activeOrders);
    }
  } catch (error) {
    console.error("Failed to fetch orders:", error);
    return res.status(500).json({ error: "Failed to fetch orders" });
  }
});

router.post("/", authenticate, async (req, res) => {
  try {
    const orderData = req.body;
    const totalAmount = orderData.items.reduce(
      (total, item) => total + item.price * item.quantity,
      0
    );

    const orderForSaving = {
      restaurantId: orderData.restaurantId,
      tableId: orderData.tableId,
      items: orderData.items.map((item) => ({
        id: item.id,
        name: item.name,
        price: item.price,
        quantity: item.quantity,
      })),
      status: orderData.status,
      totalAmount,
      tempId: orderData.tempId,
    };

    const newOrder = new Order(orderForSaving);
    const savedOrder = await newOrder.save();

    req.app.get("io").to(orderData.restaurantId).emit("newOrder", savedOrder);

    return res.status(201).json(savedOrder);
  } catch (error) {
    console.error("Failed to create order:", error);
    return res.status(500).json({ error: "Failed to create order" });
  }
});

router.patch("/:orderId", authenticate, async (req, res) => {
  try {
    const { orderId } = req.params;
    const { status } = req.body;

    const updatedOrder = await Order.findByIdAndUpdate(orderId, { status }, { new: true });

    if (!updatedOrder) {
      return res.status(404).json({ error: "Order not found" });
    }

    return res.json(updatedOrder);
  } catch (error) {
    console.error("Failed to update order:", error);
    return res.status(500).json({ error: "Failed to update order" });
  }
});

module.exports = router;
