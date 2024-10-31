// //file: \server\middleware\auth.js

// const jwt = require("jsonwebtoken");

// const authenticate = (req, res, next) => {
//   const authHeader = req.headers.authorization;

//   if (!authHeader) {
//     return res.status(401).json({ error: "Authorization header is missing" });
//   }

//   const parts = authHeader.split(" ");

//   if (parts.length !== 2 || parts[0] !== "Bearer") {
//     return res.status(401).json({ error: "Token format is invalid" });
//   }

//   const token = parts[1];

//   try {
//     const decoded = jwt.verify(token, process.env.JWT_SECRET_KEY);
//     req.user = decoded;
//     next();
//   } catch (error) {
//     if (error.name === "TokenExpiredError") {
//       return res.status(401).json({ error: "Token has expired" });
//     }
//     return res.status(401).json({ error: "Invalid token" });
//   }
// };

// module.exports = { authenticate };

//file: \server\middleware\auth.js

const jwt = require("jsonwebtoken");
const admin = require("firebase-admin");

const authenticate = (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return res.status(401).json({ error: "Authorization header is missing" });
  }

  const parts = authHeader.split(" ");

  if (parts.length !== 2 || parts[0] !== "Bearer") {
    return res.status(401).json({ error: "Token format is invalid" });
  }

  const token = parts[1];

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET_KEY);
    req.user = decoded;
    req.userType = "restaurant";
    next();
  } catch (error) {
    if (error.name === "TokenExpiredError") {
      return res.status(401).json({ error: "Token has expired" });
    }
    return res.status(401).json({ error: "Invalid token" });
  }
};

const authenticateCustomer = async (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return res.status(401).json({ error: "Authorization header is missing" });
  }

  const parts = authHeader.split(" ");

  if (parts.length !== 2 || parts[0] !== "Bearer") {
    return res.status(401).json({ error: "Token format is invalid" });
  }

  const token = parts[1];

  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    req.user = decodedToken;
    req.userType = "customer";
    next();
  } catch (error) {
    console.error("Error verifying token:", error);
    return res.status(401).json({ error: "Invalid token" });
  }
};

module.exports = { authenticate, authenticateCustomer };
