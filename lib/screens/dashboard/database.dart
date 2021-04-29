import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Database extends StatefulWidget {
  @override
  _DatabaseState createState() => _DatabaseState();
}

class _DatabaseState extends State<Database> {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'DATABASE',
            style: GoogleFonts.aldrich(
              textStyle: TextStyle(color: Colors.white, letterSpacing: .5,),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.only(left: 5, right: 5, bottom: 6),
          child: ListView.builder(
              itemCount: 2,
              itemBuilder: (context, i) => new GestureDetector(
                child: InkWell(
                  child: Column(
                    children: <Widget>[
                      Card(
                          color: Colors.lightBlue,
                          elevation: 3,
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Result',
                                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Time:',
                                      style: TextStyle(color: Colors.white, fontSize: 15,fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '10:30',
                                      style: TextStyle(color: Colors.white, fontSize: 15),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Prediction:',
                                      style: TextStyle(color: Colors.white, fontSize: 15,fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '70% Laughing, 30% Neutral',
                                      style: TextStyle(color: Colors.white, fontSize: 15),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                      )
                    ],
                  ),
                  onTap: (){

                  },
                  splashColor: Colors.black12,
                ),
              )),
        ),
      )
    );
  }
}
