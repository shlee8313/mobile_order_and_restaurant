const mongoose = require("mongoose");
const bcrypt = require("bcrypt");

// UserMeal 스키마를 별도로 정의
const UserMealSchema = new mongoose.Schema({
  restaurantId: { type: String, ref: "Restaurant", required: true },
  date: { type: Date, default: Date.now },
  items: [
    {
      name: { type: String, required: true, trim: true },
      quantity: { type: Number, required: true, min: 1 },
      price: { type: Number, required: true, min: 0 },
    },
  ],
  totalAmount: { type: Number, required: true, min: 0 },
});

const userSchema = new mongoose.Schema(
  {
    uid: {
      // Firebase UID
      type: String,
      required: true,
      unique: true,
    },
    email: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      lowercase: true,
      validate: {
        validator: function (v) {
          return /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(v);
        },
        message: (props) => `${props.value} is not a valid email address!`,
      },
    },
    displayName: { type: String, trim: true },
    photoURL: { type: String, trim: true },
    emailVerified: { type: Boolean, default: false },
    phoneNumber: { type: String, trim: true },
    role: {
      type: String,
      default: "customer",
      enum: ["customer", "admin", "staff"],
    },
    meals: [UserMealSchema],
    visits: [
      {
        restaurant: { type: mongoose.Schema.Types.ObjectId, ref: "Restaurant" },
        count: { type: Number, default: 1 },
      },
    ],
    likedRestaurants: [{ type: mongoose.Schema.Types.ObjectId, ref: "Restaurant" }],
    coupons: [{ type: mongoose.Schema.Types.ObjectId, ref: "Coupon" }],
  },
  { timestamps: true }
);

// password 관련 메서드는 제거 (Firebase에서 처리)

userSchema.virtual("fullName").get(function () {
  return this.displayName || this.email.split("@")[0];
});

// 방문 횟수 증가 메서드
userSchema.methods.incrementVisitCount = function (restaurantId) {
  const visit = this.visits.find((v) => v.restaurant.equals(restaurantId));
  if (visit) {
    visit.count += 1;
  } else {
    this.visits.push({ restaurant: restaurantId, count: 1 });
  }
  return this.save();
};

// 좋아요 토글 메서드
userSchema.methods.toggleLike = function (restaurantId) {
  const index = this.likedRestaurants.indexOf(restaurantId);
  if (index > -1) {
    this.likedRestaurants.splice(index, 1);
  } else {
    this.likedRestaurants.push(restaurantId);
  }
  return this.save();
};

module.exports = mongoose.model("User", userSchema);
