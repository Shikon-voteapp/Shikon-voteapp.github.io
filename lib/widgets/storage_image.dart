import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

/// Shows group artwork from Firebase Storage.
class StorageImage extends StatelessWidget {
  static final Map<String, Future<String>> _downloadUrls =
      <String, Future<String>>{};
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
      future: url,
      builder: (context, snapshot) {
        if (snapshot.hasError || !snapshot.hasData) {
          if (snapshot.hasError && errorBuilder != null) {
            return errorBuilder!(context, snapshot.error!, StackTrace.current);
          }
          return SizedBox(width: width, height: height);
        }
        return Image.network(
          snapshot.data!,
          fit: fit,
          width: width,
          height: height,
          webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
          errorBuilder: errorBuilder,
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
      _downloadUrls.remove(_downloadUrls.keys.first);
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
}
