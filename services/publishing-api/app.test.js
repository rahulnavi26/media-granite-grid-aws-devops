const request = require('supertest');
const app = require('./app');

describe('publishing-api', () => {
  test('GET /publishing/healthz returns 200', async () => {
    const res = await request(app).get('/publishing/healthz');
    expect(res.statusCode).toBe(200);
  });

  test('GET /publishing/version returns an imageTag', async () => {
    const res = await request(app).get('/publishing/version');
    expect(res.body).toHaveProperty('imageTag');
  });
});
