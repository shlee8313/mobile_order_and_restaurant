// models/Table.js
const mongoose = require("mongoose");

const TableSchema = new mongoose.Schema(
  {
    restaurantId: { type: String, required: true },
    tableId: { type: Number, required: true },
    x: { type: Number, required: true },
    y: { type: Number, required: true },
    width: { type: Number, required: true },
    height: { type: Number, required: true },
    status: { type: String, default: "empty" },
    currentOrderId: { type: mongoose.Schema.Types.ObjectId, ref: "Order" },
  },
  { _id: false }
);

TableSchema.index({ restaurantId: 1, tableId: 1 }, { unique: true });

module.exports = mongoose.model("Table", TableSchema);
