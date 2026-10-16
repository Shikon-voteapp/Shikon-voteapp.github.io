import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

/// Shows group artwork from Firebase Storage.
class StorageImage extends StatelessWidget {
  static final Map<String, Future<String>> _downloadUrls =
      <String, Future<String>>{};
  static final Map<String, Set<({int? width, int? height})>> _decodeSizes =
      <String, Set<({int? width, int? height})>>{};
  final String path;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final ImageErrorWidgetBuilder? errorBuilder;

  const StorageImage({
    super.key,
    required this.path,
    this.fit,
    this.width,
    this.height,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) return SizedBox(width: width, height: height);
    final url = _downloadUrl(path);
    return FutureBuilder<String>(
      key: ValueKey(path),
      future: url,
      builder: (context, snapshot) {
        if (snapshot.hasError || !snapshot.hasData) {
          if (snapshot.hasError && errorBuilder != null) {
            return errorBuilder!(context, snapshot.error!, StackTrace.current);
          }
          return SizedBox(width: width, height: height);
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
            int? decodeDimension(double dimension) {
              if (!dimension.isFinite || dimension <= 0) return null;
              return (dimension * devicePixelRatio).ceil();
            }

            final cacheWidth = decodeDimension(constraints.maxWidth);
            final cacheHeight = decodeDimension(constraints.maxHeight);
            _rememberDecodeSize(path, cacheWidth, cacheHeight);
            return Image.network(
              snapshot.data!,
              fit: fit,
              width: width,
              height: height,
              cacheWidth: cacheWidth,
              cacheHeight: cacheHeight,
              errorBuilder: errorBuilder,
            );
          },
        );
      },
    );
  }

  static Future<String> _downloadUrl(String path) {
    if (path.startsWith('https://')) return Future<String>.value(path);
    final cached = _downloadUrls[path];
    if (cached != null) return cached;

    // Keep the URL cache bounded during long-running sessions.
    if (_downloadUrls.length >= 400) {
      final oldestPath = _downloadUrls.keys.first;
      _downloadUrls.remove(oldestPath);
      _decodeSizes.remove(oldestPath);
    }
    late final Future<String> cachedFuture;
    cachedFuture = FirebaseStorage.instance
        .ref(path)
        .getDownloadURL()
        .catchError((Object error, StackTrace stackTrace) {
          if (identical(_downloadUrls[path], cachedFuture)) {
            _downloadUrls.remove(path);
          }
          Error.throwWithStackTrace(error, stackTrace);
        });
    _downloadUrls[path] = cachedFuture;
    return cachedFuture;
  }

  static Future<void> invalidate(String path) async {
    final cachedUrl = _downloadUrls.remove(path);
    final decodeSizes = _decodeSizes.remove(path) ?? const {};
    if (cachedUrl == null && !path.startsWith('https://')) return;
    try {
      final url = cachedUrl == null ? path : await cachedUrl;
      final imageCache = PaintingBinding.instance.imageCache;
      for (final size in decodeSizes) {
        await imageCache.evict(
          ResizeImage(
            NetworkImage(url),
            width: size.width,
            height: size.height,
          ),
        );
      }
      await imageCache.evict(NetworkImage(url));
    } catch (_) {
      // A failed download URL is removed from the URL cache above already.
    }
  }

  static void _rememberDecodeSize(
    String path,
    int? width,
    int? height,
  ) {
    if (width == null && height == null) return;
    if (_decodeSizes.length >= 400 && !_decodeSizes.containsKey(path)) {
      _decodeSizes.remove(_decodeSizes.keys.first);
    }
    _decodeSizes
        .putIfAbsent(path, () => <({int? width, int? height})>{})
        .add((width: width, height: height));
  }
}
