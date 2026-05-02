import 'package:flutter/foundation.dart';
import 'dart:html' as html;

class BrowserUtils {
  /// Returns true if running on Microsoft Edge
  static bool get isEdge {
    if (!kIsWeb) return false;
    final ua = html.window.navigator.userAgent.toLowerCase();
    return ua.contains('edg/') || ua.contains('edge/');
  }

  /// Returns true if running on Chrome
  static bool get isChrome {
    if (!kIsWeb) return false;
    final ua = html.window.navigator.userAgent.toLowerCase();
    return ua.contains('chrome') && !ua.contains('edg');
  }

  /// Returns true if Web Speech API is supported
  static bool get speechSupported {
    if (!kIsWeb) return true; // mobile always supported
    return isChrome; // only reliable on Chrome
  }
}