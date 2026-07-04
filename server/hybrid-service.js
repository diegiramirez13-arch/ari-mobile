const systemPrompt =
  'Eres ARI, asistente de productividad en español. ' +
  'Sé conciso, técnico y orientado a la ejecución.';

function getObject(value) {
  return value && typeof value === 'object' ? value : undefined;
}

function getFirstChoice(data) {
  const choices = Array.isArray(data.choices) ? data.choices : [];
  return getObject(choices[0]);
}

function parseOpenAICompatibleText(data) {
  const firstChoice = getFirstChoice(data);
  const message = getObject(firstChoice?.message);
  return typeof message?.content === 'string' ? message.content : 'Sin respuesta';
}

function parseOpenAICompatibleTokens(data) {
  const usage = getObject(data.usage);
  return typeof usage?.total_tokens === 'number' ? usage.total_tokens : undefined;
}

function parseGeminiText(data) {
  const candidates = Array.isArray(data.candidates) ? data.candidates : [];
  const first = getObject(candidates[0]);
  const content = getObject(first?.content);
  const parts = Array.isArray(content?.parts) ? content.parts : [];
  const firstPart = getObject(parts[0]);
  return typeof firstPart?.text === 'string' ? firstPart.text : 'Sin respuesta';
}

const providers = [
  {
    provider: 'openai',
    model: process.env.OPENAI_MODEL ?? 'gpt-4o-mini',
    apiKey: process.env.OPENAI_API_KEY,
    endpoint: 'https://api.openai.com/v1/chat/completions',
    buildBody: (prompt, model) => ({
      model,
      messages: [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: prompt },
      ],
      temperature: 0.7,
      max_tokens: 500,
    }),
    parseText: parseOpenAICompatibleText,
    parseTokens: parseOpenAICompatibleTokens,
  },
  {
    provider: 'kimi',
    model: process.env.KIMI_MODEL ?? 'moonshot-v1-8k',
    apiKey: process.env.KIMI_API_KEY,
    endpoint: 'https://api.moonshot.ai/v1/chat/completions',
    buildBody: (prompt, model) => ({
      model,
      messages: [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: prompt },
      ],
      temperature: 0.7,
      max_tokens: 500,
    }),
    parseText: parseOpenAICompatibleText,
    parseTokens: parseOpenAICompatibleTokens,
  },
  {
    provider: 'gemini',
    model: process.env.GEMINI_MODEL ?? 'gemini-1.5-flash',
    apiKey: process.env.GEMINI_API_KEY,
    buildBody: (prompt) => ({
      contents: [
        {
          parts: [{ text: `${systemPrompt}\n\nUsuario: ${prompt}` }],
        },
      ],
      generationConfig: {
        temperature: 0.7,
        maxOutputTokens: 500,
      },
    }),
    parseText: parseGeminiText,
    parseTokens: () => undefined,
  },
];

function resolveEndpoint(config) {
  if (config.provider !== 'gemini') return config.endpoint;

  const url = new URL(
    `/v1beta/models/${config.model}:generateContent`,
    'https://generativelanguage.googleapis.com',
  );
  url.searchParams.set('key', config.apiKey ?? '');
  return url.toString();
}

async function callProvider(config, prompt) {
  if (!config.apiKey) {
    throw new Error(`${config.provider}: missing API key`);
  }

  const headers = {
    'Content-Type': 'application/json; charset=utf-8',
  };

  if (config.provider !== 'gemini') {
    headers.Authorization = `Bearer ${config.apiKey}`;
  }

  const response = await fetch(resolveEndpoint(config), {
    method: 'POST',
    headers,
    body: JSON.stringify(config.buildBody(prompt, config.model)),
  });

  if (!response.ok) {
    const body = await response.text();
    throw new Error(`${config.provider}: ${response.status} ${body}`);
  }

  const data = await response.json();
  return {
    response: config.parseText(data),
    backend: config.provider,
    model: config.model,
    tokensUsed: config.parseTokens(data),
  };
}

export async function generateHybridResponse(request) {
  const prompt = String(request.prompt ?? '').trim();
  if (!prompt) throw new Error('prompt is required');

  const errors = [];
  for (const provider of providers) {
    try {
      return await callProvider(provider, prompt);
    } catch (error) {
      errors.push(error instanceof Error ? error.message : String(error));
    }
  }

  throw new Error(`all providers failed: ${errors.join(' | ')}`);
}

export function getProviderStatus() {
  return providers.reduce(
    (status, provider) => ({
      ...status,
      [provider.provider]: Boolean(provider.apiKey),
    }),
    {},
  );
}
