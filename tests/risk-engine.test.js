const assert = require("node:assert/strict");
const { analyzeRisk } = require("../lib/risk-engine");

const dangerous = analyzeRisk("Перейдем в телеграм. Родителям не говори. Срочно открой банк и пришли код из смс.");
assert.equal(dangerous.level, "critical");
assert.ok(dangerous.score >= 75);
assert.ok(dangerous.matches.some(match => match.id === "code"));
assert.ok(dangerous.matches.some(match => match.id === "money"));

const safe = analyzeRisk("Тренировка завтра в 16:00, домашку скинут в школьный чат.");
assert.equal(safe.level, "low");
assert.equal(safe.score, 0);

const locationRequest = analyzeRisk("Пришли мне координаты, где ты сейчас.");
assert.equal(locationRequest.level, "high");
assert.ok(locationRequest.score >= 70);
assert.ok(locationRequest.matches.some(match => match.id === "location_request"));

console.log("risk-engine tests passed");
