importScripts('https://storage.googleapis.com/workbox-cdn/releases/3.4.1/workbox-sw.js');

workbox.skipWaiting();
workbox.clientsClaim();

// Provide an URL to enable a custom offline page
const OFFLINE_PAGE = "/offline.html";

//Pre-cache the AMP Runtime
self.addEventListener('install', event => {
  const urls = [
    'https://cdn.ampproject.org/v0.js',
    // Add AMP extensions used on your pages
    'https://cdn.ampproject.org/v0/amp-analytics-0.1.js',
    'https://cdn.ampproject.org/v0/amp-ad-0.1.js',
    'https://cdn.ampproject.org/v0/amp-auto-ads-0.1.js',
    'https://cdn.ampproject.org/v0/amp-iframe-0.1.js',
    'https://cdn.ampproject.org/v0/amp-twitter-0.1.js',
    'https://cdn.ampproject.org/v0/amp-web-push-0.1.js',
    'https://cdn.ampproject.org/v0/amp-facebook-like-0.1.js',
    'https://cdn.ampproject.org/v0/amp-addthis-0.1.js',
    'https://cdn.ampproject.org/v0/amp-youtube-0.1.js',
    // Add fonts, icons, logos used on your pages
    'https://fonts.gstatic.com/s/khula/v5/OpNCnoEOns3V7GcPrg7shw.woff2',
    'https://myautisticself.nl/assets/img/logo.png',
    'https://myautisticself.nl/assets/img/profile2.png',
  ];
  if (OFFLINE_PAGE) {
    urls.push(OFFLINE_PAGE);
  }
  event.waitUntil(
    caches.open(workbox.core.cacheNames.runtime).then(cache => cache.addAll(urls))
  );
});

// Enable navigation preload . This is only necessary if navigation routes are not cached,
// see: https://developers.google.com/web/tools/workbox/modules/workbox-navigation-preload
workbox.navigationPreload.enable();

// Fallback to an offline page for navgiation requests if there is no
// network connection
let navigationStrategy;
if (OFFLINE_PAGE) {
  const networkFirstWithOfflinePage = async (args) => {
    const response = await workbox.strategies.networkFirst().handle(args);
    if ( response) {
      return response;
    }
    return caches.match(OFFLINE_PAGE);
  }
  navigationStrategy = networkFirstWithOfflinePage;
} else {
  navigationStrategy = workbox.strategies.networkFirst();
}
const navigationRoute = new workbox.routing.NavigationRoute(navigationStrategy, {
  // Optionally, provide a white/blacklist of RegExps to determine
  // which paths will match this route.
  // whitelist: [],
  // blacklist: [],
});
workbox.routing.registerRoute(navigationRoute);

// By default Use a network first strategy to ensure the latest content is used
workbox.routing.setDefaultHandler(workbox.strategies.networkFirst());

// Serve the AMP Runtime from cache and check for an updated version in the background
workbox.routing.registerRoute(
  /https:\/\/cdn\.ampproject\.org\/.*/,
  workbox.strategies.staleWhileRevalidate()
);

// Cache Images
workbox.routing.registerRoute(
  /\.(?:png|gif|jpg|jpeg|svg|webp)$/,
  workbox.strategies.cacheFirst({
    cacheName: 'images',
    plugins: [
      new workbox.expiration.Plugin({
        maxEntries: 60,
        maxAgeSeconds: 30 * 24 * 60 * 60, // 30 Days
      }),
    ],
  }),
);

// Google Font Caching
// see https://developers.google.com/web/tools/workbox/guides/common-recipes#google_fonts
workbox.routing.registerRoute(
  new RegExp('https://fonts.(?:googleapis|gstatic).com/(.*)'),
  workbox.strategies.cacheFirst({
    cacheName: 'googleapis',
    plugins: [
      new workbox.cacheableResponse.Plugin({
        statuses: [0, 200]
      }),
      new workbox.expiration.Plugin({
        maxEntries: 30,
      }),
    ],
  }),
);
