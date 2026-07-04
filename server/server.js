import http from 'node:http';

import { generateHybridResponse, getProviderStatus } from './hybrid-service.js';

const port = Number(process.env.PORT ?? 8080);
const requireAuth = process.env.REQUIRE_AUTH === 'true';

function sendJson(res, statusCode, payload) {
  res.writeHead(statusCode, {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  });
  res.end(JSON.stringify(payload));
}

function hasBearerToken(req) {
  const header = req.headers.authorization ?? '';
  return header.toLowerCase().startsWith('bearer ');
}

function rejectWhenAuthMissing(req, res) {
  if (!requireAuth || hasBearerToken(req)) return false;

  sendJson(res, 401, { error: 'missing bearer token' });
  return true;
}

async function readJsonBody(req) {
  const chunks = [];
  for await (const chunk of req) chunks.push(chunk);
  if (chunks.length === 0) return {};

  const raw = Buffer.concat(chunks).toString('utf8');
  return JSON.parse(raw);
}

function sendSystemStatus(res) {
  sendJson(res, 200, {
    ok: true,
    service: 'ari-backend',
    environment: process.env.ENVIRONMENT ?? 'development',
    providers: getProviderStatus(),
    timestamp: new Date().toISOString(),
  });
}

async function handleHybridChat(req, res) {
  if (rejectWhenAuthMissing(req, res)) return;

  const body = await readJsonBody(req);
  const prompt = typeof body.prompt === 'string' ? body.prompt : '';
  if (!prompt.trim()) {
    sendJson(res, 400, { error: 'prompt is required' });
    return;
  }

  try {
    const result = await generateHybridResponse({
      prompt,
      userId: typeof body.userId === 'string' ? body.userId : undefined,
      timestamp: typeof body.timestamp === 'string' ? body.timestamp : undefined,
    });
    sendJson(res, 200, result);
  } catch (error) {
    sendJson(res, 503, {
      error: 'all providers failed',
      detail: error instanceof Error ? error.message : String(error),
    });
  }
}

async function handlePlanActivation(req, res) {
  if (rejectWhenAuthMissing(req, res)) return;

  const body = await readJsonBody(req);
  const planId = typeof body.planId === 'string' ? body.planId : '';
  const transactionId =
    typeof body.transactionId === 'string' ? body.transactionId : '';

  if (!planId || !transactionId) {
    sendJson(res, 400, { error: 'planId and transactionId are required' });
    return;
  }

  sendJson(res, 200, {
    ok: true,
    planId,
    transactionId,
    activatedAt: new Date().toISOString(),
  });
}

const server = http.createServer(async (req, res) => {
  try {
    const url = new URL(req.url ?? '/', `http://${req.headers.host ?? 'localhost'}`);

    if (req.method === 'OPTIONS') {
      sendJson(res, 204, {});
      return;
    }

    if (req.method === 'GET' && url.pathname === '/api/system-status') {
      sendSystemStatus(res);
      return;
    }

    if (req.method === 'POST' && url.pathname === '/api/chat/hybrid') {
      await handleHybridChat(req, res);
      return;
    }

    if (req.method === 'POST' && url.pathname === '/api/paypal/activate-plan') {
      await handlePlanActivation(req, res);
      return;
    }

    sendJson(res, 404, { error: 'not found' });
  } catch (error) {
    sendJson(res, 500, {
      error: 'internal server error',
      detail: error instanceof Error ? error.message : String(error),
    });
  }
});

server.listen(port, '0.0.0.0', () => {
  console.log(`ARI backend listening on port ${port}`);
});
