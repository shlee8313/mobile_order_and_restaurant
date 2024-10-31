// models/BusinessDay.js
const mongoose = require("mongoose");
const moment = require("moment-timezone");
const BusinessDaySchema = new mongoose.Schema({
  restaurantId: { type: String, required: true },

  startTime: { type: Date, required: true },
  endTime: { type: Date },
  isActive: { type: Boolean, default: true },
  businessDate: { type: Date, required: true },
});

BusinessDaySchema.index({ restaurantId: 1, businessDate: 1 }, { unique: true });

module.exports = mongoose.model("BusinessDay", BusinessDaySchema);
