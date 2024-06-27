import 'package:flutter/foundation.dart';
import 'package:web/web.dart';

void pushHome() {
  if (kIsWeb) {
    window.history.pushState(null, 'Magic Life Wheel', '/');
  }
}
