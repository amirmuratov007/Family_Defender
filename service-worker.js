const CACHE_NAME = "heimdall-family-protection-v12";
const ASSETS = [
  "./",
  "./index.html",
  "./en.html",
  "./ru.html",
  "./style.css",
  "./network.js",
  "./manifest.webmanifest",
  "./heimdall-logo.svg",
  "./shield-icon.svg",
  "./IPHONE_SETUP_RU.md",
  "./IPHONE_SETUP_EN.md"
];

self.addEventListener("install", event => {
  self.skipWaiting();
  event.waitUntil(caches.open(CACHE_NAME).then(cache => cache.addAll(ASSETS)));
});

self.addEventListener("activate", event => {
  event.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(key => key !== CACHE_NAME).map(key => caches.delete(key))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", event => {
  event.respondWith(
    fetch(event.request)
      .then(response => {
        const copy = response.clone();
        caches.open(CACHE_NAME).then(cache => cache.put(event.request, copy));
        return response;
      })
      .catch(() => caches.match(event.request))
  );
});
