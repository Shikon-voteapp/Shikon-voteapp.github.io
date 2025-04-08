'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "d4b5e227c73ff107d48451b0dd5cdb5d",
"assets/AssetManifest.bin.json": "0d40bc3c6a721f76bac88f180bc8baa7",
"assets/AssetManifest.json": "197b25a95494e4b08506a2d5a18b3300",
"assets/assets/First/Art_Room_1.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/First/Art_Room_2.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/First/Chori_Room.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/First/Hifuku_Room.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/First/Music_Room.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/First/N101.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/First/N102.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/First/N103.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/First/N104.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/First/N105.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/First/S101.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/First/S102.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/First/S103.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/First/S104.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/First/S105.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/First/T101.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/First/T102.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/First/Technology_Room.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/IBMPlexSansJP-Bold.ttf": "4640bb35fc3117ef87a317a14a2c5b0f",
"assets/assets/IBMPlexSansJP-ExtraLight.ttf": "53bdba83b5a39692754a776a21bc2332",
"assets/assets/IBMPlexSansJP-Light.ttf": "3ba15f9df2f2cee7780c853c9fd476d9",
"assets/assets/IBMPlexSansJP-Medium.ttf": "6405ed02b9bbfe97685173b0a2c77857",
"assets/assets/IBMPlexSansJP-Regular.ttf": "c3465fcf829758138243bea7bf997f71",
"assets/assets/IBMPlexSansJP-SemiBold.ttf": "556dff0f5c3d19800bad60206f113080",
"assets/assets/IBMPlexSansJP-Thin.ttf": "fd26d0e2d01c68a3069355855bf5763b",
"assets/assets/Second/CALL_1.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Second/CALL_2.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Second/Computer_Room_1.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Second/Computer_Room_2.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Second/lib.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Second/N201.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Second/N202.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Second/N203.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Second/N204.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Second/N205.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Second/S201.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Second/S202.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Second/S203.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Second/S204.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Second/S205.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Second/S206.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Second/S207.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Second/T201.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Second/T202.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Stage/Band01.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Stage/Band02.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Stage/Band03.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Stage/Band04.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Stage/Band05.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Stage/Band06.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Stage/No%2520Select.jpg": "f31bfa331cf9892ae9b1262727322b63",
"assets/assets/Stage/Performance01.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Stage/Performance02.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Stage/Performance03.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Stage/Performance04.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Stage/Performance05.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Stage/Roten_a.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Stage/Roten_b.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Stage/Roten_c.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Stage/Roten_d.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Stage/Roten_e.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Stage/Roten_f.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Stage/Roten_g.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Stage/Roten_h.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Stage/Stage01.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Stage/Stage02.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Stage/Stage03.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Stage/Stage04.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Stage/Stage05.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Stage/Stage06.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Stage/Stage07.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Stage/Stage08.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Stage/Stage09.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Third/Butsuri_Experiment.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Third/Daikaigi.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Third/Kagaku_Experiment.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Third/Kyotsu_Experiment.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Third/N301.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Third/N302.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Third/N303.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Third/N304.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Third/N305.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Third/N306.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Third/N307.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Third/S301.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Third/S302.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Third/S303.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Third/S304.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Third/S305.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Third/S306.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Third/S307.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Third/Saho.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Third/Seibutsu_Experiment.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Third/T301.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Third/T302.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Third/T303.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Third/T304.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Third/T305.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Third/T306.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Third/T307.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Third/T308.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Third/Tokusho_1_2_3.jpg": "43444343382f3159d55c049fbedd7686",
"assets/assets/Third/Tokusho_4_5.jpg": "43444343382f3159d55c049fbedd7686",
"assets/FontManifest.json": "b822cb7eaae137652bc3979da9885f5e",
"assets/fonts/MaterialIcons-Regular.otf": "dc84a8b08880930e9c652dfdfbe2b863",
"assets/NOTICES": "83f643634c91eaf82e6aa0798ce3d123",
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
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"flutter_bootstrap.js": "9ff528637bb595d07e7578e68014c158",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "9a507fe2ac53ff638ed040f8f16ac867",
"/": "9a507fe2ac53ff638ed040f8f16ac867",
"main.dart.js": "bcaadf8deb6ed679222d8707055463ca",
"manifest.json": "bafedb8858aca218eb168e34a857f9f9",
"style.css": "52085ddfc20d1dda153ab71cd0153d20",
"version.json": "8d55816673257e284b819830a846508c"};
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
