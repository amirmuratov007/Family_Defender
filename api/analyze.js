const { analyzeRisk } = require("../lib/risk-engine");

module.exports = function handler(req, res) {
  if (req.method !== "POST") {
    res.statusCode = 405;
    res.setHeader("content-type", "application/json");
    res.end(JSON.stringify({ error: "Method not allowed" }));
    return;
  }

  let body = "";
  req.on("data", chunk => {
    body += chunk;
    if (body.length > 100000) req.destroy();
  });
  req.on("end", () => {
    try {
      const payload = body ? JSON.parse(body) : {};
      const result = analyzeRisk(payload.text || "");
      res.statusCode = 200;
      res.setHeader("content-type", "application/json");
      res.end(JSON.stringify(result));
    } catch (error) {
      res.statusCode = 400;
      res.setHeader("content-type", "application/json");
      res.end(JSON.stringify({ error: "Invalid JSON" }));
    }
  });
};
