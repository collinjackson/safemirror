import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class Mirror {
  static const MethodChannel _channel =
      const MethodChannel('plugins.flutter.io/mirror');

  static Future<File> captureStillPicture({ int quality }) async {
    String filename = await _channel.invokeMethod(
      'captureStillPicture', {
        'quality': quality,
      },
    );
    return filename != null ? new File(filename) : null;
  }

  static Future<String> openCamera({ bool wantFrontFacing: true}) =>
    _channel.invokeMethod('openCamera', {'wantFrontFacing': wantFrontFacing});

  static Future<String> closeCamera() =>
    _channel.invokeMethod('closeCamera');
}
