const express = require("express");
const cors = require("cors");
require("dotenv").config();

const app = express();
const EXPRESS_PORT = process.env.EXPRESS_PORT || 3002;
const IS_LOCAL = true // Change if you're on FLIP

// Middleware:

// Enable CORS for all requests
// (This is a sample app, so we'll enable CORS for all origins, but normally you should restrict it to specific origins)
app.use(cors({ credentials: true, origin: "*" }));

// Parse JSON bodies (as sent by API clients)
app.use(express.json());

// Routes:
app.use("/api/people", require("./routes/peopleRoutes"));

app.listen(EXPRESS_PORT, () => {
  if (IS_LOCAL)
    console.log(`Express server running: http://localhost:${EXPRESS_PORT}/`);
  else
    console.log(`Express server running: http://flipX.engr.oregonstate.edu:${EXPRESS_PORT}/`);
});

