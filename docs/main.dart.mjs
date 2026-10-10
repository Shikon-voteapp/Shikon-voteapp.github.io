// Compiles a dart2wasm-generated main module from `source` which can then
// be instantiated via the `instantiate` method.
//
// `source` needs to be a `Response` object (or promise thereof) e.g. created
// via the `fetch()` JS API.
export async function compileStreaming(source) {
  const builtins = {builtins: ['js-string']};
  return new CompiledApp(
      await WebAssembly.compileStreaming(source, builtins), builtins);
}

// Compiles a dart2wasm-generated wasm module from `bytes` which is then
// instantiable via the `instantiate` method.
export async function compile(bytes) {
  const builtins = {builtins: ['js-string']};
  return new CompiledApp(await WebAssembly.compile(bytes, builtins), builtins);
}

class CompiledApp {
  constructor(module, builtins) {
    this.module = module;
    this.builtins = builtins;
  }

  // The second argument is an options object containing:
  // `loadDeferredModules` is a JS function that takes an array of module names
  //   matching wasm files produced by the dart2wasm compiler. It also takes a
  //   callback that should be invoked for each loaded module with 2 arguments:
  //   (1) the module name, (2) the loaded module in a format supported by
  //   `WebAssembly.compile` or `WebAssembly.compileStreaming`. The callback
  //   returns a Promise that resolves when the module is instantiated.
  //   loadDeferredModules should return a Promise that resolves when all the
  //   modules have been loaded and the callback promises have resolved.
  // `loadDeferredId` is a JS function that takes load ID produced by the
  //   compiler when the `use-load-ids` option is passed. Each load ID maps to
  //   one or more wasm files as specified in the emitted JSON file. It also
  //   takes a callback that should be invoked for each loaded module with 2
  //   arguments: (1) the module name, (2) the loaded module in a format
  //   supported by `WebAssembly.compile` or `WebAssembly.compileStreaming`.
  //   The callback returns a Promise that resolves when the module is
  //   instantiated.
  //   loadDeferredId should return a Promise that resolves when all the
  //   modules have been loaded and the callback promises have resolved.
  async instantiate(additionalImports, {loadDeferredModules, loadDeferredId} = {}) {
    let dartInstance;

    // Prints to the console
    function printToConsole(value) {
      if (typeof dartPrint == "function") {
        dartPrint(value);
        return;
      }
      if (typeof console == "object" && typeof console.log != "undefined") {
        console.log(value);
        return;
      }
      if (typeof print == "function") {
        print(value);
        return;
      }

      throw "Unable to print message: " + value;
    }

    // A special symbol attached to functions that wrap Dart functions.
    const jsWrappedDartFunctionSymbol = Symbol("JSWrappedDartFunction");

    function finalizeWrapper(dartFunction, wrapped) {
      wrapped.dartFunction = dartFunction;
      wrapped[jsWrappedDartFunctionSymbol] = true;
      return wrapped;
    }

    // Imports
    const dart2wasm = {
            AB: x0 => new Int16Array(x0),
      AC: (o, start, length) => new Uint8ClampedArray(o.buffer, o.byteOffset + start, length),
      AD: o => {
        if (o === null || o === undefined) return 0;
        if (typeof(o) === 'string') return 1;
        return 2;
      },
      AE: (x0,x1) => x0.getPropertyValue(x1),
      AF: x0 => x0.identifier,
      AG: x0 => x0.state,
      AH: (x0,x1) => x0.createEvent(x1),
      AI: (handle) => clearInterval(handle),
      AJ: () => globalThis.window.ImageDecoder,
      AK: x0 => x0.clear(),
      AL: () => globalThis.console,
      AM: x0 => x0.databaseURL,
      AN: x0 => x0.displayName,
      AO: (x0,x1,x2,x3,x4,x5,x6,x7,x8) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4,x5,x6,x7,x8),
      AP: () => globalThis.firebase_firestore.endAt,
      B: s => printToConsole(s),
      BB: x0 => new Uint16Array(x0),
      BC: (o, start, length) => new Uint8Array(o.buffer, o.byteOffset + start, length),
      BD: x0 => x0.tabIndex,
      BE: x0 => globalThis.parseFloat(x0),
      BF: x0 => x0.touches,
      BG: (x0,x1) => x0.go(x1),
      BH: (x0,x1,x2,x3) => x0.initEvent(x1,x2,x3),
      BI: (ms, c) =>
      setInterval(() => dartInstance.exports.$invokeCallback(c), ms),
      BJ: x0 => x0.message,
      BK: x0 => x0.sessionStorage,
      BL: x0 => x0.trustedTypes,
      BM: x0 => x0.apiKey,
      BN: x0 => x0.hints,
      BO: (x0,x1,x2,x3,x4,x5,x6,x7,x8,x9) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4,x5,x6,x7,x8,x9),
      BP: () => globalThis.firebase_firestore.startAfter,
      C: Function.prototype.call.bind(Number.prototype.toString),
      CB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI16ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      CC: (o, start, length) => new Int8Array(o.buffer, o.byteOffset + start, length),
      CD: (x0,x1) => x0.contains(x1),
      CE: (x0,x1) => x0.getComputedStyle(x1),
      CF: x0 => x0.pressure,
      CG: x0 => x0.parentElement,
      CH: x0 => x0.readText(),
      CI: () => Date.now(),
      CJ: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      CK: x0 => x0.localStorage,
      CL: (wasmFunction,f) => finalizeWrapper(f, function() { return wasmFunction(f,arguments.length) }),
      CM: x0 => x0.options,
      CN: x0 => x0.tenantId,
      CO: () => globalThis.firebase_firestore.documentId(),
      CP: () => globalThis.firebase_firestore.startAt,
      D: Function.prototype.call.bind(BigInt.prototype.toString),
      DB: x0 => new Int32Array(x0),
      DC: (x0,x1) => x0.querySelector(x1),
      DD: x0 => x0.activeElement,
      DE: x0 => x0.documentElement,
      DF: x0 => x0.tiltY,
      DG: (x0,x1) => x0.querySelectorAll(x1),
      DH: x0 => x0.clipboard,
      DI: x0 => new WeakRef(x0),
      DJ: (x0,x1,x2) => x0.addEventListener(x1,x2),
      DK: x0 => x0.caches,
      DL: x0 => { globalThis.onGoogleLibraryLoad = x0 },
      DM: () => globalThis.firebase_core.SDK_VERSION,
      DN: x0 => x0.phoneNumber,
      DO: (x0,x1) => new firebase_firestore.GeoPoint(x0,x1),
      DP: (x0,x1) => globalThis.firebase_firestore.orderBy(x0,x1),
      E: (exn) => {
        let stackString = exn.toString();
        let frames = stackString.split('\n');
        let drop = 4;
        if (frames[0].startsWith('Error')) {
            drop += 1;
        }
        return frames.slice(drop).join('\n');
      },
      EB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      EC: (x0,x1) => x0.item(x1),
      ED: x0 => x0.parentNode,
      EE: x0 => x0.computedStyleMap(),
      EF: x0 => x0.tiltX,
      EG: (x0,x1) => x0.requestAnimationFrame(x1),
      EH: (x0,x1) => x0.writeText(x1),
      EI: x0 => x0.deref(),
      EJ: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      EK: x0 => x0.serviceWorker,
      EL: (x0,x1,x2) => x0.setAttribute(x1,x2),
      EM: (x0,x1,x2) => globalThis.firebase_core.registerVersion(x0,x1,x2),
      EN: x0 => x0.email,
      EO: x0 => globalThis.firebase_firestore.vector(x0),
      EP: (x0,x1) => globalThis.firebase_firestore.collection(x0,x1),
      F: () => new Error().stack,
      FB: x0 => new Uint32Array(x0),
      FC: x0 => x0.length,
      FD: x0 => x0.tagName,
      FE: (x0,x1) => x0.get(x1),
      FF: x0 => x0.pointerType,
      FG: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      FH: x0 => x0.unlock(),
      FI: () => globalThis.WeakRef,
      FJ: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      FK: x0 => x0.navigator,
      FL: (x0,x1) => { x0.id = x1 },
      FM: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      FN: (x0,x1) => globalThis.firebase_auth.getMultiFactorResolver(x0,x1),
      FO: x0 => globalThis.firebase_firestore.Bytes.fromUint8Array(x0),
      FP: x0 => x0.length,
      G: s => JSON.stringify(s),
      GB: x0 => new Float32Array(x0),
      GC: (x0,x1) => x0.querySelectorAll(x1),
      GD: x0 => x0.target,
      GE: (o, p) => p in o,
      GF: x0 => x0.pointerId,
      GG: x0 => x0.now(),
      GH: (x0,x1) => x0.lock(x1),
      GI: (o, offsetInBytes, lengthInBytes) => {
        var dst = new ArrayBuffer(lengthInBytes);
        new Uint8Array(dst).set(new Uint8Array(o, offsetInBytes, lengthInBytes));
        return new DataView(dst);
      },
      GJ: (x0,x1) => x0.removeChild(x1),
      GK: () => globalThis.window,
      GL: x0 => x0.code,
      GM: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      GN: x0 => x0.customData,
      GO: x0 => x0.commit(),
      GP: x0 => x0.getReader(),
      H: Function.prototype.call.bind(Number.prototype.toString),
      HB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      HC: (x0,x1) => x0.getAttribute(x1),
      HD: x0 => x0.clientY,
      HE: (x0,x1) => { x0.textContent = x1 },
      HF: x0 => x0.getCoalescedEvents(),
      HG: x0 => x0.performance,
      HH: x0 => x0.orientation,
      HI: (a, s, e) => a.slice(s, e),
      HJ: x0 => x0.click(),
      HK: (x0,x1) => x0.transferFromImageBitmap(x1),
      HL: (x0,x1) => globalThis.firebase_storage.ref(x0,x1),
      HM: (x0,x1) => ({createScript: x0,createScriptURL: x1}),
      HN: x0 => x0.message,
      HO: x0 => globalThis.firebase_firestore.writeBatch(x0),
      HP: x0 => x0.value,
      I: Function.prototype.call.bind(String.prototype.indexOf),
      IB: x0 => new Float64Array(x0),
      IC: x0 => x0.remove(),
      ID: x0 => x0.clientX,
      IE: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      IF: (x0,x1) => x0.getModifierState(x1),
      IG: (d, digits) => d.toFixed(digits),
      IH: (x0,x1) => x0.querySelector(x1),
      II: (x0,x1) => x0.assign(x1),
      IJ: (o, a) => o + a,
      IK: (x0,x1) => x0.getContext(x1),
      IL: (x0,x1) => globalThis.firebase_storage.getStorage(x0,x1),
      IM: (x0,x1) => x0.createScriptURL(x1),
      IN: x0 => x0.code,
      IO: (x0,x1) => globalThis.firebase_firestore.getFirestore(x0,x1),
      IP: x0 => x0.done,
      J: (s, p, i) => s.lastIndexOf(p, i),
      JB: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF64ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      JC: (x0,x1) => x0.appendChild(x1),
      JD: (x0,x1,x2) => x0.setAttribute(x1,x2),
      JE: x0 => x0.matches,
      JF: s => s.trimLeft(),
      JG: x0 => x0.maxHeight,
      JH: (x0,x1) => { x0.title = x1 },
      JI: x0 => x0.pathname,
      JJ: x0 => x0.children,
      JK: (x0,x1) => { x0.height = x1 },
      JL: x0 => globalThis.firebase_storage.getStorage(x0),
      JM: (x0,x1,x2) => x0.createScript(x1,x2),
      JN: (x0,x1,x2) => globalThis.firebase_auth.createUserWithEmailAndPassword(x0,x1,x2),
      JO: x0 => globalThis.firebase_firestore.deleteDoc(x0),
      JP: x0 => x0.read(),
      K: (exn) => {
        if (exn instanceof Error) {
          return exn.stack;
        } else {
          return null;
        }
      },
      KB: x0 => new ArrayBuffer(x0),
      KC: (x0,x1) => x0.append(x1),
      KD: x0 => x0.getBoundingClientRect(),
      KE: (x0,x1) => x0.matchMedia(x1),
      KF: s => s.toUpperCase(),
      KG: x0 => x0.maxWidth,
      KH: (x0,x1) => x0.vibrate(x1),
      KI: x0 => x0.origin,
      KJ: x0 => x0.firstChild,
      KK: (x0,x1) => { x0.width = x1 },
      KL: x0 => x0.name,
      KM: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      KN: (x0,x1,x2) => ({errorMap: x0,persistence: x1,popupRedirectResolver: x2}),
      KO: (x0,x1) => globalThis.firebase_firestore.setDoc(x0,x1),
      KP: x0 => x0.body,
      L: o => o === undefined,
      LB: (x0,x1,x2) => new Uint8Array(x0,x1,x2),
      LC: (x0,x1,x2,x3) => x0.setProperty(x1,x2,x3),
      LD: (ms, c) =>
      setTimeout(() => dartInstance.exports.$invokeCallback(c),ms),
      LE: x0 => x0.matches,
      LF: (x0,x1) => x0.test(x1),
      LG: x0 => x0.minHeight,
      LH: x0 => x0.arrayBuffer(),
      LI: x0 => x0.location,
      LJ: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      LK: x0 => x0.height,
      LL: x0 => globalThis.firebase_core.getApp(x0),
      LM: (o, p) => delete o[p],
      LN: (x0,x1) => globalThis.firebase_auth.initializeAuth(x0,x1),
      LO: x0 => ({serverTimestamps: x0}),
      LP: (x0,x1) => new OffscreenCanvas(x0,x1),
      M: o => String(o),
      MB: (x0,x1,x2) => new DataView(x0,x1,x2),
      MC: x0 => x0.style,
      MD: s => new Date(s * 1000).getTimezoneOffset() * 60,
      ME: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
      MF: (x0,x1) => x0[x1],
      MG: x0 => x0.minWidth,
      MH: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof ArrayBuffer) return 1;
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
          return 2;
        }
        return 3;
      },
      MI: (x0,x1,x2) => x0.insertBefore(x1,x2),
      MJ: (x0,x1,x2,x3) => x0.removeEventListener(x1,x2,x3),
      MK: x0 => x0.width,
      ML: () => globalThis.firebase_core.getApp(),
      MM: (o, p, v) => o[p] = v,
      MN: () => globalThis.firebase_auth.browserPopupRedirectResolver,
      MO: x0 => x0.fromCache,
      MP: x0 => x0.assetBase,
      N: (c) =>
      queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
      NB: (o, p) => o[p],
      NC: x0 => x0.debugShowSemanticsNodes,
      ND: Date.now,
      NE: f => f.dartFunction,
      NF: x0 => x0.index,
      NG: (x0,x1) => x0.removeProperty(x1),
      NH: x0 => x0.status,
      NI: x0 => x0.id,
      NJ: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      NK: x0 => x0.rasterEndMilliseconds,
      NL: x0 => x0.state,
      NM: (x0,x1) => { x0.text = x1 },
      NN: () => globalThis.firebase_auth.debugErrorMap,
      NO: x0 => x0.hasPendingWrites,
      NP: x0 => x0.loader,
      O: (x0,x1) => x0.didCreateEngineInitializer(x1),
      OB: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
      OC: o => o,
      OD: (handle) => clearTimeout(handle),
      OE: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      OF: x0 => x0.pop(),
      OG: (x0,x1) => x0.add(x1),
      OH: (x0,x1) => x0.fetch(x1),
      OI: x0 => x0.offsetHeight,
      OJ: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      OK: x0 => x0.rasterStartMilliseconds,
      OL: x0 => x0.snapshot,
      OM: (x0,x1) => { x0.text = x1 },
      ON: () => globalThis.firebase_auth.browserSessionPersistence,
      OO: x0 => x0.metadata,
      OP: () => globalThis._flutter,
      P: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      PB: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
      PC: o => {
        if (o === undefined || o === null) return 0;
        if (typeof o === 'boolean') return 1;
        return 2;
      },
      PD: (x0,x1) => x0.closest(x1),
      PE: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      PF: x0 => x0.flags,
      PG: x0 => x0.data,
      PH: x0 => x0.content,
      PI: x0 => x0.offsetWidth,
      PJ: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      PK: x0 => x0.imageBitmaps,
      PL: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      PM: x0 => x0.trustedTypes,
      PN: () => globalThis.firebase_auth.browserLocalPersistence,
      PO: x0 => x0.toArray(),
      Q: (wasmFunction,f) => finalizeWrapper(f, function() { return wasmFunction(f,arguments.length) }),
      QB: o => o.byteOffset,
      QC: (x0,x1) => x0.warn(x1),
      QD: x0 => x0.bottom,
      QE: (p, s, f) => p.then(s, (e) => f(e, e === undefined)),
      QF: (a, s) => a.join(s),
      QG: (x0,x1) => { x0.scrollTop = x1 },
      QH: x0 => x0.document,
      QI: x0 => x0.stopPropagation(),
      QJ: (x0,x1) => x0.item(x1),
      QK: x0 => x0.canvasKitMaximumSurfaces,
      QL: (x0,x1) => x0.then(x1),
      QM: (x0,x1) => { x0.crossOrigin = x1 },
      QN: () => globalThis.firebase_auth.indexedDBLocalPersistence,
      QO: x0 => x0.toUint8Array(),
      R: (x0,x1) => ({initializeEngine: x0,autoStart: x1}),
      RB: o => o.buffer,
      RC: x0 => x0.console,
      RD: x0 => x0.top,
      RE: (o, i) => o[i],
      RF: (x0,x1) => x0.error(x1),
      RG: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      RH: () => typeof dartUseDateNowForTicks !== "undefined",
      RI: x0 => x0.disabled,
      RJ: () => new FileReader(),
      RK: x0 => x0.hostElement,
      RL: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      RM: (x0,x1) => { x0.type = x1 },
      RN: x0 => x0.signOut(),
      RO: () => globalThis.firebase_firestore.Bytes,
      S: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      SB: Function.prototype.call.bind(DataView.prototype.getUint8),
      SC: () => globalThis.window,
      SD: x0 => x0.right,
      SE: o => o.length,
      SF: () => globalThis.console,
      SG: (x0,x1) => { x0.value = x1 },
      SH: () => Date.now(),
      SI: (x0,x1) => { x0.min = x1 },
      SJ: (x0,x1) => x0.readAsArrayBuffer(x1),
      SK: x0 => x0.location,
      SL: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      SM: x0 => x0.providerId,
      SN: (x0,x1,x2) => globalThis.firebase_auth.signInWithEmailAndPassword(x0,x1,x2),
      SO: () => globalThis.firebase_firestore.VectorValue,
      T: x0 => new Promise(x0),
      TB: (b, o) => new DataView(b, o),
      TC: (o, c) => o instanceof c,
      TD: x0 => x0.left,
      TE: o => {
        if (o === undefined) return 1;
        var type = typeof o;
        if (type === 'boolean') return 2;
        if (type === 'number') return 3;
        if (type === 'string') return 4;
        if (o instanceof Array) return 5;
        if (ArrayBuffer.isView(o)) {
          if (o instanceof Int8Array) return 6;
          if (o instanceof Uint8Array) return 7;
          if (o instanceof Uint8ClampedArray) return 8;
          if (o instanceof Int16Array) return 9;
          if (o instanceof Uint16Array) return 10;
          if (o instanceof Int32Array) return 11;
          if (o instanceof Uint32Array) return 12;
          if (o instanceof Float32Array) return 13;
          if (o instanceof Float64Array) return 14;
          if (o instanceof DataView) return 15;
        }
        if (o instanceof ArrayBuffer) return 16;
        // Feature check for `SharedArrayBuffer` before doing a type-check.
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
            return 17;
        }
        if (o instanceof Promise) return 18;
        return 19;
      },
      TF: s => s.trimRight(),
      TG: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      TH: () => 1000 * performance.now(),
      TI: (x0,x1) => { x0.max = x1 },
      TJ: x0 => ({type: x0}),
      TK: (x0,x1) => x0.getModifierState(x1),
      TL: (wasmFunction,f) => finalizeWrapper(f, function() { return wasmFunction(f,arguments.length) }),
      TM: x0 => x0.uid,
      TN: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      TO: x0 => x0.longitude,
      U: (x0,x1,x2) => x0.call(x1,x2),
      UB: (b, o, l) => new DataView(b, o, l),
      UC: (x0,x1) => x0.exec(x1),
      UD: x0 => x0.clientY,
      UE: x0 => x0.language,
      UF: x0 => x0.blur(),
      UG: (x0,x1) => { x0.value = x1 },
      UH: x0 => new Uint8Array(x0),
      UI: (x0,x1) => { x0.disabled = x1 },
      UJ: (x0,x1) => new Blob(x0,x1),
      UK: x0 => x0.metaKey,
      UL: x0 => x0.call(),
      UM: x0 => x0.providerData,
      UN: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      UO: x0 => x0.latitude,
      V: (constructor, args) => {
        const factoryFunction = constructor.bind.apply(
            constructor, [null, ...args]);
        return new factoryFunction();
      },
      VB: Function.prototype.call.bind(DataView.prototype.getFloat64),
      VC: x0 => x0.length,
      VD: x0 => x0.clientX,
      VE: (x0,x1,x2,x3) => x0.register(x1,x2,x3),
      VF: x0 => x0.button,
      VG: s => {
        if (/[[\]{}()*+?.\\^$|]/.test(s)) {
            s = s.replace(/[[\]{}()*+?.\\^$|]/g, '\\$&');
        }
        return s;
      },
      VH: (x0,x1,x2) => x0.slice(x1,x2),
      VI: (x0,x1) => { x0.scrollLeft = x1 },
      VJ: x0 => globalThis.URL.createObjectURL(x0),
      VK: x0 => x0.altKey,
      VL: (x0,x1,x2,x3,x4) => x0.on(x1,x2,x3,x4),
      VM: x0 => x0.tenantId,
      VN: (x0,x1,x2) => x0.onIdTokenChanged(x1,x2),
      VO: () => globalThis.firebase_firestore.GeoPoint,
      W: x0 => new Array(x0),
      WB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Float64Array) return 1;
        return 2;
      },
      WC: (x0,x1) => { x0.lastIndex = x1 },
      WD: x0 => x0.changedTouches,
      WE: () => globalThis.window.FinalizationRegistry,
      WF: x0 => x0.innerHeight,
      WG: x0 => x0.value,
      WH: (x0,x1) => x0.decode(x1),
      WI: (x0,x1) => { x0.spellcheck = x1 },
      WJ: x0 => x0.size,
      WK: x0 => x0.ctrlKey,
      WL: (x0,x1,x2) => globalThis.firebase_storage.uploadBytesResumable(x0,x1,x2),
      WM: x0 => x0.refreshToken,
      WN: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      WO: (x0,x1) => x0.data(x1),
      X: o => [o],
      XB: Function.prototype.call.bind(DataView.prototype.setFloat64),
      XC: (s, m) => {
        try {
          return new RegExp(s, m);
        } catch (e) {
          return String(e);
        }
      },
      XD: x0 => x0.offsetY,
      XE: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      XF: x0 => x0.innerWidth,
      XG: x0 => x0.selectionDirection,
      XH: (x0,x1) => x0.adoptText(x1),
      XI: (x0,x1) => { x0.disabled = x1 },
      XJ: x0 => x0.name,
      XK: x0 => x0.isComposing,
      XL: () => ({}),
      XM: x0 => x0.photoURL,
      XN: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      XO: x0 => x0.nanoseconds,
      Y: (o0, o1) => [o0, o1],
      YB: (t, s) => t.set(s),
      YC: o => o instanceof RegExp,
      YD: x0 => x0.offsetX,
      YE: x0 => new window.FinalizationRegistry(x0),
      YF: x0 => x0.height,
      YG: x0 => x0.selectionStart,
      YH: x0 => x0.first(),
      YI: (x0,x1,x2) => x0.open(x1,x2),
      YJ: x0 => x0.type,
      YK: x0 => x0.code,
      YL: (x0,x1) => { x0.customMetadata = x1 },
      YM: x0 => x0.phoneNumber,
      YN: (x0,x1,x2) => x0.onAuthStateChanged(x1,x2),
      YO: x0 => x0.seconds,
      Z: (o0, o1, o2) => [o0, o1, o2],
      ZB: Function.prototype.call.bind(DataView.prototype.setFloat32),
      ZC: (string, times) => string.repeat(times),
      ZD: x0 => x0.type,
      ZE: (x0,x1) => x0.unregister(x1),
      ZF: x0 => x0.width,
      ZG: x0 => x0.selectionEnd,
      ZH: x0 => x0.next(),
      ZI: (x0,x1) => x0.revokeObjectURL(x1),
      ZJ: x0 => x0.result,
      ZK: x0 => x0.repeat,
      ZL: (x0,x1) => { x0.contentType = x1 },
      ZM: x0 => x0.lastSignInTime,
      ZN: x0 => x0.currentUser,
      ZO: () => globalThis.firebase_firestore.Timestamp,
      a: (o0, o1, o2, o3) => [o0, o1, o2, o3],
      aB: Function.prototype.call.bind(DataView.prototype.getFloat32),
      aC: x0 => x0.dotAll,
      aD: x0 => x0.maxTouchPoints,
      aE: (x0,x1) => x0.contains(x1),
      aF: x0 => x0.clientHeight,
      aG: x0 => x0.value,
      aH: x0 => x0.current(),
      aI: (x0,x1) => { x0.src = x1 },
      aJ: x0 => x0.length,
      aK: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      aL: x0 => x0.fullPath,
      aM: x0 => x0.creationTime,
      aN: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      aO: () => globalThis.firebase_firestore.DocumentReference,
      b: (x0,x1,x2) => { x0[x1] = x2 },
      bB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Float32Array) return 1;
        return 2;
      },
      bC: x0 => x0.unicode,
      bD: x0 => x0.platform,
      bE: (s) => +s,
      bF: x0 => x0.clientWidth,
      bG: x0 => x0.selectionDirection,
      bH: (x0,x1) => new Intl.v8BreakIterator(x0,x1),
      bI: (x0,x1,x2,x3,x4) => globalThis.createImageBitmap(x0,x1,x2,x3,x4),
      bJ: x0 => x0.files,
      bK: x0 => x0.userAgent,
      bL: x0 => x0.prefixes,
      bM: x0 => x0.metadata,
      bN: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      bO: x0 => x0.path,
      c: o => o,
      cB: Function.prototype.call.bind(DataView.prototype.getUint32),
      cC: x0 => x0.ignoreCase,
      cD: x0 => x0.body,
      cE: s => {
        if (!/^\s*[+-]?(?:Infinity|NaN|(?:\.\d+|\d+(?:\.\d*)?)(?:[eE][+-]?\d+)?)\s*$/.test(s)) {
          return NaN;
        }
        return parseFloat(s);
      },
      cF: (x0,x1) => { x0.content = x1 },
      cG: x0 => x0.selectionStart,
      cH: x0 => x0.v8BreakIterator,
      cI: x0 => x0.naturalHeight,
      cJ: (x0,x1) => { x0.display = x1 },
      cK: (x0,x1) => x0.removeItem(x1),
      cL: x0 => x0.items,
      cM: x0 => x0.isAnonymous,
      cN: (x0,x1) => globalThis.firebase_auth.connectAuthEmulator(x0,x1),
      cO: x0 => x0.ref,
      d: (o, p) => o[p],
      dB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Uint32Array) return 1;
        return 2;
      },
      dC: x0 => x0.multiline,
      dD: () => globalThis.document,
      dE: s => s.trim(),
      dF: (x0,x1) => { x0.name = x1 },
      dG: x0 => x0.selectionEnd,
      dH: () => globalThis.Intl,
      dI: x0 => x0.naturalWidth,
      dJ: x0 => x0.style,
      dK: (x0,x1) => x0.key(x1),
      dL: x0 => x0.nextPageToken,
      dM: x0 => x0.emailVerified,
      dN: x0 => x0.hostname,
      dO: x0 => globalThis.firebase_firestore.getDoc(x0),
      e: () => globalThis,
      eB: Function.prototype.call.bind(DataView.prototype.getInt32),
      eC: (string, token) => string.split(token),
      eD: (x0,x1,x2) => x0.addEventListener(x1,x2),
      eE: x0 => x0.classList,
      eF: x0 => x0.head,
      eG: x0 => x0.keyCode,
      eH: (x0,x1) => x0.segment(x1),
      eI: x0 => x0.decode(),
      eJ: (x0,x1) => { x0.accept = x1 },
      eK: x0 => x0.length,
      eL: x0 => globalThis.firebase_storage.listAll(x0),
      eM: x0 => x0.email,
      eN: x0 => x0.token,
      eO: x0 => globalThis.firebase_firestore.getDocFromServer(x0),
      f: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      fB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Int32Array) return 1;
        return 2;
      },
      fC: o => o instanceof Array,
      fD: x0 => x0.hasFocus(),
      fE: x0 => x0.preventDefault(),
      fF: (x0,x1) => x0.removeChild(x1),
      fG: (x0,x1) => x0.scrollIntoView(x1),
      fH: x0 => x0.index,
      fI: (x0,x1) => { x0.decoding = x1 },
      fJ: (x0,x1) => { x0.multiple = x1 },
      fK: (x0,x1,x2) => x0.setItem(x1,x2),
      fL: (x0,x1) => globalThis.firebase_database.child(x0,x1),
      fM: x0 => x0.displayName,
      fN: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      fO: x0 => globalThis.firebase_firestore.getDocFromCache(x0),
      g: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      gB: o => o instanceof Uint16Array,
      gC: (a, i) => a[i],
      gD: x0 => x0.relatedTarget,
      gE: x0 => x0.parent,
      gF: x0 => x0.firstChild,
      gG: x0 => x0.multiViewEnabled,
      gH: x0 => x0.next(),
      gI: (x0,x1) => { x0.crossOrigin = x1 },
      gJ: (x0,x1) => { x0.draggable = x1 },
      gK: (x0,x1) => x0.getItem(x1),
      gL: x0 => x0.toJSON(),
      gM: x0 => globalThis.firebase_auth.multiFactor(x0),
      gN: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      gO: x0 => x0.source,
      h: (x0,x1) => ({addView: x0,removeView: x1}),
      hB: Function.prototype.call.bind(DataView.prototype.getUint16),
      hC: a => a.length,
      hD: x0 => x0.shiftKey,
      hE: x0 => x0.timeStamp,
      hF: x0 => x0.viewConstraints,
      hG: (x0,x1) => x0.replaceWith(x1),
      hH: x0 => x0.value,
      hI: (x0,x1) => x0.createObjectURL(x1),
      hJ: (x0,x1) => { x0.type = x1 },
      hK: (x0,x1) => x0.querySelector(x1),
      hL: (x0,x1) => globalThis.firebase_database.set(x0,x1),
      hM: x0 => x0.toJSON(),
      hN: (x0,x1,x2) => globalThis.firebase_app_check.onTokenChanged(x0,x1,x2),
      hO: x0 => ({source: x0}),
      i: (l, r) => l === r,
      iB: o => o instanceof Int16Array,
      iC: x0 => x0.userAgent,
      iD: (decoder, codeUnits) => decoder.decode(codeUnits),
      iE: (x0,x1) => x0.hasAttribute(x1),
      iF: x0 => x0.hostElement,
      iG: (x0,x1) => { x0.type = x1 },
      iH: x0 => x0.done,
      iI: x0 => x0.URL,
      iJ: (x0,x1) => x0.createElement(x1),
      iK: (x0,x1) => x0.getAttribute(x1),
      iL: (x0,x1) => globalThis.firebase_database.update(x0,x1),
      iM: x0 => x0.user,
      iN: x0 => new firebase_app_check.ReCaptchaV3Provider(x0),
      iO: x0 => x0.path,
      j: x0 => x0.random(),
      jB: Function.prototype.call.bind(DataView.prototype.getInt16),
      jC: x0 => x0.navigator,
      jD: () => new TextDecoder("utf-8", {fatal: true}),
      jE: x0 => x0.buttons,
      jF: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      jG: (x0,x1) => { x0.className = x1 },
      jH: (o, m, a) => o[m].apply(o, a),
      jI: x0 => new Blob(x0),
      jJ: () => globalThis.document,
      jK: (x0,x1) => x0.debug(x1),
      jL: x0 => x0.priority,
      jM: x0 => x0.idToken,
      jN: x0 => new firebase_app_check.ReCaptchaEnterpriseProvider(x0),
      jO: x0 => x0.metadata,
      k: o => o,
      kB: o => o instanceof Uint8ClampedArray,
      kC: Function.prototype.call.bind(String.prototype.toLowerCase),
      kD: () => new TextDecoder("utf-8", {fatal: false}),
      kE: x0 => x0.ctrlKey,
      kF: x0 => ({runApp: x0}),
      kG: (x0,x1) => { x0.tabIndex = x1 },
      kH: x0 => x0.iterator,
      kI: (x0,x1,x2,x3,x4) => ({type: x0,data: x1,premultiplyAlpha: x2,colorSpaceConversion: x3,preferAnimation: x4}),
      kJ: (x0,x1) => x0.appendChild(x1),
      kK: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      kL: x0 => x0.val(),
      kM: x0 => x0.secret,
      kN: x0 => ({provider: x0}),
      kO: x0 => x0.doc,
      l: o => {
        if (o === undefined || o === null) return 0;
        if (typeof o === 'number') return 1;
        return 2;
      },
      lB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Uint8Array) return 1;
        return 2;
      },
      lC: Object.is,
      lD: (a, i, v) => a[i] = v,
      lE: x0 => x0.y,
      lF: x0 => new Event(x0),
      lG: (x0,x1) => { x0.name = x1 },
      lH: () => globalThis.Symbol,
      lI: x0 => new window.ImageDecoder(x0),
      lJ: x0 => x0.remove(),
      lK: x0 => ({createScriptURL: x0}),
      lL: x0 => x0.key,
      lM: x0 => x0.accessToken,
      lN: (x0,x1) => globalThis.firebase_app_check.initializeAppCheck(x0,x1),
      lO: x0 => x0.newIndex,
      m: () => globalThis.Math,
      mB: Function.prototype.call.bind(DataView.prototype.setInt32),
      mC: x0 => x0.vendor,
      mD: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI8ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      mE: x0 => x0.x,
      mF: (x0,x1) => x0.dispatchEvent(x1),
      mG: (x0,x1) => { x0.placeholder = x1 },
      mH: (x0,x1) => new Intl.Segmenter(x0,x1),
      mI: x0 => x0.name,
      mJ: x0 => globalThis.URL.revokeObjectURL(x0),
      mK: (x0,x1,x2) => x0.createPolicy(x1,x2),
      mL: x0 => x0.ref,
      mM: x0 => x0.signInMethod,
      mN: (x0,x1) => x0.delete(x1),
      mO: x0 => x0.oldIndex,
      n: (x0,x1) => x0.prepend(x1),
      nB: Function.prototype.call.bind(DataView.prototype.setUint32),
      nC: (x0,x1) => x0.createTextNode(x1),
      nD: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI16ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      nE: x0 => x0.scrollTop,
      nF: Function.prototype.call.bind(DataView.prototype.getBigInt64),
      nG: (x0,x1) => { x0.autocomplete = x1 },
      nH: x0 => x0.Segmenter,
      nI: x0 => x0.repetitionCount,
      nJ: x0 => x0.body,
      nK: (x0,x1) => x0.createScriptURL(x1),
      nL: x0 => globalThis.firebase_database.get(x0),
      nM: x0 => x0.providerId,
      nN: (x0,x1) => globalThis.firebase_firestore.doc(x0,x1),
      nO: x0 => x0.type,
      o: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      oB: Function.prototype.call.bind(DataView.prototype.setInt16),
      oC: (x0,x1) => { x0.id = x1 },
      oD: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      oE: x0 => x0.offsetTop,
      oF: Function.prototype.call.bind(DataView.prototype.setBigInt64),
      oG: (x0,x1) => { x0.name = x1 },
      oH: x0 => x0.buffer,
      oI: x0 => x0.frameCount,
      oJ: (x0,x1) => { x0.download = x1 },
      oK: x0 => x0.head,
      oL: x0 => x0.toJSON(),
      oM: x0 => globalThis.firebase_auth.OAuthProvider.credentialFromResult(x0),
      oN: (x0,x1,x2) => x0.set(x1,x2),
      oO: x0 => x0.docChanges(),
      p: b => !!b,
      pB: Function.prototype.call.bind(DataView.prototype.setUint16),
      pC: (x0,x1) => { x0.nonce = x1 },
      pD: x0 => x0.visibilityState,
      pE: x0 => x0.scrollLeft,
      pF: (o, start, length) => new BigInt64Array(o.buffer, o.byteOffset + start, length),
      pG: (x0,x1) => { x0.placeholder = x1 },
      pH: x0 => x0.wasmMemory,
      pI: x0 => x0.selectedTrack,
      pJ: (x0,x1) => { x0.href = x1 },
      pK: (x0,x1) => { x0.nonce = x1 },
      pL: (x0,x1) => globalThis.firebase_database.ref(x0,x1),
      pM: x0 => x0.username,
      pN: x0 => globalThis.firebase_firestore.Timestamp.fromMillis(x0),
      pO: x0 => x0.docs,
      q: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      qB: Function.prototype.call.bind(DataView.prototype.setUint8),
      qC: x0 => x0.nonce,
      qD: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      qE: x0 => x0.offsetLeft,
      qF: (x0,x1,x2,x3) => x0.pushState(x1,x2,x3),
      qG: (x0,x1) => { x0.action = x1 },
      qH: () => globalThis.window._flutter_skwasmInstance,
      qI: x0 => x0.completed,
      qJ: (x0,x1) => x0.getRandomValues(x1),
      qK: (x0,x1) => x0.querySelectorAll(x1),
      qL: (x0,x1) => globalThis.firebase_database.getDatabase(x0,x1),
      qM: x0 => x0.providerId,
      qN: (wasmFunction,f) => finalizeWrapper(f, function() { return wasmFunction(f,arguments.length) }),
      qO: x0 => globalThis.firebase_firestore.getDocs(x0),
      r: (x0,x1) => x0.focus(x1),
      rB: Function.prototype.call.bind(DataView.prototype.setInt8),
      rC: () => globalThis.window.flutterConfiguration,
      rD: x0 => x0.disconnect(),
      rE: x0 => x0.offsetParent,
      rF: x0 => x0.history,
      rG: (x0,x1) => { x0.method = x1 },
      rH: () => new TextDecoder(),
      rI: x0 => x0.ready,
      rJ: () => globalThis.crypto,
      rK: (x0,x1) => x0.item(x1),
      rL: x0 => x0.measurementId,
      rM: x0 => x0.profile,
      rN: () => globalThis.firebase_firestore.serverTimestamp(),
      rO: x0 => globalThis.firebase_firestore.getDocsFromServer(x0),
      s: () => ({}),
      sB: Function.prototype.call.bind(DataView.prototype.getInt8),
      sC: (x0,x1) => x0.attachShadow(x1),
      sD: x0 => new Intl.Locale(x0),
      sE: (o, p, r) => o.replace(p, () => r),
      sF: x0 => x0.search,
      sG: (x0,x1) => { x0.noValidate = x1 },
      sH: (a, i) => a.splice(i, 1),
      sI: x0 => x0.tracks,
      sJ: l => new DataView(new ArrayBuffer(l)),
      sK: x0 => x0.nonce,
      sL: x0 => x0.appId,
      sM: x0 => x0.isNewUser,
      sN: x0 => new firebase_firestore.FieldPath(x0),
      sO: x0 => globalThis.firebase_firestore.getDocsFromCache(x0),
      t: (o, p, v) => o[p] = v,
      tB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Int8Array) return 1;
        return 2;
      },
      tC: (x0,x1) => x0.createElement(x1),
      tD: x0 => x0.region,
      tE: (o, p, r) => o.replaceAll(p, () => r),
      tF: x0 => x0.location,
      tG: (x0,x1) => x0.removeAttribute(x1),
      tH: a => a.pop(),
      tI: x0 => x0.close(),
      tJ: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      tK: x0 => x0.length,
      tL: x0 => x0.messagingSenderId,
      tM: x0 => globalThis.firebase_auth.getAdditionalUserInfo(x0),
      tN: (x0,x1) => new firebase_firestore.FieldPath(x0,x1),
      tO: (x0,x1,x2) => globalThis.firebase_firestore.where(x0,x1,x2),
      u: () => [],
      uB: (o, start, length) => new Float64Array(o.buffer, o.byteOffset + start, length),
      uC: x0 => x0.scale,
      uD: x0 => x0.script,
      uE: x0 => x0.deltaMode,
      uF: x0 => x0.pathname,
      uG: x0 => x0.isConnected,
      uH: (map, o, v) => map.set(o, v),
      uI: (x0,x1) => ({frameIndex: x0,completeFramesOnly: x1}),
      uJ: x0 => x0.close(),
      uK: x0 => x0.document,
      uL: x0 => x0.authDomain,
      uM: x0 => globalThis.firebase_auth.OAuthProvider.credentialFromError(x0),
      uN: (x0,x1,x2) => new firebase_firestore.FieldPath(x0,x1,x2),
      uO: (x0,x1) => globalThis.firebase_firestore.query(x0,x1),
      v: (a, i) => a.push(i),
      vB: (o, start, length) => new Float32Array(o.buffer, o.byteOffset + start, length),
      vC: x0 => x0.visualViewport,
      vD: x0 => x0.language,
      vE: x0 => x0.deltaY,
      vF: (x0,x1,x2,x3) => x0.replaceState(x1,x2,x3),
      vG: x0 => x0.click(),
      vH: (map, o) => map.get(o),
      vI: (x0,x1) => x0.decode(x1),
      vJ: (x0,x1) => x0.alert(x1),
      vK: (x0,x1) => { x0.src = x1 },
      vL: x0 => x0.projectId,
      vM: x0 => x0.session,
      vN: (x0,x1,x2,x3) => new firebase_firestore.FieldPath(x0,x1,x2,x3),
      vO: () => globalThis.firebase_firestore.and,
      w: x0 => new Int8Array(x0),
      wB: (o, start, length) => new Uint32Array(o.buffer, o.byteOffset + start, length),
      wC: x0 => x0.devicePixelRatio,
      wD: x0 => x0.languages,
      wE: x0 => x0.deltaX,
      wF: o => {
        const proto = Object.getPrototypeOf(o);
        return proto === Object.prototype || proto === null;
      },
      wG: (x0,x1) => x0.getElementsByClassName(x1),
      wH: () => new WeakMap(),
      wI: x0 => x0.displayHeight,
      wJ: x0 => x0.getRegistrations(),
      wK: (x0,x1) => { x0.src = x1 },
      wL: x0 => x0.name,
      wM: x0 => x0.phoneNumber,
      wN: (x0,x1,x2,x3,x4) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4),
      wO: () => globalThis.firebase_firestore.or,
      x: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI8ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      xB: (o, start, length) => new Int32Array(o.buffer, o.byteOffset + start, length),
      xC: x0 => x0.height,
      xD: (x0,x1) => x0.observe(x1),
      xE: x0 => x0.wheelDeltaY,
      xF: o => Object.keys(o),
      xG: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      xH: x0 => x0.debugSkipFontRetryDelay,
      xI: x0 => x0.displayWidth,
      xJ: x0 => x0.unregister(),
      xK: (x0,x1) => { x0.defer = x1 },
      xL: (x0,x1,x2,x3,x4,x5,x6,x7) => ({apiKey: x0,authDomain: x1,databaseURL: x2,projectId: x3,storageBucket: x4,messagingSenderId: x5,measurementId: x6,appId: x7}),
      xM: x0 => x0.uid,
      xN: (x0,x1,x2,x3,x4,x5) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4,x5),
      xO: x0 => globalThis.firebase_firestore.limitToLast(x0),
      y: x0 => new Uint8Array(x0),
      yB: (o, start, length) => new Uint16Array(o.buffer, o.byteOffset + start, length),
      yC: x0 => x0.width,
      yD: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      yE: x0 => x0.wheelDeltaX,
      yF: x0 => x0.state,
      yG: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF64ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      yH: (x0,x1,x2) => x0.set(x1,x2),
      yI: x0 => x0.duration,
      yJ: x0 => x0.keys(),
      yK: (x0,x1) => { x0.async = x1 },
      yL: (x0,x1) => globalThis.firebase_core.initializeApp(x0,x1),
      yM: x0 => x0.enrollmentTime,
      yN: (x0,x1,x2,x3,x4,x5,x6) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4,x5,x6),
      yO: x0 => globalThis.firebase_firestore.limit(x0),
      z: x0 => new Uint8ClampedArray(x0),
      zB: (o, start, length) => new Int16Array(o.buffer, o.byteOffset + start, length),
      zC: x0 => x0.screen,
      zD: x0 => new ResizeObserver(x0),
      zE: x0 => x0.key,
      zF: x0 => x0.hash,
      zG: (x0,x1) => x0.dispatchEvent(x1),
      zH: x0 => x0.fontFallbackBaseUrl,
      zI: x0 => x0.image,
      zJ: (x0,x1) => x0.delete(x1),
      zK: x0 => x0.trustedTypes,
      zL: x0 => x0.storageBucket,
      zM: x0 => x0.factorId,
      zN: (x0,x1,x2,x3,x4,x5,x6,x7) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4,x5,x6,x7),
      zO: () => globalThis.firebase_firestore.endBefore,

    };

    const baseImports = {
      _: dart2wasm,
      Math: Math,
      Date: Date,
      Object: Object,
      Array: Array,
      Reflect: Reflect,
      WebAssembly: {
        JSTag: WebAssembly.JSTag,
      },
      "": new Proxy({}, { get(_, prop) { return prop; } }),

    };

    const jsStringPolyfill = {
      "charCodeAt": (s, i) => s.charCodeAt(i),
      "compare": (s1, s2) => {
        if (s1 < s2) return -1;
        if (s1 > s2) return 1;
        return 0;
      },
      "concat": (s1, s2) => s1 + s2,
      "equals": (s1, s2) => s1 === s2,
      "fromCharCode": (i) => String.fromCharCode(i),
      "length": (s) => s.length,
      "substring": (s, a, b) => s.substring(a, b),
      "fromCharCodeArray": (a, start, end) => {
        if (end <= start) return '';

        const read = dartInstance.exports.$wasmI16ArrayGet;
        let result = '';
        let index = start;
        const chunkLength = Math.min(end - index, 500);
        let array = new Array(chunkLength);
        while (index < end) {
          const newChunkLength = Math.min(end - index, 500);
          for (let i = 0; i < newChunkLength; i++) {
            array[i] = read(a, index++);
          }
          if (newChunkLength < chunkLength) {
            array = array.slice(0, newChunkLength);
          }
          result += String.fromCharCode(...array);
        }
        return result;
      },
      "intoCharCodeArray": (s, a, start) => {
        if (s === '') return 0;

        const write = dartInstance.exports.$wasmI16ArraySet;
        for (var i = 0; i < s.length; ++i) {
          write(a, start++, s.charCodeAt(i));
        }
        return s.length;
      },
      "test": (s) => typeof s == "string",
    };


    

    dartInstance = await WebAssembly.instantiate(this.module, {
      ...baseImports,
      ...additionalImports,
      
      "wasm:js-string": jsStringPolyfill,
    });

    return new InstantiatedApp(this, dartInstance);
  }
}

class InstantiatedApp {
  constructor(compiledApp, instantiatedModule) {
    this.compiledApp = compiledApp;
    this.instantiatedModule = instantiatedModule;
  }

  // Call the main function with the given arguments.
  invokeMain(...args) {
    this.instantiatedModule.exports.$invokeMain(args);
  }
}
