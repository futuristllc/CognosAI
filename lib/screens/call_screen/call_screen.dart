import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognos/configs/agora_configs.dart';
import 'package:cognos/image_provider/user_provider.dart';
import 'package:cognos/models/calls_data.dart';
import 'package:cognos/resources/call_method.dart';
import 'package:cognos/screens/dashboard/dashboard.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:native_screenshot/native_screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:tflite/tflite.dart';

class CallScreen extends StatefulWidget {
  final Call call;

  CallScreen({
    @required this.call,
  });

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  static final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  bool feed = false;
  bool vision = false;
  var timer;
  bool _loading = false;

  List<Rect> rect = new List<Rect>();
  List _outputs;
  List faceExpression = [];

  File _img1, _img2;
  final picker = ImagePicker();
  ui.Image image;

  bool shouldCapture = true;

  final CallMethods callMethods = CallMethods();
  ScreenshotController screenshotController = ScreenshotController();

  UserProvider userProvider;
  StreamSubscription callStreamSubscription;

  @override
  void initState() {
    super.initState();
    addPostFrameCallback();
    initializeAgora();
    _loading = true;
    checkScreenshot();
    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
    //timer = Timer.periodic(Duration(seconds: 10), (Timer t) => _takeScreenShot());
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/emotion_ai.tflite",
      labels: "assets/emotion_ai.txt",
    );
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 4,
      threshold: 0.005,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _img1 = image;
      _loading = false;
      _outputs = output;
    });
    print("inside classify image *********************************");
    print((_outputs[0]["label"]).runtimeType);
    print(_outputs[0]["label"]);
    faceExpression.add(_outputs[0]["label"].toString());
    print('${faceExpression}');
  }

  checkScreenshot(){
    print('in checkSS');
    setState(() {
      shouldCapture = !shouldCapture;
      print(shouldCapture);

      print('in take SS IF');
      Timer.periodic(Duration(seconds: 30), (timer) {
        if (!shouldCapture) {
          timer.cancel();
        }
        _takeScreenShot();
      });
        //timer = Timer.periodic(Duration(seconds: 30), (Timer t) => _takeScreenShot());
    });
  }

  Future<ui.Image> loadImage(File image) async {
    var img = await image.readAsBytes();
    return await decodeImageFromList(img);
  }


  Future getImage(String screenShotPath) async {
    _img2 = File(screenShotPath);
    setState(() {
      rect = List<Rect>();
    });

    var dirPath;
    createFolderInAppDocDir('CognosAI','FaceData').then((String path) async {
      setState(() {
        dirPath = path;
      });
      print('Path: $dirPath');

      var visionImage = FirebaseVisionImage.fromFile(_img2);
      var options = new FaceDetectorOptions(
        enableTracking: true,
        enableLandmarks: true,
        enableClassification: true,
        mode: FaceDetectorMode.accurate,
      );
      var faceDetector = FirebaseVision.instance.faceDetector(options);
      List<Face> faces = await faceDetector.processImage(visionImage);
      int i = 0;
      String meetingid = 'meeting';
      for (Face f in faces) {
        rect.add(f.boundingBox);
        print(rect);
        i++;
        print('Probabilities: ${f.leftEyeOpenProbability},${f.rightEyeOpenProbability},${f.headEulerAngleY},');
        print('${f.headEulerAngleZ},${f.smilingProbability},${f.trackingId}');
        File croppedFile = await FlutterNativeImage.cropImage(_img2.path, f.boundingBox.left.toInt(),
            f.boundingBox.top.toInt(), f.boundingBox.width.toInt(), f.boundingBox.height.toInt());
        DateTime now = new DateTime.now();
        DateTime date = new DateTime(now.year, now.month, now.day ,now.hour,now.minute , now.second);
        print(formatDate(date, [yyyy, '', mm, '', dd ,'',HH, '', nn, '_', ss]));
        var formatted_date = formatDate(date, [yyyy, '_', mm, '_', dd ,'_',HH, '_', nn, '_', ss]);
        croppedFile.copy('${dirPath}/FaceData/${meetingid}_${i}_${formatted_date.toString()}.jpg');
        print('Cropped File Path: ${croppedFile}');
        //classifyImage(croppedFile);
      }

      loadImage(_img2).then((img) {
        setState(() {
          this.image = img;
        });
      });
    });
  }

  Future<void> _takeScreenShot() async {
    print('in take SS');
    var _path;
    DateTime now = new DateTime.now();
    DateTime date = new DateTime(now.year, now.month, now.day ,now.hour,now.minute , now.second);
    //print(date);
    print(formatDate(date, [yyyy, '_', mm, '_', dd ,'_',HH, '_', nn, '_', ss]));
    var formattedDate = formatDate(date, [yyyy, '_', mm, '_', dd ,'_',HH, '_', nn, '_', ss]);
    String screenShotPath = await NativeScreenshot.takeScreenshot();
    print(screenShotPath);
    print('captured');
    getImage(screenShotPath);
    /*screenshotController
        .capture(delay: Duration(milliseconds: 10))
        .then((File image) async {
      print("Capture Done");
      createFolderInAppDocDir('CognosAI','Screenshots').then((String result){
        setState(() {
          _path = result;
          print('Path: $_path');
          image.copy('$_path/FaceData/${formattedDate}.jpg');
        });
      });
      final result =
      await ImageGallerySaver.saveImage(image.readAsBytesSync());
      print("File Saved to Gallery");
    }).catchError((onError) {
      print(onError);
    });*/
  }

  static Future<String> createFolderInAppDocDir(String folderName, String subFolderName) async {
    final _appDocDir = await getExternalStorageDirectory();
    //print('Dir: $_appDocDir');
    final Directory _appDocDirFolder =  Directory('${_appDocDir.path}/$folderName/');
    final Directory _subDocDirFolder =  Directory('${_appDocDirFolder.path}/$subFolderName/');

    if(await _appDocDirFolder.exists() && await _subDocDirFolder.exists()){ //if folder already exists return path
      return _appDocDirFolder.path.toString();
    }
    else{//if folder not exists create folder and then return its path
      final Directory _appDocDirNewFolder = await _appDocDirFolder.create(recursive: true);
      final Directory _subDocDirNewFolder = await _subDocDirFolder.create(recursive: true);
      return _appDocDirNewFolder.path.toString();
    }
  }

  Future<void> initializeAgora() async {
    if (APP_ID.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await AgoraRtcEngine.enableWebSdkInteroperability(true);
    await AgoraRtcEngine.setParameters(
        '''{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}''');
    await AgoraRtcEngine.joinChannel(null, widget.call.channelId, null, 0);

  }

  addPostFrameCallback() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      userProvider = Provider.of<UserProvider>(context, listen: false);

      callStreamSubscription = callMethods
          .callStream(uid: userProvider.getUser.uid)
          .listen((DocumentSnapshot ds) {
        // defining the logic
        switch (ds.data) {
          case null:
          // snapshot is null which means that call is hanged and documents are deleted
            Navigator.pop(context);
            break;
          default:
            break;
        }
      });
    });
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    await AgoraRtcEngine.create(APP_ID);
    await AgoraRtcEngine.enableVideo();
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    AgoraRtcEngine.onError = (dynamic code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onJoinChannelSuccess = (
        String channel,
        int uid,
        int elapsed,
        ) {
      setState(() {
        final info = 'onJoinChannel: $channel, uid: $uid';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      setState(() {
        final info = 'onUserJoined: $uid';
        _infoStrings.add(info);
        _users.add(uid);
      });
    };

    AgoraRtcEngine.onUpdatedUserInfo = (AgoraUserInfo userInfo, int i) {
      setState(() {
        final info = 'onUpdatedUserInfo: ${userInfo.toString()}';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onRejoinChannelSuccess = (String string, int a, int b) {
      setState(() {
        final info = 'onRejoinChannelSuccess: $string';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onUserOffline = (int a, int b) {
      callMethods.endCall(call: widget.call);
      setState(() {
        final info = 'onUserOffline: a: ${a.toString()}, b: ${b.toString()}';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onRegisteredLocalUser = (String s, int i) {
      setState(() {
        final info = 'onRegisteredLocalUser: string: s, i: ${i.toString()}';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onLeaveChannel = () {
      setState(() {
        _infoStrings.add('onLeaveChannel');
        _users.clear();
      });
    };

    AgoraRtcEngine.onConnectionLost = () {
      setState(() {
        final info = 'onConnectionLost';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      // if call was picked

      setState(() {
        final info = 'userOffline: $uid';
        _infoStrings.add(info);
        _users.remove(uid);
      });
    };

    AgoraRtcEngine.onFirstRemoteVideoFrame = (
        int uid,
        int width,
        int height,
        int elapsed,
        ) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
      });
    };
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<AgoraRenderWidget> list = [
      AgoraRenderWidget(0, local: true, preview: true),
    ];
    _users.forEach((int uid) => list.add(AgoraRenderWidget(uid)));
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
              children: <Widget>[_videoView(views[0])],
            ));
      case 2:
        return Container(
            child: Column(
              children: <Widget>[
                _expandedVideoRow([views[1]]),
                _expandedVideoRow([views[0]])
              ],
            ));
      case 3:
        return Container(
            child: Column(
              children: <Widget>[
                _expandedVideoRow(views.sublist(0, 2)),
                _expandedVideoRow(views.sublist(2, 3))
              ],
            ));
      case 4:
        return Container(
            child: Column(
              children: <Widget>[
                _expandedVideoRow(views.sublist(0, 2)),
                _expandedVideoRow(views.sublist(2, 4))
              ],
            ));
      default:
    }
    return Container();
  }

  /// Info panel to show logs
  Widget _panel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: _infoStrings.length,
            itemBuilder: (BuildContext context, int index) {
              if (_infoStrings.isEmpty) {
                return null;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _infoStrings[index],
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    AgoraRtcEngine.muteLocalAudioStream(muted);
  }

  void _onToggleCamera() {
    setState(() {
      feed = !feed;
    });
    AgoraRtcEngine.muteLocalVideoStream(feed);
  }

  void _onToggleVision() {
    setState(() {
      vision = !vision;
    });

  }

  void _onSwitchCamera() {
    AgoraRtcEngine.switchCamera();
  }

  /// Toolbar layout
  Widget _toolbar(){
    return OrientationBuilder(
      builder: (context,orientation){
        return orientation == Orientation.portrait ? Padding(
          padding: EdgeInsets.only(bottom: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  RawMaterialButton(
                    onPressed: (){
                      callMethods.endCall(
                        call: widget.call,
                      );
                      /*Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DashBoard(faceExpr: faceExpression),
                      ),
                    );*/
                    },
                    child: Icon(
                      Icons.call_end,
                      color: Colors.white,
                      size: 25.0,
                    ),
                    shape: CircleBorder(),
                    elevation: 2.0,
                    fillColor: Colors.redAccent,
                    padding: const EdgeInsets.all(15.0),
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.all(10),),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RawMaterialButton(
                    onPressed: _onToggleCamera,
                    child: Icon(
                      feed?Icons.videocam : Icons.videocam_off,
                      color: feed?Colors.white : Colors.blueAccent,
                      size: 20.0,
                    ),
                    shape: CircleBorder(),
                    elevation: 2.0,
                    fillColor: feed?Colors.blueAccent:Colors.white,
                    padding: const EdgeInsets.all(12.0),
                  ),

                  RawMaterialButton(
                    onPressed: _onToggleMute,
                    child: Icon(
                      muted ? Icons.mic : Icons.mic_off,
                      color: muted ? Colors.white : Colors.blueAccent,
                      size: 20.0,
                    ),
                    shape: CircleBorder(),
                    elevation: 2.0,
                    fillColor: muted ? Colors.blueAccent : Colors.white,
                    padding: const EdgeInsets.all(12.0),
                  ),

                  RawMaterialButton(
                    onPressed: _onSwitchCamera,
                    child: Icon(
                      Icons.switch_camera,
                      color: Colors.blueAccent,
                      size: 20.0,
                    ),
                    shape: CircleBorder(),
                    elevation: 2.0,
                    fillColor: Colors.white,
                    padding: const EdgeInsets.all(12.0),
                  ),

                  RawMaterialButton(
                    onPressed: checkScreenshot,
                    child: Icon(
                      shouldCapture?Icons.widgets : Icons.widgets_outlined,
                      color: shouldCapture?Colors.white:Colors.blueAccent ,
                      size: 20.0,
                    ),
                    shape: CircleBorder(),
                    elevation: 2.0,
                    fillColor: shouldCapture?Colors.blueAccent:Colors.white,
                    padding: const EdgeInsets.all(12.0),
                  ),
                ],
              ),
            ],
          ),
        ) :
        Padding(
          padding: EdgeInsets.only(bottom: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RawMaterialButton(
                    onPressed: _onToggleCamera,
                    child: Icon(
                      feed?Icons.videocam : Icons.videocam_off,
                      color: feed?Colors.white : Colors.blueAccent,
                      size: 20.0,
                    ),
                    shape: CircleBorder(),
                    elevation: 2.0,
                    fillColor: feed?Colors.blueAccent:Colors.white,
                    padding: const EdgeInsets.all(12.0),
                  ),

                  RawMaterialButton(
                    onPressed: _onToggleMute,
                    child: Icon(
                      muted ? Icons.mic : Icons.mic_off,
                      color: muted ? Colors.white : Colors.blueAccent,
                      size: 20.0,
                    ),
                    shape: CircleBorder(),
                    elevation: 2.0,
                    fillColor: muted ? Colors.blueAccent : Colors.white,
                    padding: const EdgeInsets.all(12.0),
                  ),

                  RawMaterialButton(
                    onPressed: (){
                      callMethods.endCall(
                        call: widget.call,
                      );
                      /*Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DashBoard(faceExpr: faceExpression),
                      ),
                    );*/
                    },
                    child: Icon(
                      Icons.call_end,
                      color: Colors.white,
                      size: 25.0,
                    ),
                    shape: CircleBorder(),
                    elevation: 2.0,
                    fillColor: Colors.redAccent,
                    padding: const EdgeInsets.all(15.0),
                  ),

                  RawMaterialButton(
                    onPressed: _onSwitchCamera,
                    child: Icon(
                      Icons.switch_camera,
                      color: Colors.blueAccent,
                      size: 20.0,
                    ),
                    shape: CircleBorder(),
                    elevation: 2.0,
                    fillColor: Colors.white,
                    padding: const EdgeInsets.all(12.0),
                  ),

                  RawMaterialButton(
                    onPressed: checkScreenshot,
                    child: Icon(
                      shouldCapture?Icons.widgets : Icons.widgets_outlined,
                      color: shouldCapture?Colors.white:Colors.blueAccent ,
                      size: 20.0,
                    ),
                    shape: CircleBorder(),
                    elevation: 2.0,
                    fillColor: shouldCapture?Colors.blueAccent:Colors.white,
                    padding: const EdgeInsets.all(12.0),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk
    AgoraRtcEngine.leaveChannel();
    AgoraRtcEngine.destroy();
    callStreamSubscription.cancel();
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: <Widget>[
            _viewRows(),
            // _panel(),
            _toolbar(),
          ],
        ),
      ),
    );
  }
}