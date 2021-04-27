import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognos/configs/agora_configs.dart';
import 'package:cognos/image_provider/user_provider.dart';
import 'package:cognos/models/calls_data.dart';
import 'package:cognos/models/voice_call.dart';
import 'package:cognos/resources/call_method.dart';
import 'package:cognos/screens/chatscreen/cache_image/cache_image.dart';
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
import 'package:toast/toast.dart';
import 'package:cognos/resources/firebase_repository.dart';

class VoiceCall extends StatefulWidget {

  final Call call;
  final CallMethods callMethods = CallMethods();

  VoiceCall({
    @required this.call,
  });

  @override
  _VoiceCallState createState() => _VoiceCallState();
}

class _VoiceCallState extends State<VoiceCall> {
  static final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  bool speaker = true;

  final CallMethods callMethods = CallMethods();
  String _currentUserId;

  bool shouldCapture = true;

  UserProvider userProvider;
  StreamSubscription callStreamSubscription;
  FirebaseRepository _repository = FirebaseRepository();

  @override
  void initState() {
    super.initState();
    addPostFrameCallback();
    initializeAgora();
    _repository.getCurrentUser().then((user) {
      _currentUserId = user.uid;});
    //timer = Timer.periodic(Duration(seconds: 10), (Timer t) => _takeScreenShot());
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
    await AgoraRtcEngine.disableVideo();
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

    /*AgoraRtcEngine.onFirstRemoteVideoFrame = (
        int uid,
        int width,
        int height,
        int elapsed,
        ) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
      });
    };*/
  }

  /// Helper function to get list of native views
  /*List<Widget> _getRenderViews() {
    final List<AgoraRenderWidget> list = [
      AgoraRenderWidget(0, local: false, preview: false),
    ];
    _users.forEach((int uid) => list.add(AgoraRenderWidget(uid)));
    return list;
  }*/

  /// Video view wrapper
  /*Widget _videoView(view) {
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
  }*/

  Widget _viewRows(){
    //final views = _getRenderViews();

    var pic, name;
    if(_currentUserId == widget.call.callerId){
      name = widget.call.receiverName;
      pic = widget.call.receiverPic;
    }
    else {
      name = widget.call.callerName;
      pic = widget.call.callerPic;
    }
    return Container(
      decoration: new BoxDecoration(
        color: Colors.lightBlue,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            pic == null ? Container(
              child: Icon(
                Icons.person,
                size: 100,
                color: Colors.black38,
              ),) : CachedImage(pic, isRound: true, radius: 150, width: 10, height: 10,),
            SizedBox(height: 10),
            Container(
              child: Text(
                name,
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Video layout wrapper
  /*Widget _viewRows() {
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
  }*/

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    AgoraRtcEngine.muteLocalAudioStream(muted);
  }

  void _onToggleSpeaker(){
    setState(() {
      speaker =! speaker;
    });
    AgoraRtcEngine.setEnableSpeakerphone(speaker);
  }

  /*void _onToggleCamera() {
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
  }*/

  /// Toolbar layout
  Widget _toolbar(){
    return Padding(
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
                onPressed: _onToggleSpeaker,
                child: Icon(
                  speaker ? Icons.volume_up : Icons.volume_off,
                  color: speaker ? Colors.blueAccent : Colors.white,
                  size: 20.0,
                ),
                shape: CircleBorder(),
                elevation: 2.0,
                fillColor: speaker ? Colors.white : Colors.blueAccent,
                padding: const EdgeInsets.all(12.0),
              ),
              RawMaterialButton(
                onPressed: (){
                  callMethods.endCall(
                    call: widget.call,
                  );
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

            ],
          ),
          Padding(padding: EdgeInsets.all(10),),
        ],
      ),
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