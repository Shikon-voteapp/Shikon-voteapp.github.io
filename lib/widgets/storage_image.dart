import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

/// Shows group artwork from Firebase Storage. Asset paths remain supported for
/// app-owned illustrations such as unselected placeholders.
class StorageImage extends StatelessWidget {
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
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: errorBuilder,
      );
    }
    final url =
        path.startsWith('https://')
            ? Future<String>.value(path)
            : FirebaseStorage.instance.ref(path).getDownloadURL();
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
          errorBuilder: errorBuilder,
        );
      },
    );
  }
}
