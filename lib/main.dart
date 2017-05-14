import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:io';
import 'faceapp.dart';
import 'package:mirror/mirror.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'SafeMirror',
      home: new SafeMirrorHome(),
    );
  }
}

class SafeMirrorHome extends StatefulWidget {
  @override
  _SafeMirrorHomeState createState() => new _SafeMirrorHomeState();
}

final faceApp = new FaceApp();

class _SafeMirrorHomeState extends State<SafeMirrorHome> {
  StreamController<ImageProvider> _streamController = new StreamController();

  void initState() {
    super.initState();
    Mirror.openCamera(); // .then((_) => _capturePicture());
  }

  _capturePicture() async {
    File file = await Mirror.captureStillPicture();
    // kick off the next request while this is uploading
    new Future.delayed(const Duration(milliseconds: 200), _capturePicture);
    String code = await faceApp.upload(file);
    ImageProvider provider = new MemoryImage(
      await faceApp.applyFilter(code: code, filter: 'smile', cropped: false),
    );
    _streamController.add(provider);
  }

  @override dispose() {
    Mirror.closeCamera();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('SafeMirror'),
      ),
      body: new Center(
        child: new StreamBuilder(
          stream: _streamController.stream,
          builder: (BuildContext context, AsyncSnapshot<ImageProvider> snapshot) {
            if (snapshot.hasData)
              return new Image(image: snapshot.data, gaplessPlayback: true);
            return new CircularProgressIndicator();
          }
        )
      ),
      floatingActionButton: new FloatingActionButton(
        child: new Icon(Icons.photo_camera),
        onPressed: () {
          _capturePicture();
        }
      ),
    );
  }
}
