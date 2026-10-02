const express = require('express');
const app = express();

app.get('/publishing/healthz', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

app.get('/publishing/version', (req, res) => {
  res.json({ imageTag: process.env.IMAGE_TAG || 'dev' });
});

module.exports = app;
