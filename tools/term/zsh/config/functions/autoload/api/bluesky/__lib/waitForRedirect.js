import http from 'node:http';
import { consoleInfo, firostError, run } from 'firost';

export let __;

/**
 * Open the authorization page in the browser, and wait for Bluesky to redirect
 * the user to a local callback server
 * @param {object} options - Options of the wait
 * @param {string} options.authorizeUrl - Authorization page to open
 * @param {number} options.port - Port of the local callback server
 * @returns {Promise<URLSearchParams>} The parameters of the redirect
 */
export async function waitForRedirect(options) {
  const { authorizeUrl, port } = options;

  return await new Promise((resolve, reject) => {
    const server = http.createServer((request, response) => {
      const url = new URL(request.url, `http://127.0.0.1:${port}`);
      // Ignore anything but the redirect
      if (url.pathname !== '/callback') {
        response.end();
        return;
      }

      // Close the connection too, or a keep-alive socket would keep the
      // closed server alive
      const headers = { Connection: 'close' };
      server.close();
      const { searchParams } = url;
      if (searchParams.has('error')) {
        response.writeHead(400, headers);
        response.end('Authentication failed');
        reject(firostError('BLUESKY_LOGIN_FAILED', searchParams.get('error')));
        return;
      }

      response.writeHead(200, headers);
      response.end('Authentication successful. You can close this tab.');
      resolve(searchParams);
    });

    server.on('error', reject);

    // The server must listen before the browser opens, or the redirect has
    // nowhere to land
    server.listen(port, '127.0.0.1', () => {
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
    consoleInfo('Opening browser for Bluesky OAuth consent...');
    return run(['xdg-open', url], { detached: true });
  },
};
