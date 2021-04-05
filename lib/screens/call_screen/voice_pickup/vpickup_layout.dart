import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognos/image_provider/user_provider.dart';
import 'package:cognos/models/calls_data.dart';
import 'package:cognos/resources/call_method.dart';
import 'package:cognos/screens/call_screen/pickup/pickup_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cognos/resources/voice_call.dart';
import 'package:cognos/models/voice_call.dart';
import 'package:cognos/screens/call_screen/voice_pickup/vpickup_screen.dart';

class VoicePickupLayout extends StatelessWidget {
  final Widget scaffold;
  final VoiceCallMethods vcallMethods = VoiceCallMethods();

  VoicePickupLayout({
    @required this.scaffold,
  });

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return (userProvider != null && userProvider.getUser != null)
        ? StreamBuilder<DocumentSnapshot>(
      stream: vcallMethods.vcallStream(uid: userProvider.getUser.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data.data != null) {
          Voice vcall = Voice.fromMap(snapshot.data.data);

          if (!vcall.hasDialled) {
            return VoicePickupScreen(vcall: vcall);
          }
        }
        return scaffold;
      },
    )
        : Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}