import http from 'node:http';
import {
  consoleError,
  consoleInfo,
  consoleSuccess,
  run,
  writeJson,
} from 'firost';
import { google } from 'googleapis';

const clientId = process.env.OROSHI_GOOGLE_CLIENT_ID;
const clientSecret = process.env.OROSHI_GOOGLE_CLIENT_SECRET;
const redirectUri = 'http://localhost:48912/oauth2callback';
const tokenPath = `${process.env.OROSHI_ROOT}/private/config/google/tokens.json`;
const scopes = [
  'https://www.googleapis.com/auth/documents',
  'https://www.googleapis.com/auth/drive.file',
];

if (!clientId || !clientSecret) {
  consoleError(
    'Missing OROSHI_GOOGLE_CLIENT_ID or OROSHI_GOOGLE_CLIENT_SECRET',
  );
  process.exit(1);
}

const oauth2Client = new google.auth.OAuth2(
  clientId,
  clientSecret,
  redirectUri,
);

const authorizeUrl = oauth2Client.generateAuthUrl({
  access_type: 'offline',
  scope: scopes,
  prompt: 'consent',
});

const server = http.createServer(async (request, response) => {
  const url = new URL(request.url, 'http://localhost:48912');
  if (!url.pathname.startsWith('/oauth2callback')) {
    response.end();
    return;
  }

  const code = url.searchParams.get('code');
  if (!code) {
    response.writeHead(400);
    response.end('Missing authorization code');
    return;
  }

  try {
    const { tokens } = await oauth2Client.getToken(code);
    await writeJson(tokens, tokenPath);
    consoleSuccess(`Tokens saved to ${tokenPath}`);
    response.writeHead(200);
    response.end('Authentication successful. You can close this tab.');
  } catch (error) {
    consoleError(`Token exchange failed: ${error.message}`);
    response.writeHead(500);
    response.end('Authentication failed');
  }

  server.close();
});

server.listen(48912, () => {
  consoleInfo('Opening browser for Google OAuth consent...');
  run(['xdg-open', authorizeUrl], { detached: true });
});
