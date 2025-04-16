const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const mongoose = require('mongoose');
const User = require('./usermodel'); // Import your user schema

const app = express();
const port = 3000;

app.use(bodyParser.json());
app.use(cors());

// Connect to MongoDB
mongoose.connect('mongodb://localhost/contact_app', { useNewUrlParser: true, useUnifiedTopology: true });
const db = mongoose.connection;
db.on('error', console.error.bind(console, 'MongoDB connection error:'));

// Define your routes here

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});

const jwt = require('jsonwebtoken');

app.post('/login', (req, res) => {
  // Check username and password from request body
  const { username, password } = req.body;
  // Validate username and password (e.g., from MongoDB)
  // If valid, generate JWT token
  const token = jwt.sign({ username }, 'secret_key', { expiresIn: '1h' });
  res.json({ token });
});
