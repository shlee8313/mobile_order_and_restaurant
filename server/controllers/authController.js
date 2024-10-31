const express = require("express");
const router = express.Router();
const Restaurant = require("../models/Restaurant");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcrypt");
const { authenticate } = require("../middleware/auth");

router.post("/register", async (req, res) => {
  try {
    const {
      email,
      password,
      businessName,
      address,
      phoneNumber,
      businessNumber,
      operatingHours,
      tables,
      restaurantId,
      hasTables,
    } = req.body;

    if (
      !email ||
      !password ||
      !businessName ||
      !address ||
      !phoneNumber ||
      !businessNumber ||
      !operatingHours ||
      !restaurantId
    ) {
      return res.status(400).json({ message: "All fields are required" });
    }

    const existingRestaurant = await Restaurant.findOne({ email });
    if (existingRestaurant) {
      return res.status(400).json({ message: "Restaurant already exists" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const newRestaurant = new Restaurant({
      email,
      password: hashedPassword,
      businessName,
      address,
      phoneNumber,
      businessNumber,
      operatingHours,
      tables,
      restaurantId,
      hasTables,
    });

    await newRestaurant.save();

    return res
      .status(201)
      .json({ message: "Restaurant registered successfully", restaurantId: newRestaurant._id });
  } catch (error) {
    console.error("Registration error:", error);
    return res
      .status(500)
      .json({ message: "An error occurred during registration", error: error.message });
  }
});

router.post("/login", async (req, res) => {
  try {
    const { restaurantId, password } = req.body;

    const restaurant = await Restaurant.findOne({ restaurantId });

    if (!restaurant) {
      return res.status(401).json({ message: "Invalid restaurantId or password" });
    }

    const isPasswordValid = await bcrypt.compare(password, restaurant.password);
    if (!isPasswordValid) {
      return res.status(401).json({ message: "Invalid restaurantId or password" });
    }

    const token = jwt.sign(
      { restaurantId: restaurant.restaurantId, _id: restaurant._id },
      process.env.JWT_SECRET_KEY,
      { expiresIn: "1d" }
    );

    const restaurantObject = restaurant.toObject();
    delete restaurantObject.password;

    return res.json({ token, restaurant: restaurantObject });
  } catch (error) {
    console.error("Login error:", error);
    return res.status(500).json({ message: "An error occurred" });
  }
});

router.get("/", authenticate, async (req, res) => {
  const { restaurantId } = req.query;

  if (!restaurantId) {
    return res.status(400).json({ error: "Restaurant ID is required" });
  }

  try {
    const restaurant = await Restaurant.findOne({ restaurantId }).select("-password");
    if (!restaurant) {
      return res.status(404).json({ error: "Restaurant not found" });
    }

    return res.json(restaurant);
  } catch (error) {
    console.error("Failed to fetch restaurant:", error);
    return res.status(500).json({ error: "Failed to fetch restaurant" });
  }
});

module.exports = router;
