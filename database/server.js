// Originally created by Rachel Pottinger at UBC
// Modified by Kelly Shaw in 2026 for Williams CS335

// This file would be run on a CS machine

const express = require('express')
require('dotenv').config();

const app = express()
const appRouter = require('./appRouter');

const port = process.env.PORT || 5110;

app.use(express.static('public'));  // Serve static files from the 'public' directory
app.use(express.json());             // Parse incoming JSON payloads

// mount the router
app.use('/', appRouter);

app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: err.message || 'Server error' });
});

// The 0.0.0.0 is needed to work over the VPN
app.listen(5110, () => {
  console.log("Server app listening at http://localhost:5110/");
});
