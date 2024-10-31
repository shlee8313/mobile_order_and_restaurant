//file: \server\models\QuickOrder.js

const mongoose = require("mongoose");
// 옵션 스키마

const SelectedOptionSchema = new mongoose.Schema({
  name: { type: String, required: true }, // 옵션 이름 (예: "샷 추가")
  choice: { type: String, required: true }, // 사용자가 선택한 옵션 값 (예: "추가")
  price: { type: Number, default: 0 }, // 선택지에 따른 추가 가격 (없을 경우 0)
  quantity: { type: Number }, // 선택지에 따른 수량 (없을 수 있음)
});
const QuickOrderItemSchema = new mongoose.Schema({
  id: { type: String, required: true },
  name: { type: String, required: true },
  price: { type: Number, required: true },
  quantity: { type: Number, required: true },
  selectedOptions: {
    type: [SelectedOptionSchema], // 옵션 배열
    default: [], // 옵션이 없을 경우 기본값으로 빈 배열
  },
});

const QuickOrderSchema = new mongoose.Schema({
  restaurantId: { type: String, required: true },
  businessDayId: { type: mongoose.Schema.Types.ObjectId, ref: "BusinessDay", required: true },
  orderNumber: { type: Number },
  items: [QuickOrderItemSchema],
  queuePosition: { type: Number, default: 0 },
  status: {
    type: String,
    enum: ["pending", "preparing", "served", "completed"],
    default: "pending",
  },
  totalAmount: { type: Number, required: true },
  isComplimentaryOrder: { type: Boolean, default: false }, // 추가
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now },
  user: { type: String, required: true }, // ObjectId에서 String으로 변경
  fcmToken: { type: String }, // FCM 토큰 필드 추가
});

QuickOrderSchema.pre("save", async function (next) {
  if (this.isNew) {
    const BusinessDay = mongoose.model("BusinessDay");
    let businessDay = await BusinessDay.findById(this.businessDayId);

    if (!businessDay) {
      throw new Error("Business day not found");
    }

    // 해당 비즈니스 데이의 마지막 주문 번호를 가져옵니다.
    const lastOrder = await this.constructor
      .findOne({ businessDayId: this.businessDayId })
      .sort("-orderNumber");

    if (lastOrder) {
      // 같은 비즈니스 데이 내에서는 주문 번호를 증가시킵니다.
      this.orderNumber = lastOrder.orderNumber + 1;
    } else {
      // 새로운 비즈니스 데이의 경우, 주문 번호를 10부터 시작합니다.
      this.orderNumber = 10;
    }

    // BusinessDay 모델에 현재 주문 번호를 업데이트합니다.
    businessDay.currentOrderNumber = this.orderNumber;
    await businessDay.save();
  }
  next();
});

const QuickOrder = mongoose.model("QuickOrder", QuickOrderSchema, "quickOrders");

module.exports = QuickOrder;
