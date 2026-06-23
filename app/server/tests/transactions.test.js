const request = require('supertest');

jest.mock('../db', () => ({ query: jest.fn() }));

const app = require('../index');
const pool = require('../db');

afterEach(() => jest.clearAllMocks());

describe('POST /transactions', () => {
  it('creates a transaction and returns 201', async () => {
    pool.query.mockResolvedValueOnce({
      rows: [{ id: 1, description: 'Pizza', category: 'food', amount: '25.00', created_at: new Date() }],
    });

    const res = await request(app)
      .post('/transactions')
      .send({ description: 'Pizza', category: 'food', amount: 25 });

    expect(res.status).toBe(201);
    expect(res.body.description).toBe('Pizza');
    expect(res.body.category).toBe('food');
    expect(res.body.amount).toBe('25.00');
  });

  it('returns 400 when required fields are missing', async () => {
    const res = await request(app)
      .post('/transactions')
      .send({ category: 'food' });

    expect(res.status).toBe(400);
  });
});

describe('GET /transactions', () => {
  it('returns the list of all transactions', async () => {
    pool.query.mockResolvedValueOnce({
      rows: [
        { id: 1, description: 'Pizza', category: 'food', amount: '25.00', created_at: new Date() },
        { id: 2, description: 'Uber', category: 'transport', amount: '10.00', created_at: new Date() },
      ],
    });

    const res = await request(app).get('/transactions');

    expect(res.status).toBe(200);
    expect(res.body).toHaveLength(2);
  });
});

describe('GET /transactions/summary', () => {
  it('returns spending totals grouped by category', async () => {
    pool.query.mockResolvedValueOnce({
      rows: [
        { category: 'food', total: '150.00' },
        { category: 'transport', total: '45.00' },
      ],
    });

    const res = await request(app).get('/transactions/summary');

    expect(res.status).toBe(200);
    expect(res.body[0].category).toBe('food');
    expect(res.body[0].total).toBe('150.00');
  });
});

describe('DELETE /transactions/:id', () => {
  it('deletes a transaction and returns 204', async () => {
    pool.query.mockResolvedValueOnce({ rows: [{ id: 1 }] });

    const res = await request(app).delete('/transactions/1');

    expect(res.status).toBe(204);
  });

  it('returns 404 when transaction does not exist', async () => {
    pool.query.mockResolvedValueOnce({ rows: [] });

    const res = await request(app).delete('/transactions/999');

    expect(res.status).toBe(404);
  });
});
