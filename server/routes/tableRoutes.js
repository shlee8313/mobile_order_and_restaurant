// routes/tableRoutes.js
const express = require("express");
const router = express.Router();
const Table = require("../models/Table");
const Order = require("../models/Order");
const { authenticate } = require("../middleware/auth");
const mongoose = require("mongoose");
/**
 *
 */
// GET: Retrieve tables and active orders for a restaurant
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
    return res.status(500).json({ error: "Failed to fetch tables", details: error.message });
  }
});

// POST: Create or update a table
router.post("/", authenticate, async (req, res) => {
  try {
    const { restaurantId, tableId, x, y, width, height, status } = req.body;

    if (!restaurantId || !tableId) {
      return res.status(400).json({ error: "restaurantId and tableId are required" });
    }

    console.log("Received table data:", req.body);

    let tableData = {
      restaurantId,
      tableId,
      x,
      y,
      width,
      height,
      status: status || "empty",
    };

    // findOneAndUpdate를 사용하여 upsert 수행
    const savedTable = await Table.findOneAndUpdate({ restaurantId, tableId }, tableData, {
      new: true,
      upsert: true,
      runValidators: true,
    });

    // console.log("Saved table:", savedTable);

    return res.status(201).json({
      message: "Table created/updated successfully",
      table: savedTable,
    });
  } catch (error) {
    console.error("Failed to create/update table:", error);
    if (error.code === 11000) {
      return res.status(409).json({ error: "Duplicate table ID for this restaurant" });
    }
    return res.status(500).json({ error: "Failed to create/update table", details: error.message });
  }
});

/**
 *
 */

// PUT: Update multiple tables for a restaurant
router.put("/", authenticate, async (req, res) => {
  try {
    const { restaurantId, tables } = req.body;

    if (!restaurantId || !tables || !Array.isArray(tables)) {
      return res.status(400).json({ error: "restaurantId and valid tables array are required" });
    }

    const updatedTables = await Promise.all(
      tables.map(async (table) => {
        const updatedTable = await Table.findOneAndUpdate(
          { restaurantId, tableId: table.tableId },
          {
            ...table,
            restaurantId,
            status: table.status || "empty",
          },
          { new: true, upsert: true, runValidators: true, setDefaultsOnInsert: true }
        );
        return updatedTable;
      })
    );

    // Remove tables that are not in the updated list
    await Table.deleteMany({
      restaurantId,
      tableId: { $nin: tables.map((t) => t.tableId) },
    });

    return res.json({ message: "Tables updated successfully", tables: updatedTables });
  } catch (error) {
    console.error("Failed to update tables:", error);
    return res.status(500).json({ error: "Failed to update tables", details: error.message });
  }
});

// PATCH: Update the status of an order and potentially the table
router.patch("/", authenticate, async (req, res, next) => {
  try {
    const { restaurantId, tableId, orderId, newStatus } = req.body;

    if (!restaurantId || !tableId || !orderId || !newStatus) {
      return res.status(400).json({
        error: "Missing required parameters",
        receivedParams: { restaurantId, tableId, orderId, newStatus },
      });
    }

    const order = await Order.findOneAndUpdate(
      { _id: orderId, restaurantId, tableId },
      { $set: { status: newStatus } },
      { new: true }
    );

    if (!order) {
      return res.status(404).json({ error: "Order not found" });
    }

    const allOrders = await Order.find({ restaurantId, tableId, status: { $ne: "completed" } });
    const tableStatus = allOrders.length > 0 ? "occupied" : "empty";
    const table = await Table.findOneAndUpdate(
      { restaurantId, tableId },
      { $set: { status: tableStatus } },
      { new: true }
    );

    if (!table) {
      return res.status(404).json({ error: "Table not found" });
    }

    const responseOrder = {
      ...order.toObject(),
      id: order._id.toString(),
    };

    return res.json({
      message: "Order updated successfully",
      order: responseOrder,
      table,
    });
  } catch (error) {
    console.error("Error in PATCH route:", error);
    next(error);
  }
});

module.exports = router;
