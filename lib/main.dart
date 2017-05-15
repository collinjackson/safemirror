import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'faceapp.dart';
import 'package:mirror/mirror.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'google_cloud_vision.dart';

final googleSignIn = new GoogleSignIn(
  scopes: ['https://www.googleapis.com/auth/cloud-platform'],
);

final faceApp = new FaceApp();

final googleCloudVision = new GoogleCloudVision(googleSignIn: googleSignIn);

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: new ThemeData.dark(),
      title: 'SafeMirror',
      home: new SafeMirrorHome(),
    );
  }
}

class SafeMirrorHome extends StatefulWidget {
  @override
  _SafeMirrorHomeState createState() => new _SafeMirrorHomeState();
}

class Filter {
  final bool cropped;
}

final List<Filter> filters = [
];

class _SafeMirrorHomeState extends State<SafeMirrorHome> {
  StreamController<ImageProvider> _streamController = new StreamController();
  bool _playing = false;
  String _filter = 'smile';
  bool _selfie = false;
  bool _cropped = false;

  void initState() {
//    googleSignIn.signInSilently();
    super.initState();
  }

  _capturePicture() async {
    if (!_playing)
      return;
    File file = await Mirror.captureStillPicture(quality: 25);
    // kick off the next request while this is processing
    if (file == null) {
      print("Failed to capture picture; stopping");
      _stop();
      return;
    }
     new Future.delayed(const Duration(milliseconds: 100), _capturePicture);
//
//    // process the image
//    ImageClassification classification = await googleCloudVision.classify(file);
//    if (classification.nsfw) {
//      _streamController.add()
//      return;
//    }
    String code = await faceApp.upload(file);
    if (code != null) {
      Uint8List result = await faceApp.applyFilter(code: code, filter: _filter, cropped: _cropped);
      if (result != null) {
        _streamController.add(new MemoryImage(result));
        return;
      }
    }

    // Fallback if we can't FaceApp the photo
    _streamController.add(new FileImage(
      file,
      scale: 1.0 + new Random().nextDouble() / 100000000.0),  // bust cache
    );
  }

  _start() async {
//    if (googleSignIn.currentUser == null) {
//      googleSignIn.signIn();
//    }
    await Mirror.openCamera(wantFrontFacing: _selfie);
    setState(() {
      _playing = true;
    });
    _capturePicture();
  }

  _stop() async {
    // Mirror.closeCamera();
    setState(() {
      _playing = false;
    });
  }

  @override dispose() {
    _stop();
    super.dispose();
  }

  _handleSelfieChanged(bool value) async {
    _stop();
    await Mirror.closeCamera();
    setState(() {
      _selfie = value;
      _cropped = value == 'smile' || value == 'smile_2';
    });
    await Mirror.openCamera(wantFrontFacing: _selfie);
  }

  void _handleFilterChanged(String value) {
    _stop();
    setState(() {
      _filter = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: _playing ? null : new AppBar(
        title: new Text(''),
      ),
      drawer: new Drawer(
        child: new ListView(
          children: [
            new DrawerHeader(
              child: new Text('Options'),
            ),
            new ListTile(
              onTap: () => _handleSelfieChanged(true),
              title: new Text('📱'),
              leading: new Radio<bool>(
                value: true,
                groupValue: _selfie,
                onChanged: _handleSelfieChanged,
              ),
            ),
            new ListTile(
                onTap: () => _handleSelfieChanged(false),
              title: new Text('🌎'),
              leading: new Radio<bool>(
                value: false,
                groupValue: _selfie,
                onChanged: _handleSelfieChanged,
              ),
            ),
            new Divider(),
            new ListTile(
                onTap: () => _handleFilterChanged('hot'),
                title: new Text('✨'),
                leading: new Radio<String>(
                    value: 'hot',
                    groupValue: _filter,
                    onChanged: _handleFilterChanged,
                ),
            ),
            new ListTile(
                onTap: () => _handleFilterChanged('old'),
                title: new Text('👴'),
                leading: new Radio<String>(
                    value: 'old',
                    groupValue: _filter,
                    onChanged: _handleFilterChanged,
                ),
            ),
            new ListTile(
                onTap: () => _handleFilterChanged('smile'),
                title: new Text('😁'),
                leading: new Radio<String>(
                    value: 'smile',
                    groupValue: _filter,
                    onChanged: _handleFilterChanged,
                ),
            ),
            new ListTile(
                onTap: () => _handleFilterChanged('male'),
                title: new Text('👨'),
                leading: new Radio<String>(
                    value: 'male',
                    groupValue: _filter,
                    onChanged: _handleFilterChanged,
                ),
            ),
            new ListTile(
              onTap: () => _handleFilterChanged('female'),
              title: new Text('👩'),
              leading: new Radio<String>(
                value: 'female',
                groupValue: _filter,
                onChanged: _handleFilterChanged,
              ),
            ),
          ],
        ),
      ),
      body: new StreamBuilder(
        stream: _streamController.stream,
        builder: (BuildContext context, AsyncSnapshot<ImageProvider> snapshot) {
          if (snapshot.hasData)
            return new ConstrainedBox(
              constraints: new BoxConstraints.expand(),
              child: new Image(image: snapshot.data, gaplessPlayback: true),
            );
          return new Center(child: new Text("Ready to begin?"));
        }
      ),
      floatingActionButton: new FloatingActionButton(
        child: new Icon(_playing ? Icons.stop : Icons.play_arrow),
        onPressed: _playing ? _stop : _start,
      ),
    );
  }
}
