// Source: https://developers.cloudflare.com/workers/tutorials/send-emails-with-resend/
interface Env {
  ASSETS: Fetcher;
  RESEND_API_KEY: string;
}

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    const url = new URL(request.url);

    // Phase 4: stub — returns { ok: true } for any POST to /api/contact
    if (url.pathname === '/api/contact' && request.method === 'POST') {
      return Response.json({ ok: true });
    }

    if (url.pathname === '/api/contact') {
      return Response.json(
        { ok: false, message: 'Method not allowed' },
        { status: 405 }
      );
    }

    // Unknown API path — 404
    if (url.pathname.startsWith('/api/')) {
      return Response.json({ ok: false, message: 'Not found' }, { status: 404 });
    }

    // Fall through to static assets (safety net; should not be reached with run_worker_first: ["/api/*"])
    return env.ASSETS.fetch(request);
  },
} satisfies ExportedHandler<Env>;
