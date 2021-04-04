import 'package:cognos/signup.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {

    if (MediaQuery.of(context).orientation == Orientation.portrait){
      // is portrait
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(top:5, left:5, right:5),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'COGNOS AI',
                    style: GoogleFonts.aldrich(
                      textStyle: TextStyle(color: Colors.blue, letterSpacing: .5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child:  Container(
                    color: Colors.white,
                    child: new Image.asset('assets/images/Logo.jpg', height: 250, width: 250,),
                    alignment: Alignment.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 5, top:30),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Read our ',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 8,
                            ),
                          ),
                          Text(
                            'Pivacy Policy.',
                            style: TextStyle(
                              color: Colors.lightBlue,
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Tap Agree and Continue to accept the ',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 8,
                            ),
                          ),
                          Text(
                            'Terms of Service.',
                            style: TextStyle(
                              color: Colors.lightBlue,
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
                      FlatButton(
                        splashColor: Colors.lightBlue,
                        color: Colors.lightBlue,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'AGREE AND CONTINUE',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignUp()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    else{
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(top:5, left:5, right:5),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'COGNOS AI',
                        style: GoogleFonts.aldrich(
                          textStyle: TextStyle(color: Colors.blue, letterSpacing: .5, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child:  Container(
                        color: Colors.white,
                        child: new Image.asset('assets/images/Logo.jpg', height: 250, width: 250,),
                        alignment: Alignment.center,
                      ),
                    ),
                  ]
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 5, top:30),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Read our ',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 8,
                            ),
                          ),
                          Text(
                            'Pivacy Policy.',
                            style: TextStyle(
                              color: Colors.lightBlue,
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Tap Agree and Continue to accept the ',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 8,
                            ),
                          ),
                          Text(
                            'Terms of Service.',
                            style: TextStyle(
                              color: Colors.lightBlue,
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
                      FlatButton(
                        splashColor: Colors.lightBlue,
                        color: Colors.lightBlue,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'AGREE AND CONTINUE',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignUp()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }


  }
}
