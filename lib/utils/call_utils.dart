import 'dart:math';
import 'package:cognos/models/calls_data.dart';
import 'package:cognos/models/userlist.dart';
import 'package:cognos/resources/call_method.dart';
import 'package:cognos/screens/call_screen/call_screen.dart';
import 'package:flutter/material.dart';

class CallUtils {
  static final CallMethods callMethods = CallMethods();

  static dial({UserList from, UserList to, context}) async {
    Call call = Call(
      callerId: from.uid,
      callerName: from.name,
      callerPic: from.profileurl,
      receiverId: to.uid,
      receiverName: to.name,
      receiverPic: to.profileurl,
      channelId: Random().nextInt(1000).toString(),
    );

    bool callMade = await callMethods.makeCall(call: call);

    call.hasDialled = true;

    if (callMade) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CallScreen(call: call),
          ));
    }
  }
}