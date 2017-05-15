import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'dart:io';
import 'package:http/http.dart' as http;

class FaceApp {
  static const String DEFAULT_API_HOST = 'https://node-01.faceapp.io';
  static const String DEFAULT_USER_AGENT = 'FaceApp/1.0.229 (Linux; Android 4.4)';
  static const int DEVICE_ID_LENGTH = 8;
  final String deviceId = new String.fromCharCodes(
    new List.generate(
        DEVICE_ID_LENGTH,
          (_) => 'a'.codeUnitAt(0) + new Random().nextInt(26),
    )
  );

  http.MultipartRequest _createRequest(String method, String path) {
    Uri uri = Uri.parse('$DEFAULT_API_HOST$path');
    var request = new http.MultipartRequest(method, uri);
    request.headers['User-Agent'] = DEFAULT_USER_AGENT;
    request.headers['X-FaceApp-DeviceID'] = deviceId;
    return request;
  }

  Future<String> upload(File file) async {
    var request = _createRequest('POST', '/api/v2.3/photos');
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    http.StreamedResponse response = await request.send();
    Map resultMap = JSON.decode(await response.stream.bytesToString());
    print("uploaded ${await file.length()} bytes and got result: $resultMap");
    return resultMap['code'];
  }

  Future<Uint8List> applyFilter({ String code, String filter, bool cropped: true }) async {
    var request = _createRequest(
      'GET',
      '/api/v2.3/photos/$code/filters/$filter?cropped=${cropped ? 1 : 0}'
    );
    var response = await request.send();
    print('applyFilter result: ${response.statusCode} ${response.reasonPhrase} (${response.contentLength} bytes)');
    return response.stream.toBytes();
  }
}