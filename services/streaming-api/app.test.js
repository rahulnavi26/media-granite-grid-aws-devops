const request = require('supertest');
const app = require('./app');

describe('streaming-api', () => {
  test('GET /streaming/healthz returns 200', async () => {
    const res = await request(app).get('/streaming/healthz');
    expect(res.statusCode).toBe(200);
  });

  test('GET /streaming/version returns an imageTag', async () => {
    const res = await request(app).get('/streaming/version');
    expect(res.body).toHaveProperty('imageTag');
  });
});
