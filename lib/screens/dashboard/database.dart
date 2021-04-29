import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tflite/tflite.dart';
import 'dart:io';
import 'dart:ui' as ui;

class Database extends StatefulWidget {
  final List<dynamic> cropImage;
  Database({
    @required this.cropImage,

  });
  @override
  _DatabaseState createState() => _DatabaseState();
}

class _DatabaseState extends State<Database> {
  List faceExpr;
  List expr;
  String currentUserId, date, time;
  var now;
  File _img1, _img2;

  String directory;
  List f = [];
  List file = [];

  bool pre = false;
  static final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  bool feed = false;
  bool vision = false;
  var timer;
  bool _loading = false;
  bool speaker = true;

  List<Rect> rect = new List<Rect>();
  List _outputs;
  List faceExpression = [];

  bool shouldCapture = true;
  List classImage = [];

  @override
  void initState() {
    super.initState();
    Tflite.close();
    _loading = true;
    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    Tflite.close();
    super.dispose();
  }
  Future<String> loadModel() async {
    return Tflite.loadModel(
      model: "assets/emotion_ai.tflite",
      labels: "assets/emotion_ai.txt",
    );
  }


  Future<void> classifyImage(List cImage) async {
    for(var i=0;i<cImage.length;i++){
      classImage.add(cImage[i].toString().substring(7,cImage[i].toString().length-1));
      print(classImage[i]);
      //file.add(f[i].toString().replaceRange(0,7,'').toString());
    }
    for(var k = 0; k<classImage.length;k++){
      var output = await Tflite.runModelOnImage(
        path: classImage[k].toString(),
        numResults: 4,
        threshold: 0.005,
        imageMean: 127.5,
        imageStd: 127.5,
      );
      setState(() {
        _img1 = File(classImage[k]);
        _loading = false;
        _outputs = output;
      });
      print("inside classify image *********************************");
      print((_outputs[0]["label"]).runtimeType);
      print(_outputs[0]["label"]);
      faceExpression.add(_outputs[0]["label"].toString());
      print('************************ ${faceExpression} **************************');
      //Toast.show('${faceExpression}', context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
    }
    print('************************ ${faceExpression} **************************');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'RECOGNIZER',
            style: GoogleFonts.aldrich(
              textStyle: TextStyle(color: Colors.white, letterSpacing: .5,),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: Center(
          child: InkWell(
            child: Icon(
              Icons.developer_board,
              color: Colors.lightBlue,
            ),
            onTap: () {classifyImage(widget.cropImage);},
          ),
        )

        /*Padding(
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
                                      'Time: ',
                                      style: TextStyle(color: Colors.white, fontSize: 15,fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '10:30',
                                      style: TextStyle(color: Colors.white, fontSize: 15),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Attentive/Non Attentive: ',
                                      style: TextStyle(color: Colors.white, fontSize: 15,fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Non Attentive',
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
        ),*/
      )
    );
  }
}
