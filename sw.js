/* Offline cache. Bump V when files change. */
var V="rg-v14",FILES=["app.js", "cnn_model.js", "embeddings.js", "forecast_data.js", "manifest.webmanifest", "model.js", "places.js", "samples.js", "style.css"].concat(["./"]);
self.addEventListener("install",function(e){e.waitUntil(caches.open(V).then(function(c){return c.addAll(FILES)}).then(function(){return self.skipWaiting()}))});
self.addEventListener("activate",function(e){e.waitUntil(caches.keys().then(function(k){return Promise.all(k.filter(function(x){return x!==V}).map(function(x){return caches.delete(x)}))}).then(function(){return self.clients.claim()}))});
self.addEventListener("fetch",function(e){
  var r=e.request;if(r.method!=="GET"||new URL(r.url).origin!==location.origin)return;
  if(r.mode==="navigate"){e.respondWith(fetch(r).then(function(x){var c=x.clone();caches.open(V).then(function(h){h.put("./",c)});return x}).catch(function(){return caches.match("./")}));return}
  e.respondWith(caches.match(r).then(function(m){return m||fetch(r).then(function(x){var c=x.clone();caches.open(V).then(function(h){h.put(r,c)});return x})}));
});
