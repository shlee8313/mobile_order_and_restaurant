// models/Menu.js
const mongoose = require("mongoose");

const MenuItemOptionSchema = new mongoose.Schema({
  name: { type: String, required: true }, // 옵션 이름 (예: 설탕추가, 고추빼고)
  choices: [
    {
      name: { type: String, required: true }, // 선택지 이름 (예: 추가, 제거)
      price: { type: Number, default: 0 }, // 선택지에 따른 추가 가격 (없을 경우 0)
      quantity: { type: Number }, // 선택지에 따른 수량 (없을 수 있음)
    },
  ],
  defaultChoice: { type: String }, // 기본 선택값
  isRequired: { type: Boolean, default: false }, // 필수 선택 여부
  isMultiple: { type: Boolean, default: false }, // 다중 선택 가능 여부 추가
});

const MenuItemSchema = new mongoose.Schema({
  id: { type: String, required: true, unique: true },
  name: { type: String, required: true },
  description: { type: String },
  detailedDescription: { type: String }, // 상세 설명 필드 추가
  price: { type: Number, required: true },
  images: [{ type: String }], // Changed from single String to array of Strings
  isVisible: { type: Boolean, default: true },
  isTakeout: { type: Boolean, default: true },
  options: [MenuItemOptionSchema], // 메뉴 옵션 추가
  discountAmount: { type: Number }, // 추가
  rewardPoints: { type: Number }, // 추가
  // selectedOptions: { type: Map, of: [String], default: {} }, // 주석: selectedOptions 필드 추가
});

const MenuSchema = new mongoose.Schema(
  {
    restaurantId: { type: String, required: true, unique: true },
    categories: [
      {
        name: { type: String, required: true },
        items: [MenuItemSchema],
      },
    ],
  },
  { timestamps: true }
);

module.exports = mongoose.model("Menu", MenuSchema);
