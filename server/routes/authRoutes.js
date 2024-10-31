// routes/authRoutes.js
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

    // 중복 체크
    const emailExists = await Restaurant.findOne({ email });
    const restaurantIdExists = await Restaurant.findOne({ restaurantId });
    const businessNumberExists = await Restaurant.findOne({ businessNumber });

    if (emailExists) {
      return res.status(400).json({ message: "Email already exists" });
    }
    if (restaurantIdExists) {
      return res.status(400).json({ message: "Restaurant ID already exists" });
    }
    if (businessNumberExists) {
      return res.status(400).json({ message: "Business Number already exists" });
    }

    // const hashedPassword = await bcrypt.hash(password, 10);
    const newRestaurant = new Restaurant({
      email,
      password, // 해싱되지 않은 원본 비밀번호를 그대로 전달
      businessName,
      address,
      phoneNumber,
      businessNumber,
      operatingHours,
      tables,
      restaurantId,
      hasTables,
    });
    // console.log("register newRestaurant", newRestaurant);
    await newRestaurant.save(); // pre('save') 미들웨어에서 비밀번호 해싱
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
    // console.log("Login attempt for restaurantId:", restaurantId);
    // console.log("Received password length:", password.length);

    const restaurant = await Restaurant.findOne({ restaurantId });
    if (!restaurant) {
      console.log("Restaurant not found for restaurantId:", restaurantId);
      return res.status(401).json({ message: "Invalid restaurantId or password" });
    }

    // console.log("Restaurant found:", restaurant);
    // console.log("Stored hashed password:", restaurant.password);

    const isPasswordValid = await restaurant.comparePassword(password);
    // console.log("Password validation result:", isPasswordValid);

    if (!isPasswordValid) {
      console.log("Invalid password for restaurantId:", restaurantId);
      return res.status(401).json({ message: "Invalid restaurantId or password" });
    }

    const token = jwt.sign(
      { restaurantId: restaurant.restaurantId, _id: restaurant._id },
      process.env.JWT_SECRET_KEY,
      { expiresIn: "1d" }
    );

    const restaurantObject = restaurant.toObject();
    delete restaurantObject.password;

    // console.log("Login successful for restaurantId:", restaurantId);
    return res.json({ token, restaurant: restaurantObject });
  } catch (error) {
    console.error("Login error:", error);
    return res
      .status(500)
      .json({ message: "An error occurred during login", error: error.message });
  }
});
/**
 *
 */

router.get("/validate-token", authenticate, async (req, res) => {
  try {
    const restaurant = await Restaurant.findOne({ _id: req.user._id }).select("-password");
    if (!restaurant) {
      return res.status(404).json({ message: "Restaurant not found" });
    }
    return res.json({ valid: true, restaurant });
  } catch (error) {
    console.error("Token validation error:", error);
    return res.status(500).json({ message: "An error occurred during token validation" });
  }
});

router.get("/", authenticate, async (req, res) => {
  try {
    const restaurant = await Restaurant.findOne({ _id: req.user._id }).select("-password");
    if (!restaurant) {
      return res.status(404).json({ error: "Restaurant not found" });
    }
    return res.json(restaurant);
  } catch (error) {
    console.error("Failed to fetch restaurant:", error);
    return res.status(500).json({ error: "Failed to fetch restaurant" });
  }
});

// 중복 체크를 위한 새로운 엔드포인트
router.get("/check-duplicate", async (req, res) => {
  try {
    const { field, value } = req.query;
    if (!field || !value) {
      return res.status(400).json({ message: "Field and value are required" });
    }

    const query = { [field]: value };
    const existingRestaurant = await Restaurant.findOne(query);

    res.json({ isDuplicate: !!existingRestaurant });
  } catch (error) {
    console.error("Duplicate check error:", error);
    res.status(500).json({ message: "An error occurred during duplicate check" });
  }
});
// 추가: 토큰 갱신 라우트
router.post("/refresh-token", authenticate, async (req, res) => {
  try {
    const restaurant = await Restaurant.findOne({ _id: req.user._id });
    if (!restaurant) {
      return res.status(404).json({ message: "Restaurant not found" });
    }

    const newToken = jwt.sign(
      { restaurantId: restaurant.restaurantId, _id: restaurant._id },
      process.env.JWT_SECRET_KEY,
      { expiresIn: "1d" }
    );

    return res.json({ token: newToken });
  } catch (error) {
    console.error("Token refresh error:", error);
    return res.status(500).json({ message: "An error occurred during token refresh" });
  }
});
module.exports = router;
