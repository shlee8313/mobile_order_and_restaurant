const express = require("express");
const router = express.Router();
const Restaurant = require("../models/Restaurant");
const { authenticate } = require("../middleware/auth");

/**
 * @route   GET /api/restaurants
 * @desc    Get a list of all restaurants or a specific restaurant
 * @access  Public
 */
router.get("/", async (req, res) => {
  try {
    const { restaurantId } = req.query;
    console.log("레스토랑 조회", restaurantId);
    // 특정 레스토랑 조회
    if (restaurantId) {
      const restaurant = await Restaurant.findOne({ restaurantId });
      if (!restaurant) {
        return res.status(404).json({ error: "Restaurant not found" });
      }
      return res.json(restaurant);
    }

    // 전체 레스토랑 목록 조회
    const restaurants = await Restaurant.find();
    return res.json(restaurants);
  } catch (error) {
    console.error("Failed to fetch restaurants:", error);
    return res.status(500).json({ error: "Failed to fetch restaurants" });
  }
});

module.exports = router;
