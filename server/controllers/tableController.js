// controllers/tableController.js
const express = require("express");
const router = express.Router();
const Table = require("../models/Table");
const Order = require("../models/Order");
const { authenticate } = require("../middleware/auth");

router.get("/", authenticate, async (req, res) => {
  try {
    const { restaurantId } = req.query;

    if (!restaurantId) {
      return res.status(400).json({ error: "restaurantId is required" });
    }

    const tables = await Table.find({ restaurantId }).sort("tableId").lean();

    const tablesWithOrders = await Promise.all(
      tables.map(async (table) => {
        const activeOrders = await Order.find({
          restaurantId,
          tableId: table.tableId,
          status: { $ne: "completed" },
        }).lean();

        const ordersWithId = activeOrders.map((order) => ({
          ...order,
          id: order._id.toString(),
        }));

        return {
          ...table,
          orders: ordersWithId,
        };
      })
    );

    return res.json(tablesWithOrders);
  } catch (error) {
    console.error("Failed to fetch tables:", error);
    return res.status(500).json({ error: "Failed to fetch tables" });
  }
});

router.post("/", authenticate, async (req, res) => {
  try {
    const { restaurantId, tableId, x, y, width, height, status } = req.body;

    if (!restaurantId || !tableId) {
      return res.status(400).json({ error: "Invalid request data" });
    }

    const updatedTable = await Table.findOneAndUpdate(
      { restaurantId, tableId },
      {
        restaurantId,
        tableId,
        x,
        y,
        width,
        height,
        status: status || "empty",
      },
      { new: true, upsert: true, runValidators: true, setDefaultsOnInsert: true }
    );

    return res.json({
      message: "Table created/updated successfully",
      table: updatedTable,
    });
  } catch (error) {
    console.error("Failed to create/update table:", error);
    if (error.code === 11000) {
      return res.status(409).json({ error: "Duplicate table ID for this restaurant" });
    }
    return res.status(500).json({ error: "Failed to create/update table" });
  }
});

router.put("/", authenticate, async (req, res) => {
  try {
    const { restaurantId, tables } = req.body;

    if (!restaurantId || !tables || !Array.isArray(tables)) {
      return res.status(400).json({ error: "restaurantId and valid tables array are required" });
    }

    await Table.deleteMany({ restaurantId });

    const tablesWithRestaurantId = tables.map((table) => ({
      ...table,
      restaurantId,
      status: table.status || "empty",
    }));

    await Table.insertMany(tablesWithRestaurantId);

    return res.json({ message: "Tables updated successfully" });
  } catch (error) {
    console.error("Failed to update tables:", error);
    return res.status(500).json({ error: "Failed to update tables" });
  }
});

module.exports = router;
