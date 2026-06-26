const CACHE_NAME = "heimdall-family-protection-v2";
const ASSETS = ["./", "./index.html", "./en.html", "./ru.html", "./style.css", "./network.js", "./risk.js", "./manifest.webmanifest", "./heimdall-logo.svg", "./shield-icon.svg"];

self.addEventListener("install", event => {
  event.waitUntil(caches.open(CACHE_NAME).then(cache => cache.addAll(ASSETS)));
});

self.addEventListener("fetch", event => {
  event.respondWith(caches.match(event.request).then(cached => cached || fetch(event.request)));
});
