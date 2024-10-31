//file: \server\models\Order.js

const mongoose = require("mongoose");
// 옵션 스키마
// 옵션 스키마
const SelectedOptionSchema = new mongoose.Schema({
  name: { type: String, required: true }, // 옵션 이름 (예: "샷 추가")
  choice: { type: String, required: true }, // 사용자가 선택한 옵션 값 (예: "추가")
  price: { type: Number, default: 0 }, // 선택지에 따른 추가 가격 (없을 경우 0)
  quantity: { type: Number }, // 선택지에 따른 수량 (없을 수 있음)
});

const OrderItemSchema = new mongoose.Schema({
  id: { type: String, required: true },
  name: { type: String, required: true },
  price: { type: Number, required: true },
  quantity: { type: Number, required: true },
  selectedOptions: {
    type: [SelectedOptionSchema], // 옵션 배열
    default: [], // 옵션이 없을 경우 기본값으로 빈 배열
  },
});

const OrderSchema = new mongoose.Schema({
  restaurantId: { type: String, required: true },
  businessDayId: { type: mongoose.Schema.Types.ObjectId, ref: "BusinessDay", required: true }, // 추가된 부분
  tableId: { type: Number, required: true },
  items: [OrderItemSchema],
  status: {
    type: String,
    enum: ["pending", "preparing", "served", "completed"],
    default: "pending",
  },
  isComplimentaryOrder: { type: Boolean, default: false },
  totalAmount: { type: Number, required: true },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now },
  user: { type: String, required: true }, // ObjectId에서 String으로 변경
});

// pre-save 훅 수정 (businessDayId 관련 로직 추가)
OrderSchema.pre("save", async function (next) {
  if (this.isNew) {
    const Restaurant = mongoose.model("Restaurant");
    const BusinessDay = mongoose.model("BusinessDay");

    const restaurant = await Restaurant.findOne({ restaurantId: this.restaurantId });

    if (!restaurant) {
      throw new Error("Restaurant not found");
    }

    if (!restaurant.hasTables) {
      throw new Error("This order model is for restaurants with tables only");
    }

    // businessDayId가 유효한지 확인
    const businessDay = await BusinessDay.findById(this.businessDayId);
    if (!businessDay) {
      throw new Error("Business day not found");
    }

    // 필요한 경우 여기에 추가 로직을 구현할 수 있습니다.
    // 예: 주문 번호 생성, BusinessDay 모델 업데이트 등
  }
  next();
});

module.exports = mongoose.model("Order", OrderSchema);
