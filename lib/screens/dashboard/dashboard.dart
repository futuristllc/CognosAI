import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cognos/screens/dashboard/database.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognos/resources/firebase_repository.dart';
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:date_format/date_format.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:tflite/tflite.dart';

class DashBoard extends StatefulWidget {
  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  List faceExpr;
  List expr;
  FirebaseRepository _repository = FirebaseRepository();
  String currentUserId, date, time;
  var now;

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
  bool fd = false;
  bool exp = false;

  String timestamp;
  File _img1, _img2;
  ui.Image image;
  bool shouldCapture = true;
  List cropImage = [];
  File croppedFile;
  List classImage = [];
  List lefteye = [];
  List righteye = [];

  bool pref = false;
  List attentive = [];
  int tcount = 0, fcount = 0;
  double attentionProb = 0.0, nonAttentionProb = 0.0;

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
    _repository.getCurrentUser().then((user) {
      setState(() {
        now = new DateTime.now();
        date = new DateFormat("dd-MM-yyyy").format(now);
        time = new DateFormat("H:m:s").format(now);
        currentUserId = user.uid;
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
    for (var i = 0; i < cImage.length; i++) {
      classImage.add(
          cImage[i].toString().substring(7, cImage[i].toString().length - 1));
      print(classImage[i]);
      //file.add(f[i].toString().replaceRange(0,7,'').toString());
    }
    for (var k = 0; k < classImage.length; k++) {
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
      print(
          '************************ ${faceExpression} **************************');
      //Toast.show('${faceExpression}', context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
    }
    print(
        '************************ ${faceExpression} **************************');
    timestamp = DateFormat("H:m").format(DateTime.now()).toString();
    probability();
  }

  void probability() {
    for (var i = 0; i < faceExpression.length; i++) {
      if (lefteye[i] < 0.5 && righteye[i] < 0.5) {
        //
        attentive.add("false");
      } else {
        if (faceExpression == "happy") {
          attentive.add("true");
        } else if (faceExpression == "disgust" ||
            faceExpression == "fear" ||
            faceExpression == "anger" ||
            faceExpression == "surprise") {
          attentive.add("true");
        } else {
          if (lefteye[i] >= 0.7 &&
              righteye[i] >= 0.7 &&
              faceExpression[i] == "neutral") {
            attentive.add("true");
          } else {
            attentive.add("false");
          }
        }
      }

      /*if (lefteye[i] < 0.7 && righteye[i] < 0.7 &&
          (faceExpression[i] != "neutral" || faceExpression[i] != "happy")) {
        if (faceExpression[i] == "sad") {
          attentive.add("false");
        }
        /*else {
          if(faceExpression[i]=="angry" && lefteye[i]<0.5 && righteye[i]<0.5){
            attentive.add("false");
          }
        }*/
      }
      else {
        if (righteye[i] >= 0.7 && lefteye[i] >= 0.7 &&
            faceExpression[i] == "surprise") {
          attentive.add("true");
        }
        else {
          if ((lefteye[i] >= 0.6 && righteye[i] >= 0.6 &&
              faceExpression[i] == "neutral") || faceExpression[i] == "happy") {
            attentive.add("true");
          }
          else {
            if (righteye[i] >= 0.85 && lefteye[i] >= 0.85 &&
                faceExpression[i] == "fear") {
              attentive.add("true");
            }
            else {
              attentive.add("true");
            }
          }
        }*/

      //attentive.add("true");
    }
    for (var j = 0; j < attentive.length; j++) {
      if (attentive[j] == "true") {
        tcount++;
      } else {
        fcount++;
      }
    }
    print('****************************');
    print(tcount);
    print(fcount);


    setState(() {
      exp = false;
      fd=null;
      pref = true;
      this.attentionProb = (tcount / attentive.length.toInt()) * 100;
      this.nonAttentionProb = (fcount / attentive.length.toInt()) * 100;
    });
    print(attentionProb);
    print(nonAttentionProb);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'CALL ANALYZER',
            style: GoogleFonts.aldrich(
              textStyle: TextStyle(
                color: Colors.white,
                letterSpacing: .5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.developer_board,
                color: Colors.white,
              ),
              onPressed: () {
                _listofFiles();
              },
            ),
            IconButton(
              icon: Icon(
                Icons.account_tree_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Database(cropImage: cropImage)));
              },
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 60),
              child: Scaffold(
                backgroundColor: Colors.white,
                body:  Container(child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          image: AssetImage('assets/images/bgchat.jpg'),
                          width: 200,
                        ),
                        fd==false ? Text(
                            'Analyse your images ...',
                            style: TextStyle(
                                color: Colors.lightBlue,
                                fontSize: 20
                            )
                        ): fd==true ? Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                  'Images are being pre processed ...',
                                  style: TextStyle(
                                      color: Colors.lightBlue,
                                      fontSize: 20
                                  )
                              ),
                            ),
                            CircularProgressIndicator(),
                          ],
                        ): Wrap(
                          children: [
                            InkWell(
                              child: Card(
                                  color: Colors.lightBlue,
                                  elevation: 6,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 50, horizontal: 20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Text(
                                            'Result',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 30,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Divider(
                                          color: Colors.white,
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Analysis Time:',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              ' $time',
                                              style: TextStyle(
                                                  color: Colors.white, fontSize: 20),
                                            ),
                                          ],
                                        ),
                                        Divider(
                                          color: Colors.white,
                                        ),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '\nProbabilities:',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              'Attentive (${double.parse(attentionProb.toString()).toStringAsFixed(2)})'
                                                  '\nNon Attentive (${double.parse(nonAttentionProb.toString()).toStringAsFixed(2)})',
                                              style: TextStyle(
                                                  color: Colors.white, fontSize: 15),
                                            ),
                                          ],
                                        ),
                                        Divider(
                                          color: Colors.white,
                                        ),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '\nAttentive/Non Attentive:',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              attentionProb > nonAttentionProb
                                                  ? 'Attentive'
                                                  : 'Non Attentive',
                                              style: TextStyle(
                                                  color: Colors.white, fontSize: 20),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )),
                              onTap: () {},
                              splashColor: Colors.black12,
                            ),
                          ],
                        ),
                      ],
                      ),
                      ),
                    )
                )),
              ),
        ),
      );
  }

  void userToDb(String currentUserId) {
    DocumentReference userRef = Firestore.instance
        .collection("prediction")
        .document(currentUserId)
        .collection(currentUserId)
        .document();
    userRef.setData({
      "uid": currentUserId,
      "time": DateFormat("H:m").format(DateTime.now()).toString(),
      "result": "attentive"
    }).then((_) {
      Toast.show("Result Updated", context,
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER,
          backgroundRadius: 5);
    });
  }

  void _listofFiles() async {
    setState(() {
      fd = true;
    });

    print('**********List***************');
    directory = "storage/emulated/0/cognos/";
    setState(() {
      f = Directory("$directory").listSync();
      for (var i = 0; i < f.length; i++) {
        file.add(f[i].toString().substring(7, f[i].toString().length - 1));
        print(file[i]);

        //file.add(f[i].toString().replaceRange(0,7,'').toString());
      }
      /*for(var i=0;i<file.length;i++){
        file.add(file[i].toString().);
      }*/
    });
    print('***********************');
    getImage(file);
  }

  Future getImage(List file) async {
    setState(() {
      rect = List<Rect>();
    });
    int j;
    for (j = 0; j < file.length; j++) {
      _img2 = File(file[j]);
      var visionImage = FirebaseVisionImage.fromFile(_img2);
      var options = new FaceDetectorOptions(
        enableTracking: true,
        enableLandmarks: true,
        enableClassification: true,
        mode: FaceDetectorMode.accurate,
      );

      Completer<ui.Image> completer = new Completer<ui.Image>();
      Image.file(_img2)
          .image
          .resolve(new ImageConfiguration())
          .addListener(new ImageStreamListener((ImageInfo image, bool _) {
        completer.complete(image.image);
      }));
      ui.Image info = await completer.future;
      int width = info.width;
      int height = info.height;

      print('*************************** $width $height');

      var faceDetector = FirebaseVision.instance.faceDetector(options);
      List<Face> faces = await faceDetector.processImage(visionImage);
      int i = 0;
      //String meetingid = 'meeting';
      for (Face f in faces) {
        rect.add(f.boundingBox);
        print(rect);
        i++;
        print(
            'Probabilities: ${f.leftEyeOpenProbability},${f.rightEyeOpenProbability},${f.headEulerAngleY},');
        righteye.add(f.rightEyeOpenProbability);
        lefteye.add(f.leftEyeOpenProbability);
        print('${f.headEulerAngleZ},${f.smilingProbability},${f.trackingId}');

        int diff;
        int newLeft, newWidth, newHeight, newTop;
        //////////////////////////////////////////////////////////////////////
        if ((f.boundingBox.left.toInt() + f.boundingBox.width.toInt()) <
                width &&
            (f.boundingBox.top.toInt() + f.boundingBox.height.toInt()) <
                height &&
            (f.boundingBox.left.toInt() >= 0) &&
            (f.boundingBox.top.toInt() >= 0)) {
          croppedFile = await FlutterNativeImage.cropImage(
              _img2.path,
              f.boundingBox.left.toInt(),
              f.boundingBox.top.toInt(),
              f.boundingBox.width.toInt(),
              f.boundingBox.height.toInt());

          print('******************True');
        } else {
          try {
            if ((f.boundingBox.left.toInt().isNegative)) {
              diff = -(f.boundingBox.left.toInt());
              newLeft = 0;
              newWidth = (f.boundingBox.width.toInt()) - diff;
              newTop = (f.boundingBox.top.toInt()) + diff;
              newHeight = (f.boundingBox.height.toInt()) - diff;
            }
            if ((f.boundingBox.top.toInt().isNegative)) {
              diff = -(f.boundingBox.top.toInt());
              newTop = 0;
              newHeight = (f.boundingBox.height.toInt()) - diff;
              newLeft = (f.boundingBox.left.toInt()) + diff;
              newWidth = (f.boundingBox.width.toInt()) - diff;
            }
            if ((f.boundingBox.left.toInt() + f.boundingBox.width.toInt()) <
                width) {
              diff = width -
                  (f.boundingBox.left.toInt() + f.boundingBox.width.toInt());
              newLeft = f.boundingBox.left.toInt() + (diff ~/ 2);
              newWidth = f.boundingBox.width.toInt() - (diff ~/ 2);

              newTop = f.boundingBox.top.toInt() + (diff ~/ 2);
              newHeight = f.boundingBox.height.toInt() - (diff ~/ 2);
            }
            if ((f.boundingBox.top.toInt() + f.boundingBox.height.toInt()) <
                height) {
              diff = height -
                  (f.boundingBox.top.toInt() + f.boundingBox.height.toInt());
              newLeft = f.boundingBox.left.toInt() + (diff ~/ 2);
              newWidth = f.boundingBox.width.toInt() - (diff ~/ 2);

              newTop = f.boundingBox.top.toInt() + (diff ~/ 2);
              newHeight = f.boundingBox.height.toInt() - (diff ~/ 2);
            }
            print('******************* $newTop $newHeight $newLeft $newWidth');
            croppedFile = await FlutterNativeImage.cropImage(
                _img2.path, newLeft, newTop, newWidth, newHeight);
          } catch (Exception) {
            //
          }
        }
        print('*******************False');
      }
      /////////////////////////////////////////////////////
      //DateTime now = new DateTime.now();
      /*DateTime date = new DateTime(
            now.year, now.month, now.day, now.hour, now.minute, now.second);
        print(
            formatDate(date, [yyyy, '', mm, '', dd, '', HH, '', nn, '_', ss]));
        var formatted_date = formatDate(
            date, [yyyy, '_', mm, '_', dd, '_', HH, '_', nn, '_', ss]);*/
      //croppedFile.copy('${dirPath}/FaceData/${meetingid}_${i}_${formatted_date.toString()}.jpg');
      //print('Cropped File Path: ${croppedFile}');
      //Toast.show('Image Cropped', context, duration: Toast.LENGTH_SHORT,
      //gravity: Toast.BOTTOM);
      cropImage.add(croppedFile.toString());
      print('$cropImage *****************');
      //classifyImage(croppedFile);
    }
    //print(cropImage);
    classifyImage(cropImage);
    loadImage(_img2).then((img) {
      setState(() {
        this.image = img;
      });
    });
  }

  Future<ui.Image> loadImage(File image) async {
    var img = await image.readAsBytes();
    return await decodeImageFromList(img);
  }

/*Future<String> loadModel() async {
    return Tflite.loadModel(
      model: "assets/emotion_ai.tflite",
      labels: "assets/emotion_ai.txt",
    );
  }*/

/*Future<void> classifyImage(List cImage) async {
    for(var i=0;i<cImage.length;i++){
      classImage.add(cImage[i].toString().substring(7,cImage[i].toString().length-1));
      print(classImage[i]);
      //file.add(f[i].toString().replaceRange(0,7,'').toString());
    }
    /*for(var k = 0; k<classImage.length;k++){
      var output = await Tflite.runModelOnImage(
        path: classImage[k],
        numResults: 4,
        threshold: 0.005,
        imageMean: 127.5,
        imageStd: 127.5,
      );
      setState(() {
        _img1 = classImage[k];
        _loading = false;
        _outputs = output;
      });
      print("inside classify image *********************************");
      print((_outputs[0]["label"]).runtimeType);
      print(_outputs[0]["label"]);
      faceExpression.add(_outputs[0]["label"].toString());
      print('************************ ${faceExpression} **************************');
      //Toast.show('${faceExpression}', context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
    }*/
    //print('************************ ${faceExpression} **************************');
  }*/
}
