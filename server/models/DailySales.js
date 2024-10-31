// models/DailySales.js
const mongoose = require("mongoose");

const DailySalesSchema = new mongoose.Schema({
  restaurantId: { type: String, required: true },
  businessDayId: { type: mongoose.Schema.Types.ObjectId, ref: "BusinessDay", required: true },
  date: { type: Date, required: true },
  totalSales: { type: Number, default: 0 },
  itemSales: [
    {
      itemId: String,
      name: String,
      quantity: Number,
      price: Number,
      sales: Number, // 추가: 개별 아이템의 총 판매액
    },
  ],
});

// DailySalesSchema.index({ restaurantId: 1, date: 1 }, { unique: true });
DailySalesSchema.index({ restaurantId: 1, businessDayId: 1 }, { unique: true });
const DailySales = mongoose.models.DailySales || mongoose.model("DailySales", DailySalesSchema);

module.exports = DailySales;
