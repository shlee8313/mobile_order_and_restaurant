//file \routes\userAuthRoutes.js

const express = require("express");
const router = express.Router();
const admin = require("firebase-admin");
const User = require("../models/User");

// Firebase Admin 초기화 (app.js나 별도의 설정 파일에서 해야 함). 모바일 주문하는 유저
// admin.initializeApp();

// Firebase 토큰 검증 미들웨어
const verifyFirebaseToken = async (req, res, next) => {
  const idToken = req.headers.authorization?.split("Bearer ")[1];
  if (!idToken) {
    return res.status(401).json({ message: "No token provided" });
  }

  try {
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    req.user = decodedToken;
    next();
  } catch (error) {
    res.status(401).json({ message: "Invalid token", error: error.message });
  }
};

// Google 또는 Apple 로그인 (Firebase에서 처리 후)
router.post("/auth", verifyFirebaseToken, async (req, res) => {
  try {
    console.log("Received auth request for user:", req.user);
    const { uid, email, name, picture } = req.user;

    console.log("Searching for user with uid:", uid);
    let user = await User.findOne({ uid });
    console.log("User found:", user);

    if (!user) {
      console.log("Creating new user:", { uid, email, name, picture });
      user = new User({
        uid,
        email,
        displayName: name,
        photoURL: picture,
        emailVerified: req.user.email_verified,
      });
      console.log("Saving new user...");
      await user.save();
      console.log("New user created:", user);
    } else {
      console.log("Updating existing user:", uid);
      const updates = {};
      if (name && name !== user.displayName) updates.displayName = name;
      if (picture && picture !== user.photoURL) updates.photoURL = picture;
      if (req.user.email_verified !== user.emailVerified)
        updates.emailVerified = req.user.email_verified;

      console.log("Updates to be applied:", updates);

      if (Object.keys(updates).length > 0) {
        console.log("Applying updates...");
        user = await User.findOneAndUpdate(
          { uid },
          { $set: updates },
          { new: true, runValidators: true }
        );
        console.log("User updated:", user);
      } else {
        console.log("No updates needed for user:", uid);
      }
    }

    res.json({ user });
  } catch (error) {
    console.error("Error in /auth route:", error);
    if (error.name === "ValidationError") {
      return res.status(400).json({ message: "Invalid user data", error: error.message });
    }
    res.status(500).json({ message: "Server error", error: error.message });
  }
});

// 사용자 정보 조회
router.get("/me", verifyFirebaseToken, async (req, res) => {
  try {
    const user = await User.findOne({ uid: req.user.uid });
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
    res.json(user);
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
});

// 사용자 정보 업데이트
router.put("/me", verifyFirebaseToken, async (req, res) => {
  try {
    const user = await User.findOne({ uid: req.user.uid });
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    // 업데이트 가능한 필드들
    const updatableFields = ["displayName", "photoURL", "phoneNumber", "role"];
    updatableFields.forEach((field) => {
      if (req.body[field] !== undefined) {
        user[field] = req.body[field];
      }
    });

    await user.save();
    res.json(user);
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
});

module.exports = router;
