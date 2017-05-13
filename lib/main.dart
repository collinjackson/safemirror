import 'dart:async';
import 'dart:io';
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

class _SafeMirrorHomeState extends State<SafeMirrorHome> {
  StreamController<FileImage> _streamController = new StreamController();
  double _imageScale = 1.0;

  void initState() {
    super.initState();
    Mirror.openCamera().then((_) => _capturePicture());
  }

  _capturePicture() async {
    File file = await Mirror.captureStillPicture();
    setState(() {
      _imageScale += 0.00000000001;
    });

    _streamController.add(new FileImage(file, scale: _imageScale));
    _capturePicture();
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
          builder: (BuildContext context, AsyncSnapshot<FileImage> snapshot) {
            if (snapshot.hasData)
              return new Image(image: snapshot.data, gaplessPlayback: true);
            return new CircularProgressIndicator();
          }
        )
      ),
    );
  }
}
