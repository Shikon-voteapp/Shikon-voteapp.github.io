'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "14405e1b7536f787d08d8350d58067d1",
"assets/AssetManifest.bin.json": "016fafe36c5e60e17a7aa525a39e4b6d",
"assets/AssetManifest.json": "658c37eae370a6c205ab01e93ef41574",
"assets/assets/%25E2%2585%25A0A.jpeg": "8e77c7f974abce5969b7f20681352761",
"assets/assets/%25E2%2585%25A0B.jpg": "186933f49d69c839ccb68699aa22c476",
"assets/assets/%25E2%2585%25A0D.JPG": "ba49f27afd2925f088d3c8a6c762827c",
"assets/assets/%25E2%2585%25A0E.jpg": "bf7ed272db570d422422f00305c9290a",
"assets/assets/%25E2%2585%25A0F.jpg": "e7ec39c61a78176044936bd780e064dc",
"assets/assets/%25E2%2585%25A0G.jpg": "2ccb2cf04516a57089329cc4c876ab3b",
"assets/assets/%25E2%2585%25A1AC.jpg": "78462fc41f466bd8140fc9706a759f87",
"assets/assets/%25E2%2585%25A2A.jpg": "ecb1f0c6653ad3d53dd21f2ceae66df5",
"assets/assets/%25E2%2585%25A2C.jpg": "61ee302369948984f40089591fa70949",
"assets/assets/%25E2%2585%25A2D.jpeg": "a715b1c4fb7f787ff6805576919c2592",
"assets/assets/%25E2%2585%25A2E.jpg": "67a0d83ffb16e8862654b268982b4f49",
"assets/assets/%25E2%2585%25A2F.jpeg": "485590974f24329238904e71a4a7a795",
"assets/assets/%25E2%2585%25A2G.jpeg": "e1db5543dba189dc6679cb0999f5d442",
"assets/assets/%25E3%2581%258A%25E3%2581%25AA%25E3%2581%2593%25E3%2582%2599%25E3%2581%25A3%25E3%2581%25BB%25E3%2582%259A%25E3%2582%2593%25E3%2580%259C%25E3%2582%258A%25E3%2581%259F%25E3%2583%25BC%25E3%2582%2593%25E3%2581%2599%25E3%2582%2599%25E3%2580%259C%2520-%2520nann.PNG": "1ca273cbc5efbd9ec39c7a32a451885b",
"assets/assets/%25E3%2581%25AF%25E3%2582%258D%25E3%2583%25BC%25E3%2581%2595%25E3%2582%2593%25E3%2581%25A7%25E3%2583%25BC.jpeg": "66e9c212b99a63e80e34d34f87ee3a99",
"assets/assets/%25E3%2581%25BF%25E3%2581%258D%25E3%2581%2588%25E3%2581%25A1%25E3%2582%2583%25E3%2582%2593%25E3%2582%25AF%25E3%2583%25AB%25E3%2583%25BC%25E3%2582%25BA.JPG": "770afdf57c9afc526e4ca4228b5ef6ce",
"assets/assets/%25E3%2581%25BF%25E3%2581%259F%25E3%2582%2589%25E3%2581%2597.jpeg": "d7139cd073bf06d5fe534bffe763768b",
"assets/assets/%25E3%2582%25B5%25E3%2583%2583%25E3%2582%25AB%25E3%2583%25BC%25E9%2583%25A8.jpeg": "b86a95479a0ae0d4e82f6e17cfc2ac13",
"assets/assets/%25E3%2582%25B9%25E3%2582%25AD%25E3%2583%25BC%25E9%2583%25A8.jpg": "2b57ecf32f2a66764267b749aee9c85d",
"assets/assets/%25E3%2583%2580%25E3%2583%25B3%25E3%2582%25B9%25E9%2583%25A8.jpeg": "67fd0eb417f41ec02c088e602625d1aa",
"assets/assets/%25E3%2583%2588%25E3%2583%25AD%25E3%2583%2594%25E3%2582%25AB%25E3%2583%25AB%25E3%2582%25A8%25E3%2582%25B9%25E3%2582%25B1%25E3%2583%25BC%25E3%2583%2597.jpg": "7b190cce1220d0bc783ba9e18f1811b0",
"assets/assets/%25E3%2583%259E%25E3%2582%25B8%25E3%2582%25AB%25E3%2583%25AA%25E3%2583%2583%25E3%2583%2597.png": "716c13cbe1a1d143df4e9c07f2248789",
"assets/assets/%25E3%2583%259E%25E3%2583%25B3%25E3%2583%2589%25E3%2583%25AA%25E3%2583%25B3.jpeg": "198c145c6896c5aa699f116e1066db3c",
"assets/assets/%25E4%25B8%25AD%25EF%25BC%2591%25E5%25AD%25A6%25E5%25B9%25B4%25E5%25B1%2595%25E7%25A4%25BA.jpg": "d572fe3c22dbb5305efcf0b589d356bf",
"assets/assets/%25E4%25B8%25AD2.jpeg": "0b3fd8c42f1c1b65ad8bea35149c445e",
"assets/assets/%25E4%25B8%25AD3.jpg": "c1e992edde57842682f86edc3e08a2ad",
"assets/assets/%25E5%2589%25A3%25E9%2581%2593%25E9%2583%25A8.jpg": "78425f5a7df43cd64c8bf1152623fb76",
"assets/assets/%25E5%258C%2596%25E5%25AD%25A6%25E9%2583%25A8.jpg": "6741cae15233050029262d11d5974a14",
"assets/assets/%25E5%259B%25B3%25E6%259B%25B8%25E7%258F%25AD.jpg": "b16d5f17964136002696f230d3ba1c94",
"assets/assets/%25E5%259C%25B0%25E5%25AD%25A6%25E9%2583%25A8.png": "bbaf074a9c89d7856e488543c3f7d27a",
"assets/assets/%25E5%259C%25B0%25E7%2590%2586%25E7%25A0%2594%25E7%25A9%25B6%25E9%2583%25A8.jpg": "459a83c573b13673e5007e76f73c1166",
"assets/assets/%25E6%2582%25B2%25E9%25B3%25B4%25E3%2581%25AE%25E6%25BA%2596%25E5%2582%2599.jpeg": "6d7d13b9b2c667027a6ae672fe558b69",
"assets/assets/%25E6%2596%2599%25E7%2590%2586%25E7%25A0%2594%25E7%25A9%25B6.jpeg": "eaf5de5c03c9bba23c1f2309047a8500",
"assets/assets/%25E6%2598%25A0%25E7%2594%25BB%25E9%2583%25A8.jpg": "c1e1ea1731762ce5d4b21f24ceb74c82",
"assets/assets/%25E6%259A%2596%25E6%25B5%25B7%25E4%25B8%2596%25E4%25BB%25A3.jpg": "4b74125579d6c8405fcacdb2365d7b2a",
"assets/assets/%25E6%259B%25B8%25E9%2581%2593%25E9%2583%25A8%25E5%25B1%2595%25E7%25A4%25BA.jpg": "737a77cc29afb0e230265c00b849d133",
"assets/assets/%25E6%259B%25B8%25E9%2581%2593%25E9%2583%25A8.jpeg": "9bf15f0d74c3592b97a0b93dead6459b",
"assets/assets/%25E6%259C%2589%25E5%25BF%2597%25E3%2583%2595%25E3%2583%2583%25E3%2583%2588%25E3%2582%25B5%25E3%2583%25AB.jpg": "21306997c96646778da797dcb33d2002",
"assets/assets/%25E6%259C%2589%25E5%25BF%2597%25E6%25BC%2594%25E5%258A%2587%25E9%2583%25A8%25E3%2582%25A4%25E3%2583%25A9%25E3%2582%25B9%25E3%2583%2588%2520-%2520%25E7%2591%259E%25E7%25A9%2582.PNG": "d2994b1bc37e1f900d9ab3f83a1d8f80",
"assets/assets/%25E6%25AD%25B4%25E7%25A0%2594%25EF%25BC%2592%25EF%25BC%2590%25EF%25BC%2592%25EF%25BC%2595%25E6%2596%2587%25E5%258C%2596%25E7%25A5%25AD%25E3%2583%2591%25E3%2583%25B3%25E3%2583%2595%2520-%2520%25E7%2589%25A7%25E9%2587%258E%25E6%25B7%25B3%25E5%25BC%25A5.jpg": "5c865ab89eeb10283c3dcd073cc24eae",
"assets/assets/%25E6%25BC%25AB%25E7%2594%25BB%25E7%25A0%2594%25E7%25A9%25B6.jpeg": "ea25b8a1430cff982fc398f4b381851f",
"assets/assets/%25E7%2589%25A9%25E7%2590%2586%25E9%2583%25A8.jpg": "e5a974f2a72348ab287c64416ef28f59",
"assets/assets/%25E7%2594%259F%25E7%2589%25A9%25E9%2583%25A8.jpg": "643fed311675613f64317de5c647f9ca",
"assets/assets/%25E7%25BE%258E%25E8%25A1%2593%25E9%2583%25A8.PNG": "19fcadd3469948226b9debcac452ff87",
"assets/assets/%25E8%258C%25B6%25E9%2581%2593%25E9%2583%25A8.jpeg": "8893054f9cc8a216696e52c6a3090755",
"assets/assets/%25E9%2589%2584%25E9%2581%2593%25E7%25A0%2594%25E7%25A9%25B6%25E9%2583%25A8.JPG": "c5db240d92832d0ee0c55e9083162aae",
"assets/assets/%25E9%25AB%2598%25E8%25BA%25AB%25E9%2595%25B7%25E3%2581%2598%25E3%2582%2583%25E3%2583%2580%25E3%2583%25A1%25E3%2581%25A7%25E3%2581%2599%25E3%2581%258B.png": "18ab8e1d40e49dea75d1077af89d9241",
"assets/assets/%25E9%25AB%2598II%2520F%2520.png": "a822bf188c0e97e4a3a4829d91f87bab",
"assets/assets/6%25E6%2588%2591%25E5%25A4%25A2chu.jpeg": "ce9254a0a836b6101c41bffed469fd32",
"assets/assets/ESS.jpeg": "479011f8bf88bfa45b4a07fd3e72e08f",
"assets/assets/JRC.jpg": "7fd89d691f902225392f15eddd388259",
"assets/assets/Jupiter.jpeg": "473742d3985922bb4fd64e5d1513f149",
"assets/assets/MBC.jpeg": "c8232fdbeb1dc5c2d9a4d8d4df00b3e9",
"assets/assets/Palette_icon%2520-%2520%25E3%2581%2595%25E3%2581%258F%25E3%2582%2589.jpg": "cb36dba263f4a8e9dc9ab3513b775c8d",
"assets/assets/PapiFleur.jpeg": "161d536315ceaa022e1389bd7dfad6de",
"assets/assets/pixy.jpeg": "e242465fa7dd7e2c45b3fce4d1003310",
"assets/assets/Royal%2520MasqueraDe%2520CaGino.jpeg": "471fe30a35f0abe2dcaa6fd7df84f140",
"assets/assets/sho_setsumei.png": "d64bfe9fcad86758e84b8e30b49438ac",
"assets/assets/youth.PNG": "d5fd448d240157bcf45deb1a7bd29100",
"assets/FontManifest.json": "209e66e2f71c646cc7eb744ea1cea0dc",
"assets/fonts/MaterialIcons-Regular.otf": "5e8439307c7bbf58c28889647c5b7f44",
"assets/NOTICES": "536f0b489ff961cf77eb1a4f75ad6e6e",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/flutter_charts/google_fonts/Comforter-Regular.ttf": "cff123ea94f9032380183b8bbbf30ec1",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "86e461cf471c1640fd2b461ece4589df",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/chromium/canvaskit.js": "34beda9f39eb7d992d46125ca868dc61",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206",
"favicon.png": "6b0b881dca1191ee0650e78ad889bbfb",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"flutter_bootstrap.js": "15dc7a632161964ddd8ede50fbde57db",
"icons/Icon-192.png": "6b0b881dca1191ee0650e78ad889bbfb",
"icons/Icon-512.png": "6b0b881dca1191ee0650e78ad889bbfb",
"icons/Icon-maskable-192.png": "6b0b881dca1191ee0650e78ad889bbfb",
"icons/Icon-maskable-512.png": "6b0b881dca1191ee0650e78ad889bbfb",
"index.html": "97a65b468656563b865c08fbd6f5ca77",
"/": "97a65b468656563b865c08fbd6f5ca77",
"main.dart.js": "f31e351db92d98631cd0c981aba9ac55",
"style.css": "52085ddfc20d1dda153ab71cd0153d20",
"version.json": "2116e2964732126ce9c049d88010a72e",
"web_entrypoint.dart": "2b221105f6c12f9a0207793107cc75ba"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
