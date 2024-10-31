// file: \server\routes\salesRoutes.js
const express = require("express");
const router = express.Router();
const BusinessDay = require("../models/BusinessDay"); // 새로운 모델 추가
const DailySales = require("../models/DailySales");
const { authenticate } = require("../middleware/auth");
const moment = require("moment-timezone");

const timeZone = "Asia/Seoul";

// Helper function to convert Korean time to UTC
const toUTCDate = (date) => moment.tz(date, timeZone).utc().toDate();
// Helper function to convert UTC to Korean time
const toKoreanDate = (date) => moment.utc(date).tz(timeZone).toDate();
// Helper function to get the start of the day in KST
const getStartOfDayKST = (date) => moment(date).startOf("day").tz(timeZone).toDate();
// Helper function to get the end of the day in KST
const getEndOfDayKST = (date) => moment(date).endOf("day").tz(timeZone).toDate();

router.get("/", authenticate, async (req, res) => {
  try {
    const { restaurantId, month, year } = req.query;

    if (!restaurantId || !month || !year) {
      return res.status(400).json({ error: "Restaurant ID, month, and year are required" });
    }

    // 날짜 형식을 ISO 8601 표준에 맞게 수정
    const startDate = moment.tz(`${year}-${month.padStart(2, "0")}-01`, timeZone).startOf("month");
    const endDate = startDate.clone().endOf("month");

    // const businessDays = await BusinessDay.find({
    //   restaurantId,
    //   businessDate: { $gte: startDate.toDate(), $lte: endDate.toDate() },
    // }).sort("businessDate");

    // const salesData = await DailySales.find({
    //   businessDayId: { $in: businessDays.map((bd) => bd._id) },
    // });
    const businessDays = await BusinessDay.find({
      restaurantId,
      businessDate: { $gte: startDate.toDate(), $lte: endDate.toDate() },
    }).sort("businessDate");
    console.log("Sales Route businessDays", businessDays);
    const salesData = await DailySales.find({
      businessDayId: { $in: businessDays.map((bd) => bd._id) },
    });

    const fullSalesData = businessDays.map((businessDay) => {
      const sales = salesData.find(
        (sale) => sale.businessDayId.toString() === businessDay._id.toString()
      );

      return {
        date: moment(businessDay.businessDate).tz(timeZone).format("YYYY-MM-DD"),
        businessDayId: businessDay._id.toString(),
        _id: businessDay._id.toString(),
        restaurantId: businessDay.restaurantId,
        startTime: moment(businessDay.startTime).tz(timeZone).format(),
        endTime: businessDay.endTime ? moment(businessDay.endTime).tz(timeZone).format() : null,
        businessDate: moment(businessDay.businessDate).tz(timeZone).format("YYYY-MM-DD"),
        isActive: businessDay.isActive,
        totalSales: sales ? sales.totalSales : 0,
        itemSales: sales ? sales.itemSales : [],
      };
    });

    console.log("Full sales data:", JSON.stringify(fullSalesData, null, 2));

    return res.json(fullSalesData);
  } catch (error) {
    console.error("Failed to fetch sales data:", error);
    return res.status(500).json({ error: "Failed to fetch sales data", details: error.message });
  }
});

router.get("/today", authenticate, async (req, res) => {
  try {
    const { restaurantId } = req.query;
    if (!restaurantId) {
      return res.status(400).json({ error: "Restaurant ID is required" });
    }

    // Get current time in Korean time zone
    const now = moment().tz(timeZone);

    console.log("Fetching today's sales for restaurant:", restaurantId);

    // Find the active business day
    // const activeBusinessDay = await BusinessDay.findOne({
    //   restaurantId,
    //   isActive: true,
    // });
    const activeBusinessDay = await BusinessDay.findOne({
      restaurantId,
      businessDate: {
        $gte: now.clone().startOf("day").toDate(),
        $lte: now.clone().endOf("day").toDate(),
      },
      isActive: true,
    });
    if (!activeBusinessDay) {
      return res.json({
        date: now.format("YYYY-MM-DD"),
        totalSales: 0,
        meta: { businessDayId: null },
      });
    }

    // Find sales for the active business day
    const todaySales = await DailySales.findOne({
      restaurantId,
      businessDayId: activeBusinessDay._id,
    });

    console.log("Today's sales:", todaySales?.totalSales || 0);

    return res.json({
      date: moment(activeBusinessDay.businessDate).format("YYYY-MM-DD"),
      totalSales: todaySales ? todaySales.totalSales : 0,
      meta: { businessDayId: activeBusinessDay._id },
    });
  } catch (error) {
    console.error("Failed to fetch today's sales data:", error);
    return res
      .status(500)
      .json({ error: "Failed to fetch today's sales data", details: error.message });
  }
});
// router.get("/today", authenticate, async (req, res) => {
//   try {
//     const { restaurantId } = req.query;
//     if (!restaurantId) {
//       return res.status(400).json({ error: "Restaurant ID is required" });
//     }

//     // Get current time in Korean time zone
//     const now = moment().tz(timeZone);
//     // Calculate start and end of today in UTC
//     const todayStart = toUTCDate(getStartOfDayKST(now));
//     const todayEnd = toUTCDate(getEndOfDayKST(now));

//     console.log("Fetching today's sales for restaurant:", restaurantId);

//     const todaySales = await DailySales.findOne({
//       restaurantId,
//       date: { $gte: todayStart, $lte: todayEnd },
//     });

//     console.log("Today's sales:", todaySales?.totalSales || 0);

//     // return res.json({
//     //   date: now.format("YYYY-MM-DD"),
//     //   totalSales: todaySales ? todaySales.totalSales : 0,
//     // });
//     const businessDay = await BusinessDay.findOne({
//       restaurantId,
//       businessDate: { $gte: todayStart, $lte: todayEnd },
//     });

//     return res.json({
//       date: now.format("YYYY-MM-DD"),
//       totalSales: todaySales ? todaySales.totalSales : 0,
//       meta: {
//         businessDayId: businessDay ? businessDay._id : null,
//       },
//     });
//   } catch (error) {
//     console.error("Failed to fetch today's sales data:", error);
//     return res
//       .status(500)
//       .json({ error: "Failed to fetch today's sales data", details: error.message });
//   }
// });

module.exports = router;
