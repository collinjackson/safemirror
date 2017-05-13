import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class Mirror {
  static const MethodChannel _channel =
      const MethodChannel('plugins.flutter.io/mirror');

  static Future<File> captureStillPicture() async {
    String filename = await _channel.invokeMethod('captureStillPicture');
    return new File(filename);
  }

  static Future<String> openCamera() =>
    _channel.invokeMethod('openCamera');

  static Future<String> closeCamera() =>
    _channel.invokeMethod('closeCamera');
}
