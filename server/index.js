// ES Module
import express from 'express';
import cors from 'cors';
import { Pool } from 'pg';
import dotenv from 'dotenv';
import fs from 'fs';

dotenv.config();

const app = express();
const port = process.env.PORT || 3001;

// Database connection
const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  ssl: {
    ca: fs.readFileSync('../certs/rds.pem').toString(),
  }
});

// Middleware
app.use(cors());
app.use(express.json());

// Test database connection
pool.connect((err, client, release) => {
  if (err) {
    console.error('Error connecting to database:', err.stack);
  } else {
    console.log('Connected to PostgreSQL database');
    release();
  }
});

// Routes
app.get('/api/visitors', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM visitors ORDER BY created_at DESC'
    );
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching visitors:', error);
    res.status(500).json({ error: 'Failed to fetch visitors' });
  }
});

app.post('/api/visitors', async (req, res) => {
  const { name, email, location, message } = req.body;
  
  if (!name || !name.trim()) {
    return res.status(400).json({ error: 'Name is required' });
  }

  try {
    const result = await pool.query(
      'INSERT INTO visitors (name, email, location, message, created_at) VALUES ($1, $2, $3, $4, NOW()) RETURNING *',
      [name.trim(), email?.trim() || null, location?.trim() || null, message?.trim() || null]
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Error creating visitor:', error);
    res.status(500).json({ error: 'Failed to create visitor' });
  }
});

app.get('/api/health', async (req, res) => {
  // Check database connectivity
  try {
    await pool.query('SELECT 1');
    res.json({
      status: 'OK',
      database: 'connected',
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    console.error('Database health check failed:', error);
    res.status(500).json({
      status: 'ERROR',
      database: 'disconnected',
      timestamp: new Date().toISOString(),
      error: error.message,
    });
  }
});

app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});

export default app;