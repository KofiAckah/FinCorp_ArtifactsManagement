const express = require('express');
const pool = require('./db');

const router = express.Router();

router.post('/', async (req, res) => {
  const { description, category, amount } = req.body;
  if (!description || !category || amount == null) {
    return res.status(400).json({ error: 'description, category and amount are required' });
  }
  try {
    const result = await pool.query(
      'INSERT INTO transactions (description, category, amount) VALUES ($1, $2, $3) RETURNING *',
      [description, category, amount]
    );
    res.status(201).json(result.rows[0]);
  } catch {
    res.status(500).json({ error: 'Database error' });
  }
});

router.get('/', async (_req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM transactions ORDER BY created_at DESC'
    );
    res.json(result.rows);
  } catch {
    res.status(500).json({ error: 'Database error' });
  }
});

router.get('/summary', async (_req, res) => {
  try {
    const result = await pool.query(
      'SELECT category, SUM(amount) AS total FROM transactions GROUP BY category ORDER BY total DESC'
    );
    res.json(result.rows);
  } catch {
    res.status(500).json({ error: 'Database error' });
  }
});

router.delete('/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query(
      'DELETE FROM transactions WHERE id = $1 RETURNING id',
      [id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Transaction not found' });
    }
    res.status(204).send();
  } catch {
    res.status(500).json({ error: 'Database error' });
  }
});

module.exports = router;
