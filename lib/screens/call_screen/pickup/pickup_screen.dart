import 'package:cognos/models/calls_data.dart';
import 'package:cognos/resources/call_method.dart';
import 'package:cognos/screens/call_screen/call_screen.dart';
import 'package:cognos/utils/permissions.dart';
import 'package:cognos/screens/chatscreen/cache_image/cache_image.dart';
import 'package:flutter/material.dart';

class PickupScreen extends StatelessWidget {
  final Call call;
  final CallMethods callMethods = CallMethods();

  PickupScreen({
    @required this.call,
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
              "Incoming Call...",
              style: TextStyle(
                fontSize: 30,
              ),
            ),
            SizedBox(height: 5),
            call.callerPic==null ? Container(
              child: Icon(
                Icons.person,
                size: 100,
                color: Colors.black38,
              ),) : CachedImage(call.callerPic, isRound: true, radius: 120, width: 10, height: 10,),
            SizedBox(height: 10),
            Text(
              call.callerName,
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
                    await callMethods.endCall(call: call);
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
                      builder: (context) => CallScreen(call: call),
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