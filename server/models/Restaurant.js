const mongoose = require("mongoose");
const bcrypt = require("bcrypt");

const restaurantSchema = new mongoose.Schema(
  {
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    restaurantId: { type: String, required: true, unique: true },
    businessName: { type: String, required: true },
    address: { type: String, required: true },
    phoneNumber: { type: String, required: true },
    businessNumber: { type: String, required: true },
    operatingHours: { type: String },
    hasTables: { type: Boolean, required: true },
    tables: { type: Number },
    orders: [{ type: mongoose.Schema.Types.ObjectId, ref: "Order" }],
    quickOrders: [{ type: mongoose.Schema.Types.ObjectId, ref: "QuickOrder" }], // 대문자 'O'로 통일
    // ... 기존 필드들 ...
    totalVisits: { type: Number, default: 0 },
    totalLikes: { type: Number, default: 0 },
    // 추가: 리뷰 참조를 위한 필드
    reviews: [{ type: mongoose.Schema.Types.ObjectId, ref: "Review" }],
    // 새로운 필드: 아바타 및 전체 이미지
    avatarImage: { type: String }, // 아바타 이미지 URL
    coverImage: { type: String }, // 레스토랑 전체 이미지 URL
  },
  { timestamps: true }
);

restaurantSchema.pre("save", async function (next) {
  if (!this.isModified("password")) return next();
  this.password = await bcrypt.hash(this.password, 10);
  next();
});

restaurantSchema.methods.comparePassword = function (password) {
  return bcrypt.compare(password, this.password);
};
// 총 방문 횟수 증가 메서드
restaurantSchema.methods.incrementTotalVisits = function () {
  this.totalVisits += 1;
  return this.save();
};

// 총 좋아요 수 업데이트 메서드
restaurantSchema.methods.updateTotalLikes = function (increment) {
  this.totalLikes += increment ? 1 : -1;
  return this.save();
};
module.exports = mongoose.model("Restaurant", restaurantSchema);
