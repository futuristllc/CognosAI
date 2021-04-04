import 'package:cognos/image_provider/image_upload_provider.dart';
import 'package:cognos/image_provider/user_provider.dart';
import 'package:cognos/providers/countries.dart';
import 'package:cognos/providers/phone_auth.dart';
import 'package:cognos/resources/firebase_repository.dart';
import 'package:cognos/screens/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:cognos/splash.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseRepository _repository = FirebaseRepository();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => CountryProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => PhoneAuthDataProvider(),
          ),
          ChangeNotifierProvider(create: (_) => ImageUploadProvider()),
          ChangeNotifierProvider(create: (_) => UserProvider()),
        ],
        child:
          ChangeNotifierProvider<ImageUploadProvider>(
            create: (context) => ImageUploadProvider(),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              home: FutureBuilder(
                future: _repository.getCurrentUser(),
                builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
                  if (snapshot.hasData) {
                    //return Home();
                    return Home();
                  } else {
                    return Splash();
                  }
                },
              ),
            ),
          ),
    );
  }
}

