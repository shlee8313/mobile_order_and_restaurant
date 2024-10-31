const mongoose = require("mongoose");

const visitSchema = new mongoose.Schema(
  {
    userId: {
      type: String,
      required: true,
    },
    restaurantId: {
      type: String,
      required: true,
    },
    count: {
      type: Number,
      default: 0,
    },
    lastVisitDate: {
      type: Date,
      default: null,
    },
  },
  { timestamps: true }
);

// Compound index on userId and restaurantId for faster queries
visitSchema.index({ userId: 1, restaurantId: 1 }, { unique: true });

module.exports = mongoose.model("Visit", visitSchema);
