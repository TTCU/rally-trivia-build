// Source: https://developers.cloudflare.com/workers/tutorials/send-emails-with-resend/
import { Resend } from 'resend';

interface Env {
  ASSETS: Fetcher;
  RESEND_API_KEY: string;
  TURNSTILE_SECRET_KEY: string;
  RECIPIENT_EMAIL: string;
}

interface ContactPayload {
  Name: string;
  Email: string;
  Organization?: string;
  'Event Type'?: string;
  Message?: string;
  turnstileToken: string;
}

function buildEmailHtml(payload: ContactPayload): string {
  const row = (label: string, value: string | undefined) =>
    `<tr>
      <td style="padding: 10px 16px; font-weight: 600; color: #1e3a5f; background: #f0f4f9; width: 140px; vertical-align: top;">${label}</td>
      <td style="padding: 10px 16px; color: #374151; vertical-align: top;">${value || '—'}</td>
    </tr>`;

  return `<!DOCTYPE html>
<html lang="en">
<head><meta charset="UTF-8" /><meta name="viewport" content="width=device-width, initial-scale=1.0" /></head>
<body style="margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; background: #f9fafb;">
  <div style="max-width: 600px; margin: 40px auto; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 1px 3px rgba(0,0,0,0.1);">
    <div style="background: #1e3a5f; padding: 24px 32px;">
      <h1 style="margin: 0; color: white; font-size: 20px; font-weight: 700;">New Demo Request</h1>
      <p style="margin: 4px 0 0; color: #93c5fd; font-size: 14px;">Rally Trivia Contact Form</p>
    </div>
    <div style="padding: 24px 32px;">
      <table style="width: 100%; border-collapse: collapse; border-radius: 6px; overflow: hidden; border: 1px solid #e5e7eb;">
        ${row('Name', payload.Name)}
        ${row('Email', payload.Email)}
        ${row('Organization', payload.Organization)}
        ${row('Event Type', payload['Event Type'])}
        ${row('Message', payload.Message)}
      </table>
    </div>
    <div style="padding: 16px 32px 24px; color: #9ca3af; font-size: 12px;">
      Sent via rallytrivia.com contact form
    </div>
  </div>
</body>
</html>`;
}

async function verifyTurnstile(token: string, secretKey: string): Promise<boolean> {
  const formData = new FormData();
  formData.append('secret', secretKey);
  formData.append('response', token);

  const response = await fetch('https://challenges.cloudflare.com/turnstile/v0/siteverify', {
    method: 'POST',
    body: formData,
  });

  const outcome = (await response.json()) as { success: boolean };
  return outcome.success;
}

const corsHeaders: Record<string, string> = {
  'Access-Control-Allow-Origin': 'http://localhost:4321',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
};

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    const url = new URL(request.url);

    // Handle CORS preflight for /api/contact
    if (url.pathname === '/api/contact' && request.method === 'OPTIONS') {
      return new Response(null, { status: 204, headers: corsHeaders });
    }

    if (url.pathname === '/api/contact' && request.method === 'POST') {
      try {
        const payload = (await request.json()) as ContactPayload;

        // Verify Turnstile token
        const tokenValid = await verifyTurnstile(
          payload.turnstileToken || '',
          env.TURNSTILE_SECRET_KEY
        );

        if (!tokenValid) {
          return Response.json(
            { ok: false, message: 'Verification failed. Please try again.' },
            { status: 400, headers: corsHeaders }
          );
        }

        // Send email via Resend SDK
        const resend = new Resend(env.RESEND_API_KEY);
        const { data, error } = await resend.emails.send({
          from: 'Rally Trivia <contact@rallytrivia.com>',
          to: [env.RECIPIENT_EMAIL],
          subject: `Demo Request from ${payload.Name}`,
          html: buildEmailHtml(payload),
        });

        if (error) {
          console.error('Resend error:', error);
          return Response.json(
            { ok: false, message: 'Something went wrong. Please try again.' },
            { status: 500, headers: corsHeaders }
          );
        }

        return Response.json({ ok: true }, { headers: corsHeaders });
      } catch (err) {
        console.error('Unexpected error:', err);
        return Response.json(
          { ok: false, message: 'Something went wrong. Please try again.' },
          { status: 500, headers: corsHeaders }
        );
      }
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
