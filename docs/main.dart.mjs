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
      AG: (x0,x1) => x0.go(x1),
      AH: (x0,x1,x2,x3) => x0.initEvent(x1,x2,x3),
      AI: (ms, c) =>
      setInterval(() => dartInstance.exports.$invokeCallback(c), ms),
      AJ: x0 => ({type: x0}),
      AK: x0 => x0.length,
      AL: (x0,x1) => globalThis.firebase_core.initializeApp(x0,x1),
      AM: x0 => x0.enrollmentTime,
      AN: (x0,x1,x2,x3,x4) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4),
      AO: () => globalThis.firebase_firestore.startAt,
      B: s => printToConsole(s),
      BB: x0 => new Uint16Array(x0),
      BC: (o, start, length) => new Uint8Array(o.buffer, o.byteOffset + start, length),
      BD: x0 => x0.tabIndex,
      BE: x0 => globalThis.parseFloat(x0),
      BF: x0 => x0.touches,
      BG: x0 => x0.parentElement,
      BH: x0 => x0.readText(),
      BI: () => Date.now(),
      BJ: (x0,x1) => new Blob(x0,x1),
      BK: (x0,x1,x2) => x0.setItem(x1,x2),
      BL: x0 => x0.storageBucket,
      BM: x0 => x0.factorId,
      BN: (x0,x1,x2,x3,x4,x5) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4,x5),
      BO: (x0,x1) => globalThis.firebase_firestore.orderBy(x0,x1),
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
      CG: (x0,x1) => x0.querySelectorAll(x1),
      CH: x0 => x0.clipboard,
      CI: x0 => new WeakRef(x0),
      CJ: x0 => globalThis.URL.createObjectURL(x0),
      CK: (x0,x1) => x0.getItem(x1),
      CL: x0 => x0.databaseURL,
      CM: x0 => x0.displayName,
      CN: (x0,x1,x2,x3,x4,x5,x6) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4,x5,x6),
      CO: (x0,x1) => globalThis.firebase_firestore.collection(x0,x1),
      D: Function.prototype.call.bind(BigInt.prototype.toString),
      DB: x0 => new Int32Array(x0),
      DC: (x0,x1) => x0.querySelector(x1),
      DD: x0 => x0.activeElement,
      DE: x0 => x0.documentElement,
      DF: x0 => x0.tiltY,
      DG: (x0,x1) => x0.requestAnimationFrame(x1),
      DH: (x0,x1) => x0.writeText(x1),
      DI: x0 => x0.deref(),
      DJ: (x0,x1) => x0.appendChild(x1),
      DK: (x0,x1) => x0.querySelector(x1),
      DL: x0 => x0.apiKey,
      DM: x0 => x0.hints,
      DN: (x0,x1,x2,x3,x4,x5,x6,x7) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4,x5,x6,x7),
      DO: x0 => x0.length,
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
      EG: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      EH: x0 => x0.unlock(),
      EI: () => globalThis.WeakRef,
      EJ: x0 => x0.click(),
      EK: (x0,x1) => x0.getAttribute(x1),
      EL: x0 => x0.options,
      EM: x0 => x0.tenantId,
      EN: (x0,x1,x2,x3,x4,x5,x6,x7,x8) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4,x5,x6,x7,x8),
      EO: x0 => x0.getReader(),
      F: () => new Error().stack,
      FB: x0 => new Uint32Array(x0),
      FC: x0 => x0.length,
      FD: x0 => x0.tagName,
      FE: (x0,x1) => x0.get(x1),
      FF: x0 => x0.pointerType,
      FG: x0 => x0.now(),
      FH: (x0,x1) => x0.lock(x1),
      FI: (o, offsetInBytes, lengthInBytes) => {
        var dst = new ArrayBuffer(lengthInBytes);
        new Uint8Array(dst).set(new Uint8Array(o, offsetInBytes, lengthInBytes));
        return new DataView(dst);
      },
      FJ: x0 => x0.remove(),
      FK: (x0,x1) => x0.debug(x1),
      FL: () => globalThis.firebase_core.SDK_VERSION,
      FM: x0 => x0.phoneNumber,
      FN: (x0,x1,x2,x3,x4,x5,x6,x7,x8,x9) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4,x5,x6,x7,x8,x9),
      FO: x0 => x0.value,
      G: s => JSON.stringify(s),
      GB: x0 => new Float32Array(x0),
      GC: (x0,x1) => x0.querySelectorAll(x1),
      GD: x0 => x0.target,
      GE: (o, p) => p in o,
      GF: x0 => x0.pointerId,
      GG: x0 => x0.performance,
      GH: x0 => x0.orientation,
      GI: (a, s, e) => a.slice(s, e),
      GJ: x0 => globalThis.URL.revokeObjectURL(x0),
      GK: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      GL: (x0,x1,x2) => globalThis.firebase_core.registerVersion(x0,x1,x2),
      GM: x0 => x0.email,
      GN: () => globalThis.firebase_firestore.documentId(),
      GO: x0 => x0.done,
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
      HG: (d, digits) => d.toFixed(digits),
      HH: (x0,x1) => x0.querySelector(x1),
      HI: (x0,x1) => x0.assign(x1),
      HJ: x0 => x0.body,
      HK: x0 => ({createScriptURL: x0}),
      HL: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      HM: (x0,x1) => globalThis.firebase_auth.getMultiFactorResolver(x0,x1),
      HN: (x0,x1) => new firebase_firestore.GeoPoint(x0,x1),
      HO: x0 => x0.read(),
      I: Function.prototype.call.bind(String.prototype.indexOf),
      IB: x0 => new Float64Array(x0),
      IC: x0 => x0.remove(),
      ID: x0 => x0.clientX,
      IE: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      IF: (x0,x1) => x0.getModifierState(x1),
      IG: x0 => x0.maxHeight,
      IH: (x0,x1) => { x0.title = x1 },
      II: x0 => x0.pathname,
      IJ: () => globalThis.document,
      IK: (x0,x1,x2) => x0.createPolicy(x1,x2),
      IL: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      IM: x0 => x0.customData,
      IN: x0 => globalThis.firebase_firestore.vector(x0),
      IO: x0 => x0.body,
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
      JG: x0 => x0.maxWidth,
      JH: (x0,x1) => x0.vibrate(x1),
      JI: x0 => x0.origin,
      JJ: (x0,x1) => { x0.download = x1 },
      JK: (x0,x1) => x0.createScriptURL(x1),
      JL: (x0,x1) => ({createScript: x0,createScriptURL: x1}),
      JM: x0 => x0.message,
      JN: x0 => globalThis.firebase_firestore.Bytes.fromUint8Array(x0),
      JO: (x0,x1) => new OffscreenCanvas(x0,x1),
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
      KG: x0 => x0.minHeight,
      KH: x0 => x0.arrayBuffer(),
      KI: x0 => x0.location,
      KJ: (x0,x1) => { x0.href = x1 },
      KK: x0 => x0.head,
      KL: (x0,x1) => x0.createScriptURL(x1),
      KM: x0 => x0.code,
      KN: (x0,x1) => globalThis.firebase_firestore.doc(x0,x1),
      KO: x0 => x0.assetBase,
      L: o => o === undefined,
      LB: (x0,x1,x2) => new Uint8Array(x0,x1,x2),
      LC: (x0,x1,x2,x3) => x0.setProperty(x1,x2,x3),
      LD: (ms, c) =>
      setTimeout(() => dartInstance.exports.$invokeCallback(c),ms),
      LE: x0 => x0.matches,
      LF: (x0,x1) => x0.test(x1),
      LG: x0 => x0.minWidth,
      LH: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof ArrayBuffer) return 1;
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
          return 2;
        }
        return 3;
      },
      LI: (x0,x1,x2) => x0.insertBefore(x1,x2),
      LJ: (x0,x1) => x0.createElement(x1),
      LK: (x0,x1) => { x0.nonce = x1 },
      LL: (x0,x1,x2) => x0.createScript(x1,x2),
      LM: (x0,x1,x2) => globalThis.firebase_auth.createUserWithEmailAndPassword(x0,x1,x2),
      LN: (x0,x1) => globalThis.firebase_firestore.getFirestore(x0,x1),
      LO: x0 => x0.loader,
      M: o => String(o),
      MB: (x0,x1,x2) => new DataView(x0,x1,x2),
      MC: x0 => x0.style,
      MD: s => new Date(s * 1000).getTimezoneOffset() * 60,
      ME: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
      MF: (x0,x1) => x0[x1],
      MG: (x0,x1) => x0.removeProperty(x1),
      MH: x0 => x0.status,
      MI: x0 => x0.id,
      MJ: (x0,x1) => x0.getRandomValues(x1),
      MK: (x0,x1) => x0.querySelectorAll(x1),
      ML: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      MM: (x0,x1,x2) => ({errorMap: x0,persistence: x1,popupRedirectResolver: x2}),
      MN: x0 => x0.path,
      MO: () => globalThis._flutter,
      N: (c) =>
      queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
      NB: (o, p) => o[p],
      NC: x0 => x0.debugShowSemanticsNodes,
      ND: Date.now,
      NE: f => f.dartFunction,
      NF: x0 => x0.index,
      NG: (x0,x1) => x0.add(x1),
      NH: (x0,x1) => x0.fetch(x1),
      NI: x0 => x0.offsetHeight,
      NJ: () => globalThis.crypto,
      NK: (x0,x1) => x0.item(x1),
      NL: (o, p) => delete o[p],
      NM: (x0,x1) => globalThis.firebase_auth.initializeAuth(x0,x1),
      NN: x0 => x0.path,
      O: (x0,x1) => x0.didCreateEngineInitializer(x1),
      OB: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
      OC: o => o,
      OD: (handle) => clearTimeout(handle),
      OE: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      OF: x0 => x0.flags,
      OG: x0 => x0.data,
      OH: x0 => x0.content,
      OI: x0 => x0.offsetWidth,
      OJ: l => new DataView(new ArrayBuffer(l)),
      OK: x0 => x0.nonce,
      OL: (o, p, v) => o[p] = v,
      OM: () => globalThis.firebase_auth.browserPopupRedirectResolver,
      ON: x0 => x0.fromCache,
      P: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      PB: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
      PC: o => {
        if (o === undefined || o === null) return 0;
        if (typeof o === 'boolean') return 1;
        return 2;
      },
      PD: (x0,x1) => x0.closest(x1),
      PE: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      PF: (a, s) => a.join(s),
      PG: (x0,x1) => { x0.scrollTop = x1 },
      PH: x0 => x0.document,
      PI: x0 => x0.stopPropagation(),
      PJ: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      PK: x0 => x0.length,
      PL: (x0,x1) => { x0.text = x1 },
      PM: () => globalThis.firebase_auth.debugErrorMap,
      PN: x0 => x0.hasPendingWrites,
      Q: (wasmFunction,f) => finalizeWrapper(f, function() { return wasmFunction(f,arguments.length) }),
      QB: o => o.byteOffset,
      QC: (x0,x1) => x0.warn(x1),
      QD: x0 => x0.bottom,
      QE: (p, s, f) => p.then(s, (e) => f(e, e === undefined)),
      QF: (x0,x1) => x0.error(x1),
      QG: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      QH: () => typeof dartUseDateNowForTicks !== "undefined",
      QI: x0 => x0.disabled,
      QJ: x0 => x0.close(),
      QK: x0 => x0.document,
      QL: (x0,x1) => { x0.text = x1 },
      QM: () => globalThis.firebase_auth.browserSessionPersistence,
      QN: x0 => x0.metadata,
      R: (x0,x1) => ({initializeEngine: x0,autoStart: x1}),
      RB: o => o.buffer,
      RC: x0 => x0.console,
      RD: x0 => x0.top,
      RE: (o, i) => o[i],
      RF: () => globalThis.console,
      RG: (x0,x1) => { x0.value = x1 },
      RH: () => Date.now(),
      RI: (x0,x1) => { x0.min = x1 },
      RJ: (x0,x1) => x0.alert(x1),
      RK: (x0,x1) => { x0.src = x1 },
      RL: x0 => x0.trustedTypes,
      RM: () => globalThis.firebase_auth.browserLocalPersistence,
      RN: x0 => ({serverTimestamps: x0}),
      S: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      SB: Function.prototype.call.bind(DataView.prototype.getUint8),
      SC: () => globalThis.window,
      SD: x0 => x0.right,
      SE: o => o.length,
      SF: s => s.trimRight(),
      SG: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      SH: () => 1000 * performance.now(),
      SI: (x0,x1) => { x0.max = x1 },
      SJ: x0 => x0.getRegistrations(),
      SK: (x0,x1) => { x0.src = x1 },
      SL: (x0,x1) => { x0.crossOrigin = x1 },
      SM: () => globalThis.firebase_auth.indexedDBLocalPersistence,
      SN: x0 => x0.metadata,
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
      TF: x0 => x0.blur(),
      TG: (x0,x1) => { x0.value = x1 },
      TH: x0 => new Uint8Array(x0),
      TI: (x0,x1) => { x0.disabled = x1 },
      TJ: x0 => x0.unregister(),
      TK: (x0,x1) => { x0.defer = x1 },
      TL: (x0,x1) => { x0.type = x1 },
      TM: x0 => x0.signOut(),
      TN: x0 => x0.toArray(),
      U: (x0,x1,x2) => x0.call(x1,x2),
      UB: (b, o, l) => new DataView(b, o, l),
      UC: (x0,x1) => x0.exec(x1),
      UD: x0 => x0.clientY,
      UE: x0 => x0.language,
      UF: x0 => x0.button,
      UG: s => {
        if (/[[\]{}()*+?.\\^$|]/.test(s)) {
            s = s.replace(/[[\]{}()*+?.\\^$|]/g, '\\$&');
        }
        return s;
      },
      UH: (x0,x1,x2) => x0.slice(x1,x2),
      UI: (x0,x1) => { x0.scrollLeft = x1 },
      UJ: x0 => x0.keys(),
      UK: (x0,x1) => { x0.async = x1 },
      UL: x0 => x0.providerId,
      UM: (x0,x1,x2) => globalThis.firebase_auth.signInWithEmailAndPassword(x0,x1,x2),
      UN: x0 => x0.toUint8Array(),
      V: (constructor, args) => {
        const factoryFunction = constructor.bind.apply(
            constructor, [null, ...args]);
        return new factoryFunction();
      },
      VB: Function.prototype.call.bind(DataView.prototype.getFloat64),
      VC: x0 => x0.length,
      VD: x0 => x0.clientX,
      VE: (x0,x1,x2,x3) => x0.register(x1,x2,x3),
      VF: x0 => x0.innerHeight,
      VG: x0 => x0.value,
      VH: (x0,x1) => x0.decode(x1),
      VI: (x0,x1) => { x0.spellcheck = x1 },
      VJ: (x0,x1) => x0.delete(x1),
      VK: x0 => x0.trustedTypes,
      VL: x0 => x0.uid,
      VM: x0 => x0.call(),
      VN: () => globalThis.firebase_firestore.Bytes,
      W: x0 => new Array(x0),
      WB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Float64Array) return 1;
        return 2;
      },
      WC: (x0,x1) => { x0.lastIndex = x1 },
      WD: x0 => x0.changedTouches,
      WE: () => globalThis.window.FinalizationRegistry,
      WF: x0 => x0.innerWidth,
      WG: x0 => x0.selectionDirection,
      WH: (x0,x1) => x0.adoptText(x1),
      WI: (x0,x1) => { x0.disabled = x1 },
      WJ: x0 => x0.clear(),
      WK: () => globalThis.console,
      WL: x0 => x0.providerData,
      WM: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      WN: () => globalThis.firebase_firestore.VectorValue,
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
      XF: x0 => x0.height,
      XG: x0 => x0.selectionStart,
      XH: x0 => x0.first(),
      XI: (x0,x1,x2) => x0.open(x1,x2),
      XJ: x0 => x0.sessionStorage,
      XK: x0 => x0.trustedTypes,
      XL: x0 => x0.tenantId,
      XM: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      XN: x0 => x0.longitude,
      Y: (o0, o1) => [o0, o1],
      YB: (t, s) => t.set(s),
      YC: o => o instanceof RegExp,
      YD: x0 => x0.offsetX,
      YE: x0 => new window.FinalizationRegistry(x0),
      YF: x0 => x0.width,
      YG: x0 => x0.selectionEnd,
      YH: x0 => x0.next(),
      YI: (x0,x1) => x0.revokeObjectURL(x1),
      YJ: x0 => x0.localStorage,
      YK: (wasmFunction,f) => finalizeWrapper(f, function() { return wasmFunction(f,arguments.length) }),
      YL: x0 => x0.refreshToken,
      YM: (x0,x1,x2) => x0.onIdTokenChanged(x1,x2),
      YN: x0 => x0.latitude,
      Z: (o0, o1, o2) => [o0, o1, o2],
      ZB: Function.prototype.call.bind(DataView.prototype.setFloat32),
      ZC: (string, times) => string.repeat(times),
      ZD: x0 => x0.type,
      ZE: (x0,x1) => x0.unregister(x1),
      ZF: x0 => x0.clientHeight,
      ZG: x0 => x0.value,
      ZH: x0 => x0.current(),
      ZI: (x0,x1) => { x0.src = x1 },
      ZJ: x0 => x0.caches,
      ZK: x0 => { globalThis.onGoogleLibraryLoad = x0 },
      ZL: x0 => x0.photoURL,
      ZM: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      ZN: () => globalThis.firebase_firestore.GeoPoint,
      a: (o0, o1, o2, o3) => [o0, o1, o2, o3],
      aB: Function.prototype.call.bind(DataView.prototype.getFloat32),
      aC: x0 => x0.dotAll,
      aD: x0 => x0.maxTouchPoints,
      aE: (x0,x1) => x0.contains(x1),
      aF: x0 => x0.clientWidth,
      aG: x0 => x0.selectionDirection,
      aH: (x0,x1) => new Intl.v8BreakIterator(x0,x1),
      aI: (x0,x1,x2,x3,x4) => globalThis.createImageBitmap(x0,x1,x2,x3,x4),
      aJ: x0 => x0.serviceWorker,
      aK: (x0,x1,x2) => x0.setAttribute(x1,x2),
      aL: x0 => x0.phoneNumber,
      aM: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      aN: (x0,x1) => x0.data(x1),
      b: (x0,x1,x2) => { x0[x1] = x2 },
      bB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Float32Array) return 1;
        return 2;
      },
      bC: x0 => x0.unicode,
      bD: x0 => x0.platform,
      bE: (s) => +s,
      bF: (x0,x1) => { x0.content = x1 },
      bG: x0 => x0.selectionStart,
      bH: x0 => x0.v8BreakIterator,
      bI: x0 => x0.naturalHeight,
      bJ: x0 => x0.navigator,
      bK: (x0,x1) => { x0.id = x1 },
      bL: x0 => x0.lastSignInTime,
      bM: (x0,x1,x2) => x0.onAuthStateChanged(x1,x2),
      bN: x0 => x0.nanoseconds,
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
      cF: (x0,x1) => { x0.name = x1 },
      cG: x0 => x0.selectionEnd,
      cH: () => globalThis.Intl,
      cI: x0 => x0.naturalWidth,
      cJ: () => globalThis.window,
      cK: (x0,x1) => globalThis.firebase_database.child(x0,x1),
      cL: x0 => x0.creationTime,
      cM: x0 => x0.currentUser,
      cN: x0 => x0.seconds,
      d: (o, p) => o[p],
      dB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Uint32Array) return 1;
        return 2;
      },
      dC: x0 => x0.multiline,
      dD: () => globalThis.document,
      dE: s => s.trim(),
      dF: x0 => x0.head,
      dG: x0 => x0.keyCode,
      dH: (x0,x1) => x0.segment(x1),
      dI: x0 => x0.decode(),
      dJ: (x0,x1) => x0.transferFromImageBitmap(x1),
      dK: x0 => x0.toJSON(),
      dL: x0 => x0.metadata,
      dM: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      dN: () => globalThis.firebase_firestore.Timestamp,
      e: () => globalThis,
      eB: Function.prototype.call.bind(DataView.prototype.getInt32),
      eC: (string, token) => string.split(token),
      eD: (x0,x1,x2) => x0.addEventListener(x1,x2),
      eE: x0 => x0.classList,
      eF: (x0,x1) => x0.removeChild(x1),
      eG: (x0,x1) => x0.scrollIntoView(x1),
      eH: x0 => x0.index,
      eI: (x0,x1) => { x0.decoding = x1 },
      eJ: (x0,x1) => x0.getContext(x1),
      eK: x0 => x0.message,
      eL: x0 => x0.isAnonymous,
      eM: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      eN: () => globalThis.firebase_firestore.DocumentReference,
      f: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      fB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Int32Array) return 1;
        return 2;
      },
      fC: o => o instanceof Array,
      fD: x0 => x0.hasFocus(),
      fE: x0 => x0.preventDefault(),
      fF: x0 => x0.firstChild,
      fG: x0 => x0.multiViewEnabled,
      fH: x0 => x0.next(),
      fI: (x0,x1) => { x0.crossOrigin = x1 },
      fJ: (x0,x1) => { x0.height = x1 },
      fK: (x0,x1) => globalThis.firebase_database.set(x0,x1),
      fL: x0 => x0.emailVerified,
      fM: (x0,x1) => globalThis.firebase_auth.connectAuthEmulator(x0,x1),
      fN: x0 => x0.ref,
      g: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      gB: o => o instanceof Uint16Array,
      gC: (a, i) => a[i],
      gD: x0 => x0.relatedTarget,
      gE: x0 => x0.parent,
      gF: x0 => x0.viewConstraints,
      gG: (x0,x1) => x0.replaceWith(x1),
      gH: x0 => x0.value,
      gI: (x0,x1) => x0.createObjectURL(x1),
      gJ: (x0,x1) => { x0.width = x1 },
      gK: (x0,x1) => globalThis.firebase_database.update(x0,x1),
      gL: x0 => x0.email,
      gM: x0 => x0.hostname,
      gN: x0 => x0.doc,
      h: (x0,x1) => ({addView: x0,removeView: x1}),
      hB: Function.prototype.call.bind(DataView.prototype.getUint16),
      hC: a => a.length,
      hD: x0 => x0.shiftKey,
      hE: x0 => x0.timeStamp,
      hF: x0 => x0.hostElement,
      hG: (x0,x1) => { x0.type = x1 },
      hH: x0 => x0.done,
      hI: x0 => x0.URL,
      hJ: x0 => x0.height,
      hK: x0 => x0.priority,
      hL: x0 => x0.displayName,
      hM: x0 => x0.token,
      hN: x0 => x0.newIndex,
      i: (l, r) => l === r,
      iB: o => o instanceof Int16Array,
      iC: x0 => x0.userAgent,
      iD: (decoder, codeUnits) => decoder.decode(codeUnits),
      iE: (x0,x1) => x0.hasAttribute(x1),
      iF: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      iG: (x0,x1) => { x0.className = x1 },
      iH: (o, m, a) => o[m].apply(o, a),
      iI: x0 => new Blob(x0),
      iJ: x0 => x0.width,
      iK: x0 => x0.val(),
      iL: x0 => globalThis.firebase_auth.multiFactor(x0),
      iM: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      iN: x0 => x0.oldIndex,
      j: x0 => x0.random(),
      jB: Function.prototype.call.bind(DataView.prototype.getInt16),
      jC: x0 => x0.navigator,
      jD: () => new TextDecoder("utf-8", {fatal: true}),
      jE: x0 => x0.buttons,
      jF: x0 => ({runApp: x0}),
      jG: (x0,x1) => { x0.tabIndex = x1 },
      jH: x0 => x0.iterator,
      jI: (x0,x1,x2,x3,x4) => ({type: x0,data: x1,premultiplyAlpha: x2,colorSpaceConversion: x3,preferAnimation: x4}),
      jJ: x0 => x0.rasterEndMilliseconds,
      jK: x0 => x0.key,
      jL: x0 => x0.toJSON(),
      jM: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      jN: x0 => x0.type,
      k: o => o,
      kB: o => o instanceof Uint8ClampedArray,
      kC: Function.prototype.call.bind(String.prototype.toLowerCase),
      kD: () => new TextDecoder("utf-8", {fatal: false}),
      kE: x0 => x0.ctrlKey,
      kF: x0 => new Event(x0),
      kG: (x0,x1) => { x0.name = x1 },
      kH: () => globalThis.Symbol,
      kI: x0 => new window.ImageDecoder(x0),
      kJ: x0 => x0.rasterStartMilliseconds,
      kK: x0 => x0.ref,
      kL: x0 => x0.user,
      kM: (x0,x1,x2) => globalThis.firebase_app_check.onTokenChanged(x0,x1,x2),
      kN: x0 => x0.docChanges(),
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
      lF: (x0,x1) => x0.dispatchEvent(x1),
      lG: (x0,x1) => { x0.placeholder = x1 },
      lH: (x0,x1) => new Intl.Segmenter(x0,x1),
      lI: x0 => x0.name,
      lJ: x0 => x0.imageBitmaps,
      lK: x0 => globalThis.firebase_database.get(x0),
      lL: x0 => x0.idToken,
      lM: x0 => new firebase_app_check.ReCaptchaV3Provider(x0),
      lN: x0 => x0.docs,
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
      mF: Function.prototype.call.bind(DataView.prototype.getBigInt64),
      mG: (x0,x1) => { x0.autocomplete = x1 },
      mH: x0 => x0.Segmenter,
      mI: x0 => x0.repetitionCount,
      mJ: x0 => x0.canvasKitMaximumSurfaces,
      mK: x0 => x0.toJSON(),
      mL: x0 => x0.secret,
      mM: x0 => new firebase_app_check.ReCaptchaEnterpriseProvider(x0),
      mN: x0 => globalThis.firebase_firestore.getDocs(x0),
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
      nF: Function.prototype.call.bind(DataView.prototype.setBigInt64),
      nG: (x0,x1) => { x0.name = x1 },
      nH: x0 => x0.buffer,
      nI: x0 => x0.frameCount,
      nJ: x0 => x0.hostElement,
      nK: (x0,x1) => globalThis.firebase_database.ref(x0,x1),
      nL: x0 => x0.accessToken,
      nM: x0 => ({provider: x0}),
      nN: x0 => globalThis.firebase_firestore.getDocsFromServer(x0),
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
      oF: (o, start, length) => new BigInt64Array(o.buffer, o.byteOffset + start, length),
      oG: (x0,x1) => { x0.placeholder = x1 },
      oH: x0 => x0.wasmMemory,
      oI: x0 => x0.selectedTrack,
      oJ: x0 => x0.location,
      oK: (x0,x1) => globalThis.firebase_database.getDatabase(x0,x1),
      oL: x0 => x0.signInMethod,
      oM: (x0,x1) => globalThis.firebase_app_check.initializeAppCheck(x0,x1),
      oN: x0 => globalThis.firebase_firestore.getDocsFromCache(x0),
      p: b => !!b,
      pB: Function.prototype.call.bind(DataView.prototype.setUint16),
      pC: (x0,x1) => { x0.nonce = x1 },
      pD: x0 => x0.visibilityState,
      pE: x0 => x0.scrollLeft,
      pF: (x0,x1,x2,x3) => x0.pushState(x1,x2,x3),
      pG: (x0,x1) => { x0.action = x1 },
      pH: () => globalThis.window._flutter_skwasmInstance,
      pI: x0 => x0.completed,
      pJ: (x0,x1) => x0.getModifierState(x1),
      pK: x0 => globalThis.firebase_core.getApp(x0),
      pL: x0 => x0.providerId,
      pM: (o, a) => o + a,
      pN: x0 => x0.source,
      q: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      qB: Function.prototype.call.bind(DataView.prototype.setUint8),
      qC: x0 => x0.nonce,
      qD: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      qE: x0 => x0.offsetLeft,
      qF: x0 => x0.history,
      qG: (x0,x1) => { x0.method = x1 },
      qH: () => new TextDecoder(),
      qI: x0 => x0.ready,
      qJ: x0 => x0.metaKey,
      qK: () => globalThis.firebase_core.getApp(),
      qL: x0 => globalThis.firebase_auth.OAuthProvider.credentialFromResult(x0),
      qM: x0 => x0.children,
      qN: x0 => ({source: x0}),
      r: (x0,x1) => x0.focus(x1),
      rB: Function.prototype.call.bind(DataView.prototype.setInt8),
      rC: () => globalThis.window.flutterConfiguration,
      rD: x0 => x0.disconnect(),
      rE: x0 => x0.offsetParent,
      rF: x0 => x0.search,
      rG: (x0,x1) => { x0.noValidate = x1 },
      rH: (a, i) => a.splice(i, 1),
      rI: x0 => x0.tracks,
      rJ: x0 => x0.altKey,
      rK: x0 => x0.measurementId,
      rL: x0 => x0.username,
      rM: x0 => globalThis.firebase_firestore.deleteDoc(x0),
      rN: (x0,x1,x2) => globalThis.firebase_firestore.where(x0,x1,x2),
      s: () => ({}),
      sB: Function.prototype.call.bind(DataView.prototype.getInt8),
      sC: (x0,x1) => x0.attachShadow(x1),
      sD: x0 => new Intl.Locale(x0),
      sE: (o, p, r) => o.replace(p, () => r),
      sF: x0 => x0.location,
      sG: (x0,x1) => x0.removeAttribute(x1),
      sH: a => a.pop(),
      sI: x0 => x0.close(),
      sJ: x0 => x0.ctrlKey,
      sK: x0 => x0.appId,
      sL: x0 => x0.providerId,
      sM: (x0,x1) => globalThis.firebase_firestore.setDoc(x0,x1),
      sN: (x0,x1) => globalThis.firebase_firestore.query(x0,x1),
      t: (o, p, v) => o[p] = v,
      tB: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Int8Array) return 1;
        return 2;
      },
      tC: (x0,x1) => x0.createElement(x1),
      tD: x0 => x0.region,
      tE: (o, p, r) => o.replaceAll(p, () => r),
      tF: x0 => x0.pathname,
      tG: x0 => x0.isConnected,
      tH: (map, o, v) => map.set(o, v),
      tI: (x0,x1) => ({frameIndex: x0,completeFramesOnly: x1}),
      tJ: x0 => x0.isComposing,
      tK: x0 => x0.messagingSenderId,
      tL: x0 => x0.profile,
      tM: x0 => globalThis.firebase_firestore.Timestamp.fromMillis(x0),
      tN: () => globalThis.firebase_firestore.and,
      u: () => [],
      uB: (o, start, length) => new Float64Array(o.buffer, o.byteOffset + start, length),
      uC: x0 => x0.scale,
      uD: x0 => x0.script,
      uE: x0 => x0.deltaMode,
      uF: (x0,x1,x2,x3) => x0.replaceState(x1,x2,x3),
      uG: x0 => x0.click(),
      uH: (map, o) => map.get(o),
      uI: (x0,x1) => x0.decode(x1),
      uJ: x0 => x0.code,
      uK: x0 => x0.authDomain,
      uL: x0 => x0.isNewUser,
      uM: (wasmFunction,f) => finalizeWrapper(f, function() { return wasmFunction(f,arguments.length) }),
      uN: () => globalThis.firebase_firestore.or,
      v: (a, i) => a.push(i),
      vB: (o, start, length) => new Float32Array(o.buffer, o.byteOffset + start, length),
      vC: x0 => x0.visualViewport,
      vD: x0 => x0.language,
      vE: x0 => x0.deltaY,
      vF: o => {
        const proto = Object.getPrototypeOf(o);
        return proto === Object.prototype || proto === null;
      },
      vG: (x0,x1) => x0.getElementsByClassName(x1),
      vH: () => new WeakMap(),
      vI: x0 => x0.displayHeight,
      vJ: x0 => x0.repeat,
      vK: x0 => x0.projectId,
      vL: x0 => globalThis.firebase_auth.getAdditionalUserInfo(x0),
      vM: () => globalThis.firebase_firestore.serverTimestamp(),
      vN: x0 => globalThis.firebase_firestore.limitToLast(x0),
      w: x0 => new Int8Array(x0),
      wB: (o, start, length) => new Uint32Array(o.buffer, o.byteOffset + start, length),
      wC: x0 => x0.devicePixelRatio,
      wD: x0 => x0.languages,
      wE: x0 => x0.deltaX,
      wF: o => Object.keys(o),
      wG: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      wH: x0 => x0.debugSkipFontRetryDelay,
      wI: x0 => x0.displayWidth,
      wJ: (wasmFunction,f) => finalizeWrapper(f, function(x0) { return wasmFunction(f,arguments.length,x0) }),
      wK: x0 => x0.name,
      wL: x0 => globalThis.firebase_auth.OAuthProvider.credentialFromError(x0),
      wM: x0 => new firebase_firestore.FieldPath(x0),
      wN: x0 => globalThis.firebase_firestore.limit(x0),
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
      xF: x0 => x0.state,
      xG: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF64ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      xH: (x0,x1,x2) => x0.set(x1,x2),
      xI: x0 => x0.duration,
      xJ: x0 => x0.userAgent,
      xK: x0 => x0.code,
      xL: x0 => x0.session,
      xM: (x0,x1) => new firebase_firestore.FieldPath(x0,x1),
      xN: () => globalThis.firebase_firestore.endBefore,
      y: x0 => new Uint8Array(x0),
      yB: (o, start, length) => new Uint16Array(o.buffer, o.byteOffset + start, length),
      yC: x0 => x0.width,
      yD: (wasmFunction,f) => finalizeWrapper(f, function(x0,x1) { return wasmFunction(f,arguments.length,x0,x1) }),
      yE: x0 => x0.wheelDeltaX,
      yF: x0 => x0.hash,
      yG: (x0,x1) => x0.dispatchEvent(x1),
      yH: x0 => x0.fontFallbackBaseUrl,
      yI: x0 => x0.image,
      yJ: (x0,x1) => x0.removeItem(x1),
      yK: x0 => x0.name,
      yL: x0 => x0.phoneNumber,
      yM: (x0,x1,x2) => new firebase_firestore.FieldPath(x0,x1,x2),
      yN: () => globalThis.firebase_firestore.endAt,
      z: x0 => new Uint8ClampedArray(x0),
      zB: (o, start, length) => new Int16Array(o.buffer, o.byteOffset + start, length),
      zC: x0 => x0.screen,
      zD: x0 => new ResizeObserver(x0),
      zE: x0 => x0.key,
      zF: x0 => x0.state,
      zG: (x0,x1) => x0.createEvent(x1),
      zH: (handle) => clearInterval(handle),
      zI: () => globalThis.window.ImageDecoder,
      zJ: (x0,x1) => x0.key(x1),
      zK: (x0,x1,x2,x3,x4,x5,x6,x7) => ({apiKey: x0,authDomain: x1,databaseURL: x2,projectId: x3,storageBucket: x4,messagingSenderId: x5,measurementId: x6,appId: x7}),
      zL: x0 => x0.uid,
      zM: (x0,x1,x2,x3) => new firebase_firestore.FieldPath(x0,x1,x2,x3),
      zN: () => globalThis.firebase_firestore.startAfter,

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
