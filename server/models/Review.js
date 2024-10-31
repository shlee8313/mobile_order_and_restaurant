const mongoose = require("mongoose");

const reviewSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    restaurantId: { type: String, ref: "Restaurant", required: true },
    rating: { type: Number, required: true, min: 1, max: 5 },
    comment: { type: String, trim: true },
    // 추가: 리뷰 이미지 URL 배열
    images: [{ type: String }],
  },
  { timestamps: true }
);

module.exports = mongoose.model("Review", reviewSchema);
