import 'package:cognos/models/calls_data.dart';
import 'package:cognos/resources/call_method.dart';
import 'package:cognos/screens/call_screen/call_screen.dart';
import 'package:cognos/utils/permissions.dart';
import 'package:cognos/screens/chatscreen/cache_image/cache_image.dart';
import 'package:flutter/material.dart';
import 'package:cognos/models/voice_call.dart';
import 'package:cognos/resources/voice_call.dart';
import 'package:cognos/screens/call_screen/voice_call_screen.dart';

class VoicePickupScreen extends StatelessWidget {
  final Voice vcall;
  final VoiceCallMethods vcallMethods = VoiceCallMethods();

  VoicePickupScreen({
    @required this.vcall,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Incoming Voice Call...",
              style: TextStyle(
                fontSize: 30,
              ),
            ),
            SizedBox(height: 5),
            vcall.callerPic==null ? Container(
              child: Icon(
                Icons.person,
                size: 100,
                color: Colors.black38,
              ),) : CachedImage(vcall.callerPic, isRound: true, radius: 120, width: 10, height: 10,),
            SizedBox(height: 10),
            Text(
              vcall.callerName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 75),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.call_end),
                  color: Colors.redAccent,
                  onPressed: () async {
                    await vcallMethods.vendCall(voice: vcall);
                  },
                ),
                SizedBox(width: 25),
                IconButton(
                  icon: Icon(Icons.call),
                  color: Colors.green,
                  onPressed: () async =>
                  await Permissions.cameraAndMicrophonePermissionsGranted()
                      ? Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VoiceCall(voice: vcall),
                    ),
                  )
                      : {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}