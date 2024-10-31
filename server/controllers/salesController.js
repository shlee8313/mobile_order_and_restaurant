// controllers/salesController.js
const express = require("express");
const router = express.Router();
const Order = require("../models/Order");
const { authenticate } = require("../middleware/auth");

router.get("/", authenticate, async (req, res) => {
  try {
    const { restaurantId, month, year } = req.query;

    if (!restaurantId || !month || !year) {
      return res.status(400).json({ error: "Restaurant ID, month, and year are required" });
    }

    const startDate = new Date(year, month - 1, 1);
    const endDate = new Date(year, month, 0);

    const orders = await Order.find({
      restaurantId,
      status: "completed",
      createdAt: { $gte: startDate, $lte: endDate },
    });

    const salesData = [];
    for (let i = 1; i <= endDate.getDate(); i++) {
      const date = new Date(year, month - 1, i);
      const dailyOrders = orders.filter(
        (order) => order.createdAt.toDateString() === date.toDateString()
      );

      const dailySales = dailyOrders.reduce((sum, order) => sum + order.totalAmount, 0);
      const items = dailyOrders.reduce((acc, order) => {
        order.items.forEach((item) => {
          if (!acc[item.name]) {
            acc[item.name] = { quantity: 0, sales: 0 };
          }
          acc[item.name].quantity += item.quantity;
          acc[item.name].sales += item.price * item.quantity;
        });
        return acc;
      }, {});

      salesData.push({
        date: date.toISOString().split("T")[0],
        totalSales: dailySales,
        items: Object.entries(items).map(([name, data]) => ({
          name,
          quantity: data.quantity,
          sales: data.sales,
        })),
      });
    }

    return res.json(salesData);
  } catch (error) {
    console.error("Failed to fetch sales data:", error);
    return res.status(500).json({ error: "Failed to fetch sales data", details: error.message });
  }
});

router.get("/today", authenticate, async (req, res) => {
  try {
    const { restaurantId } = req.query;

    if (!restaurantId) {
      return res.status(400).json({ error: "Restaurant ID is required" });
    }

    const today = new Date();
    const startOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate());
    const endOfDay = new Date(
      today.getFullYear(),
      today.getMonth(),
      today.getDate(),
      23,
      59,
      59,
      999
    );

    const todayOrders = await Order.find({
      restaurantId,
      status: "completed",
      createdAt: { $gte: startOfDay, $lte: endOfDay },
    });

    const totalSales = todayOrders.reduce((sum, order) => sum + order.totalAmount, 0);

    return res.json({
      date: startOfDay.toISOString().split("T")[0],
      totalSales,
    });
  } catch (error) {
    console.error("Failed to fetch today's sales data:", error);
    return res
      .status(500)
      .json({ error: "Failed to fetch today's sales data", details: error.message });
  }
});

module.exports = router;
