// Get an instance of mysql we can use in the app
const mysql = require("mysql2");
require("dotenv").config();

// Create a 'connection pool' using the provided credentials
const pool = mysql.createPool({
  connectionLimit: 10,
  waitForConnections: true,
  host: process.env.DB_HOST || "localhost",
  user: process.env.DB_USER || "root",
  // password: process.env.DB_PASSWORD || "", // when on your local machine, use your local MySQL password or comment out this line if you don't have a password
  database: process.env.DB_DATABASE || "your_default_database",
  port: 3306,
}).promise();

// Export it for use in our application
module.exports.pool = pool;
