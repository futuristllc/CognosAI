import 'package:cognos/resources/firebase_repository.dart';
import 'package:cognos/utils/utilities.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserSetup extends StatefulWidget {
  @override
  _UserSetupState createState() => _UserSetupState();
}

FirebaseUser user;

class _UserSetupState extends State<UserSetup> {

  FirebaseRepository _repository = FirebaseRepository();

  String currentUserId, photourl;
  String initials, userName;
  String time, date, uname, prourl;
  var now;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _repository.getCurrentUser().then((user) {
      setState(() {
        now = new DateTime.now();
        date = new DateFormat("dd-MM-yyyy").format(now);
        time = new DateFormat("H:m:s").format(now);
        currentUserId = user.uid;
        uname = user.displayName;
        prourl = user.photoUrl;
        initials = Utils.getInitials(user.displayName);
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 90,
                backgroundColor: Colors.grey,
                backgroundImage: (prourl==null)?null:NetworkImage(prourl),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
