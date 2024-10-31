const express = require("express");
const router = express.Router();
const Visit = require("../models/Visits");
const { authenticate, authenticateCustomer } = require("../middleware/auth");

// Increment visit count (only once per day)
router.post("/increment", authenticateCustomer, async (req, res) => {
  try {
    const { restaurantId } = req.body;
    const userId = req.user.uid;
    const today = new Date();
    today.setHours(0, 0, 0, 0); // Set to the beginning of the day

    let visit = await Visit.findOne({ userId, restaurantId });

    if (visit) {
      if (!visit.lastVisitDate || visit.lastVisitDate < today) {
        // If last visit was before today, increment count and update lastVisitDate
        visit.count += 1;
        visit.lastVisitDate = new Date();
      }
    } else {
      // If no visit record exists, create a new one
      visit = new Visit({
        userId,
        restaurantId,
        count: 1,
        lastVisitDate: new Date(),
      });
    }

    await visit.save();

    res.json({ success: true, data: { count: visit.count, lastVisitDate: visit.lastVisitDate } });
  } catch (error) {
    console.error("Error incrementing visit count:", error);
    res.status(500).json({ success: false, message: "Failed to increment visit count" });
  }
});

// 모바일 유저가 조회. 방문회수
router.get("/customer/:restaurantId", authenticateCustomer, async (req, res) => {
  try {
    const { restaurantId } = req.params;
    const userId = req.user.uid;

    const visit = await Visit.findOne({ userId, restaurantId });

    if (!visit) {
      return res.json({ success: true, data: { count: 0, lastVisitDate: null } });
    }

    res.json({ success: true, data: { count: visit.count, lastVisitDate: visit.lastVisitDate } });
  } catch (error) {
    console.error("Error getting visit count:", error);
    res.status(500).json({ success: false, message: "Failed to get visit count" });
  }
});

// Get visit count for a user in a specific restaurant --restaurant Query
router.get("/:restaurantId", authenticate, async (req, res) => {
  try {
    const { restaurantId } = req.params;
    const userId = req.user.uid;

    const visit = await Visit.findOne({ userId, restaurantId });

    if (!visit) {
      return res.json({ success: true, data: { count: 0, lastVisitDate: null } });
    }

    res.json({ success: true, data: { count: visit.count, lastVisitDate: visit.lastVisitDate } });
  } catch (error) {
    console.error("Error getting visit count:", error);
    res.status(500).json({ success: false, message: "Failed to get visit count" });
  }
});
module.exports = router;
