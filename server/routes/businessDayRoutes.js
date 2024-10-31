// routes/businessDayRoutes.js
const express = require("express");
const router = express.Router();
const BusinessDay = require("../models/BusinessDay");
const DailySales = require("../models/DailySales");
const { authenticate, authenticateCustomer } = require("../middleware/auth");
const moment = require("moment-timezone");

const timeZone = "Asia/Seoul";

// Helper function for logging
const logInfo = (message, data) => {
  console.log(`[BusinessDay] ${message}`, JSON.stringify(data, null, 2));
};

// Helper function to get current date and time in KST
const getKoreanNow = () => {
  return moment().tz(timeZone);
};

// 비즈니스 데이 자동 생성 함수 추가
// const getOrCreateActiveBusinessDay = async (restaurantId) => {
//   console.log(`[BusinessDay] Searching for active business day for restaurant: ${restaurantId}`);
//   const now = getKoreanNow();
//   const todayStart = now.clone().startOf("day");

//   let activeBusinessDay = await BusinessDay.findOne({
//     restaurantId,
//     businessDate: todayStart.toDate(),
//     isActive: true,
//   });

//   if (activeBusinessDay) {
//     console.log(`[BusinessDay] Found active business day: ${activeBusinessDay._id}`);
//     return activeBusinessDay;
//   }

//   console.log(`[BusinessDay] No active business day found. Creating a new one.`);

//   try {
//     const newBusinessDay = new BusinessDay({
//       restaurantId,
//       startTime: now.toDate(),
//       businessDate: todayStart.toDate(),
//       isActive: true,
//     });

//     activeBusinessDay = await newBusinessDay.save();
//     console.log(`[BusinessDay] New business day created: ${activeBusinessDay._id}`);
//     return activeBusinessDay;
//   } catch (error) {
//     console.error(`[BusinessDay] Error creating new business day:`, error);
//     throw error;
//   }
// };
/**
 *
 */
router.get("/status", authenticate, async (req, res) => {
  try {
    const { restaurantId } = req.query;
    // console.log("business Day status ", restaurantId);
    const now = getKoreanNow();
    const todayStart = now.clone().startOf("day");

    const businessDay = await BusinessDay.findOne({
      restaurantId,
      businessDate: todayStart.toDate(),
    }).sort({ startTime: -1 });

    if (businessDay) {
      res.status(200).json({
        isActive: businessDay.isActive,
        businessDayId: businessDay._id,
        startTime: businessDay.startTime,
      });
    } else {
      res.status(200).json({
        isActive: false,
        businessDayId: null,
        startTime: null,
      });
    }
  } catch (error) {
    console.error("영업일 상태 확인 중 오류 발생:", error);
    res.status(500).json({ error: "영업일 상태 확인 중 오류가 발생했습니다." });
  }
});
// 영업 시작 또는 계속
router.post("/check-and-start", authenticate, async (req, res) => {
  try {
    const { restaurantId } = req.body;
    const now = getKoreanNow();
    const todayStart = now.clone().startOf("day");

    let businessDay = await BusinessDay.findOne({
      restaurantId,
      businessDate: todayStart.toDate(),
    });

    if (!businessDay) {
      // 오늘 날짜의 BusinessDay가 없는 경우
      return res.status(200).json({
        status: "no_business_day",
        businessDay: null,
        message: "오늘의 영업일이 설정되지 않았습니다. 새로운 영업일을 시작하세요.",
      });
    }

    if (!businessDay.isActive) {
      // 이미 존재하지만 비활성 상태인 경우
      return res.status(200).json({
        status: "inactive_business_day",
        businessDay: businessDay.toObject(),
        message: "영업마감 상태입니다. 영업을 재개하려면 영업마감 해제 버튼을 눌러주세요.",
      });
    }

    // 이미 활성 상태인 경우
    return res.status(200).json({
      status: "active_business_day",
      businessDay: businessDay.toObject(),
      message: "기존 영업일을 계속합니다.",
    });
  } catch (error) {
    console.error("Failed to check business day:", error);
    res.status(500).json({ error: "Failed to check business day" });
  }
});

/**
 *
 */
router.post("/start", authenticate, async (req, res) => {
  try {
    const { restaurantId } = req.body;
    const now = getKoreanNow();
    const todayStart = now.clone().startOf("day");

    // 주석: 이전의 활성화된 영업일을 찾아 종료
    const previousActiveDay = await BusinessDay.findOne({
      restaurantId,
      isActive: true,
      businessDate: { $lt: todayStart.toDate() },
    });

    if (previousActiveDay) {
      previousActiveDay.isActive = false;
      previousActiveDay.endTime = todayStart.toDate();
      await previousActiveDay.save();
    }

    let businessDay = await BusinessDay.findOne({
      restaurantId,
      businessDate: todayStart.toDate(),
    });

    if (businessDay && businessDay.isActive) {
      return res.status(200).json({
        businessDay: {
          ...businessDay.toObject(),
          startTime: businessDay.startTime.toISOString(),
          businessDate: businessDay.businessDate.toISOString(),
        },
        message: "기존 영업일을 계속합니다.",
      });
    }

    if (businessDay) {
      businessDay.isActive = true;
      businessDay.endTime = null;
    } else {
      businessDay = new BusinessDay({
        restaurantId,
        startTime: now.toDate(),
        businessDate: todayStart.toDate(),
        isActive: true,
      });
    }

    await businessDay.save();

    res.status(200).json({
      businessDay: {
        ...businessDay.toObject(),
        startTime: businessDay.startTime.toISOString(),
        businessDate: businessDay.businessDate.toISOString(),
      },
      message: "새로운 영업일이 시작되었습니다.",
    });
  } catch (error) {
    console.error("Failed to start new business day:", error);
    res.status(500).json({ error: "Failed to start new business day" });
  }
});

/**
 *
 */
// Get today's sales
router.get("/sales/today", authenticate, async (req, res) => {
  try {
    const { restaurantId } = req.query;

    logInfo("Fetching today's sales", { restaurantId });

    const activeBusinessDay = await BusinessDay.findOne({
      restaurantId,
      isActive: true,
    });

    if (!activeBusinessDay) {
      logInfo("No active business day found", { restaurantId });
      return res.status(200).json({
        success: true,
        totalSales: 0,
        itemSales: [],
        message: "No active business day found",
      });
    }

    const sales = await DailySales.findOne({
      restaurantId,
      businessDayId: activeBusinessDay._id,
    });

    const response = {
      success: true,
      businessDayId: activeBusinessDay._id,
      startTime: moment(activeBusinessDay.startTime).format("YYYY-MM-DD HH:mm:ss"),
      totalSales: sales ? sales.totalSales : 0,
      itemSales: sales ? sales.itemSales : [],
    };

    logInfo("Today's sales fetched successfully", {
      restaurantId,
      totalSales: response.totalSales,
    });
    res.status(200).json(response);
  } catch (error) {
    console.error("Failed to fetch today's sales:", error);
    res
      .status(500)
      .json({ success: false, error: "Failed to fetch today's sales", details: error.message });
  }
});

// End business day
// 영업 종료
router.post("/end", authenticate, async (req, res) => {
  try {
    const { restaurantId } = req.body;
    const now = moment().tz(timeZone);
    // const now = getKoreanNow();
    // const todayStart = now.clone().startOf("day");
    const businessDay = await BusinessDay.findOne({
      restaurantId,
      isActive: true,
    });

    if (!businessDay) {
      return res.status(400).json({ error: "활성화된 영업일이 없습니다." });
    }

    businessDay.endTime = now.toDate();
    businessDay.isActive = false;
    await businessDay.save();

    res.status(200).json({
      businessDayId: businessDay._id,
      endTime: businessDay.endTime,
      message: "영업이 종료되었습니다.",
    });
  } catch (error) {
    console.error("영업 종료 중 오류 발생:", error);
    res.status(500).json({ error: "영업 종료 중 오류가 발생했습니다." });
  }
});
// 영업 재개
router.post("/cancel-end", authenticate, async (req, res) => {
  try {
    const { restaurantId } = req.body;
    const now = getKoreanNow();
    const todayStart = now.clone().startOf("day");

    const lastEndedBusinessDay = await BusinessDay.findOne({
      restaurantId,
      isActive: false,
      endTime: { $gte: todayStart.toDate() },
    }).sort({ endTime: -1 });

    if (!lastEndedBusinessDay) {
      return res.status(400).json({
        error: "오늘 종료된 영업일이 없습니다. 새로운 영업일을 시작해주세요.",
        businessDay: null,
      });
    }

    lastEndedBusinessDay.isActive = true;
    lastEndedBusinessDay.endTime = null;
    await lastEndedBusinessDay.save();

    res.status(200).json({
      businessDay: lastEndedBusinessDay.toObject(),
      message: "영업마감이 해제되었습니다.",
    });
  } catch (error) {
    console.error("영업마감 해제 중 오류 발생:", error);
    res.status(500).json({
      error: "영업마감 해제 중 오류가 발생했습니다.",
      details: error.message,
    });
  }
});

router.get("/status/customer", authenticateCustomer, async (req, res) => {
  // console.log("여기오냐 buisiness day");
  try {
    const { restaurantId } = req.query;
    console.log("business Day status ", restaurantId);
    const now = getKoreanNow();
    const todayStart = now.clone().startOf("day");

    const businessDay = await BusinessDay.findOne({
      restaurantId,
      businessDate: todayStart.toDate(),
    }).sort({ startTime: -1 });

    if (businessDay) {
      res.status(200).json({
        isActive: businessDay.isActive,
        businessDayId: businessDay._id,
        startTime: businessDay.startTime,
      });
    } else {
      res.status(200).json({
        isActive: false,
        businessDayId: null,
        startTime: null,
      });
    }
  } catch (error) {
    console.error("영업일 상태 확인 중 오류 발생:", error);
    res.status(500).json({ error: "영업일 상태 확인 중 오류가 발생했습니다." });
  }
});
module.exports = router;
