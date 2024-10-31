// routes/menuRoutes.js
const express = require("express");
const router = express.Router();
const Menu = require("../models/Menu");
const { authenticate } = require("../middleware/auth");

router.get("/", async (req, res) => {
  // console.log("GET /api/menu request received");
  try {
    const { restaurantId } = req.query;
    console.log("Restaurant ID:", restaurantId);

    if (!restaurantId) {
      console.log("Error: Restaurant ID is missing");
      return res.status(400).json({ error: "Restaurant ID is required" });
    }

    // console.log("Searching for menu with restaurantId:", restaurantId);
    const menu = await Menu.findOne({ restaurantId });

    if (!menu) {
      console.log("Menu not found for restaurantId:", restaurantId);
      return res.status(404).json({ error: "Menu not found for this restaurant" });
    }

    // console.log("Menu found:", menu);
    return res.json(menu);
  } catch (error) {
    console.error("Failed to fetch menu:", error);
    return res.status(500).json({
      error: "Failed to fetch menu",
      details: error.message,
      stack: process.env.NODE_ENV === "development" ? error.stack : undefined,
    });
  }
});

router.get("/edit", authenticate, async (req, res) => {
  try {
    const { restaurantId } = req.query;
    // console.log(restaurantId);
    if (req.user.restaurantId !== restaurantId) {
      return res.status(403).json({ error: "Forbidden" });
    }

    const menu = await Menu.findOne({ restaurantId });
    if (!menu) {
      return res.status(404).json({ error: "Menu not found" });
    }

    return res.json(menu);
  } catch (error) {
    console.error("Failed to fetch menu for editing:", error);
    return res.status(500).json({ error: "Failed to fetch menu" });
  }
});

router.put("/edit", authenticate, async (req, res) => {
  try {
    const { restaurantId, categories } = req.body;

    if (req.user.restaurantId !== restaurantId) {
      return res.status(403).json({ error: "Forbidden" });
    }

    if (!restaurantId || !categories) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    let menu = await Menu.findOne({ restaurantId });
    if (menu) {
      menu.categories = categories;
      await menu.save();
    } else {
      menu = new Menu({ restaurantId, categories });
      await menu.save();
    }

    return res.json(menu);
  } catch (error) {
    console.error("Failed to update menu:", error);
    return res.status(500).json({ error: "Failed to update menu" });
  }
});
router.put("/item/:itemId", authenticate, async (req, res) => {
  try {
    const { itemId } = req.params;
    const { restaurantId, ...itemData } = req.body;

    if (req.user.restaurantId !== restaurantId) {
      return res.status(403).json({ error: "Forbidden" });
    }

    const menu = await Menu.findOne({ restaurantId });
    if (!menu) {
      return res.status(404).json({ error: "Menu not found" });
    }

    let updated = false;
    menu.categories = menu.categories.map((category) => {
      category.items = category.items.map((item) => {
        if (item.id === itemId) {
          updated = true;
          // Update options, discountAmount, and rewardPoints
          return {
            ...item,
            ...itemData,
            options: itemData.options || [],
            discountAmount: itemData.discountAmount,
            rewardPoints: itemData.rewardPoints,
          };
        }
        return item;
      });
      return category;
    });

    if (!updated) {
      return res.status(404).json({ error: "Menu item not found" });
    }

    await menu.save();
    return res.json({ message: "Menu item updated successfully" });
  } catch (error) {
    console.error("Failed to update menu item:", error);
    return res.status(500).json({ error: "Failed to update menu item" });
  }
});
module.exports = router;
