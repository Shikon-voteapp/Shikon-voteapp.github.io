import 'package:flutter/foundation.dart';

class AccessibilityService {
  static final ValueNotifier<bool> isZoomed = ValueNotifier<bool>(false);

  static void toggleZoom() {
    isZoomed.value = !isZoomed.value;
  }

  static void setZoom(bool value) {
    if (isZoomed.value != value) {
      isZoomed.value = value;
    }
  }
}
