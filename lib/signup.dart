import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognos/firebase/auth/phone_auth/get_phone.dart';
import 'package:cognos/resources/firebase_repository.dart';
import 'package:cognos/screens/home.dart';
import 'package:cognos/screens/userDetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  FirebaseRepository _repository = FirebaseRepository();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var uidRef = Firestore.instance.collection("uidList").document("UIDCHS1FCUOTGUNROIST");

    print(uidRef.get());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child:Padding(
          padding: EdgeInsets.all(0),
          child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    child: Image.asset('assets/images/cognos.png', height: 150, width: 150,),
                  ),
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Container(
                        child: Image.asset('assets/images/w1.jpg'),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          RaisedButton(
                            splashColor: Colors.white,
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => PhoneAuthGetPhone()),);
                            },
                            color: Colors.lightBlue,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: 5),
                                  child: Icon(Icons.phone, color: Colors.white,),
                                ),
                                Text('Sign In with Phone', style: TextStyle(color: Colors.white,fontSize: 18),)
                              ],
                            ),
                            textColor: Colors.lightBlue,
                            shape: RoundedRectangleBorder(side: BorderSide(
                                color: Colors.lightBlue,
                                width: 2,
                                style: BorderStyle.solid
                            ), borderRadius: BorderRadius.circular(50)),
                          ),
                          RaisedButton(
                            onPressed: () {
                              googleLogin();
                            },
                            color: Colors.white,
                            splashColor: Colors.lightBlue,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: 5),
                                  child: Image.asset('assets/images/google.png',height: 20,width: 20,),
                                ),
                                Text('Sign In with Google', style: TextStyle(color: Colors.black87,fontSize: 18),)
                              ],
                            ),
                            textColor: Colors.lightBlue,
                            shape: RoundedRectangleBorder(side: BorderSide(
                                color: Colors.white,
                                width: 2,
                                style: BorderStyle.solid
                            ), borderRadius: BorderRadius.circular(50)),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
          ),
        ),
      ),
    );
  }

  void googleLogin() {
    _repository.signIn().then((FirebaseUser user){
      if (user!=null) {
        authenticateUser(user);
      }
      else {
        print('error');
      }
    });
  }

  void authenticateUser(FirebaseUser user){
    _repository.authenticateUser(user).then((isNewUser){
      if(isNewUser) {
        _repository.addDataToDb(user).then((value) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
                return UserDetails();
              }));
        });
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
              return Home();
            }));
      }
    });
  }
}
