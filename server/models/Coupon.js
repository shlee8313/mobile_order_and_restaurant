const mongoose = require("mongoose");

const couponSchema = new mongoose.Schema(
  {
    code: { type: String, required: true, unique: true },
    description: { type: String, required: true },
    discountType: { type: String, enum: ["percentage", "fixed"], required: true },
    discountValue: { type: Number, required: true },
    minPurchase: { type: Number, default: 0 },
    maxDiscount: { type: Number },
    startDate: { type: Date, required: true },
    endDate: { type: Date, required: true },
    isActive: { type: Boolean, default: true },
    usageLimit: { type: Number, default: 1 },
    usedCount: { type: Number, default: 0 },
    restaurantId: { type: String, ref: "Restaurant" },
    // 특정 메뉴 항목에만 적용되는 쿠폰인 경우
    applicableItems: [{ type: String }],
  },
  { timestamps: true }
);

module.exports = mongoose.model("Coupon", couponSchema);
