import http from 'node:http';
import { consoleInfo, firostError, run } from 'firost';

export let __;

const CALLBACK_PATH = '/oauth2callback';

/**
 * Open the consent page in the browser, and wait for Google to redirect the
 * user to a local callback server with the authorization code
 * @param {object} options - Options of the wait
 * @param {string} options.authorizeUrl - Consent page to open
 * @param {number} options.port - Port of the local callback server
 * @returns {Promise<string>} The authorization code
 */
export async function waitForCode(options) {
  const { authorizeUrl, port } = options;

  return await new Promise((resolve, reject) => {
    const server = http.createServer((request, response) => {
      const url = new URL(request.url, `http://localhost:${port}`);
      // Ignore anything but the redirect
      if (!url.pathname.startsWith(CALLBACK_PATH)) {
        response.end();
        return;
      }

      // Close the connection too, or a keep-alive socket would keep the
      // closed server alive
      const headers = { Connection: 'close' };
      server.close();
      const code = url.searchParams.get('code');
      if (!code) {
        response.writeHead(400, headers);
        response.end('Missing authorization code');
        const reason = url.searchParams.get('error') || 'Missing code';
        reject(firostError('GOOGLE_LOGIN_FAILED', reason));
        return;
      }

      response.writeHead(200, headers);
      response.end('Authentication successful. You can close this tab.');
      resolve(code);
    });

    server.on('error', reject);

    // The server must listen before the browser opens, or the redirect has
    // nowhere to land
    server.listen(port, () => {
      __.openBrowser(authorizeUrl).catch(reject);
    });
  });
}

__ = {
  /**
   * Open a url in the default browser
   * @param {string} url - Url to open
   * @returns {Promise} Resolves when the opener command ends
   */
  openBrowser(url) {
    consoleInfo('Opening browser for Google OAuth consent...');
    return run(['xdg-open', url], { detached: true });
  },
};
