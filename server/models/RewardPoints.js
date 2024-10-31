// models/RewardPoints.js
const mongoose = require("mongoose");
const { v4: uuidv4 } = require("uuid");

// RewardPoints Schema 정의
const RewardPointsSchema = new mongoose.Schema({
  id: { type: String, default: uuidv4, unique: true }, // UUID로 고유 식별자 생성
  userId: { type: String, required: true }, // 사용자 ID
  restaurantId: { type: String, required: true }, // 레스토랑 ID
  points: { type: Number, default: 0 }, // 포인트, 기본값 0
  expirationDate: { type: Date, required: true }, // 포인트 만료일
});

// 포인트 추가 메서드
RewardPointsSchema.methods.addPoints = function (amount) {
  this.points += amount;
  return this.save(); // 포인트를 추가하고 저장
};

// 포인트 사용 메서드
RewardPointsSchema.methods.usePoints = function (amount) {
  if (this.points >= amount) {
    this.points -= amount;
    return this.save(); // 포인트 차감 후 저장
  }
  return false; // 포인트가 부족할 경우 false 반환
};

module.exports = mongoose.model("RewardPoints", RewardPointsSchema);
