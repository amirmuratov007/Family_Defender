const http = require("node:http");
const fs = require("node:fs");
const path = require("node:path");
const analyze = require("./api/analyze");
const health = require("./api/health");

const root = __dirname;
const port = process.env.PORT || 8788;

const mime = {
  ".html": "text/html; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".js": "application/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".webmanifest": "application/manifest+json; charset=utf-8",
  ".svg": "image/svg+xml",
  ".png": "image/png",
  ".jpg": "image/jpeg"
};

const server = http.createServer((req, res) => {
  const url = new URL(req.url, `http://${req.headers.host}`);
  if (url.pathname === "/api/analyze") return analyze(req, res);
  if (url.pathname === "/api/health") return health(req, res);

  const requested = url.pathname === "/" ? "/index.html" : url.pathname;
  const filePath = path.normalize(path.join(root, requested));
  if (!filePath.startsWith(root)) {
    res.writeHead(403);
    res.end("Forbidden");
    return;
  }

  fs.readFile(filePath, (error, data) => {
    if (error) {
      res.writeHead(404);
      res.end("Not found");
      return;
    }
    res.writeHead(200, { "content-type": mime[path.extname(filePath)] || "application/octet-stream" });
    res.end(data);
  });
});

server.listen(port, () => {
  console.log(`Heimdall local server: http://127.0.0.1:${port}`);
});
