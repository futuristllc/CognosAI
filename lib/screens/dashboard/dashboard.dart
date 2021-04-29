import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cognos/screens/dashboard/database.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognos/resources/firebase_repository.dart';

class DashBoard extends StatefulWidget {
  final List faceExpr;

  DashBoard({
    @required this.faceExpr,
  });
  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  List faceExpr;
  List expr;
  FirebaseRepository _repository = FirebaseRepository();
  String currentUserId, date, time;
  var now;

  @override
  void initState() {
    super.initState();

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'CALL ANALYZER',
            style: GoogleFonts.aldrich(
              textStyle: TextStyle(color: Colors.white, letterSpacing: .5, fontWeight: FontWeight.bold,),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.developer_board, color: Colors.white,),
              onPressed: (){

              },
            ),
            IconButton(
              icon: Icon(Icons.account_tree_outlined, color: Colors.white,),
              onPressed: (){
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Database()));
              },
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: Container(
          decoration: BoxDecoration(
            color: Colors.white
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 60),
            child: Wrap(
              children: [
                InkWell(
                  child: Card(
                      color: Colors.lightBlue,
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                'Result',
                                style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Divider(color: Colors.white,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Time:',
                                  style: TextStyle(color: Colors.white, fontSize: 20,fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  ' 10:30',
                                  style: TextStyle(color: Colors.white, fontSize: 20),
                                ),
                              ],
                            ),
                            Divider(color: Colors.white,),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '\nClassified Class:',
                                  style: TextStyle(color: Colors.white, fontSize: 20,fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '\n70% Laughing, \n30% Neutral',
                                  style: TextStyle(color: Colors.white, fontSize: 15),
                                ),
                              ],
                            ),
                            Divider(color: Colors.white,),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '\nAttentive/Non Attentive:',
                                  style: TextStyle(color: Colors.white, fontSize: 20,fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Non Attentive',
                                  style: TextStyle(color: Colors.white, fontSize: 20),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                  ),
                  onTap: (){

                  },
                  splashColor: Colors.black12,
                ),
              ],
            )
            ),
          ),
        ),
    );
  }

  void userToDb(String currentUserId) {
    DocumentReference userRef = Firestore.instance.collection("prediction").document(currentUserId).collection(currentUserId).document();
      userRef.setData({
        "uid": currentUserId,
        "time": DateFormat("H:m").format(DateTime.now()).toString(),
        "result": "attentive"
      }).then((_){
        Toast.show("Result Updated", context, duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER, backgroundRadius: 5);
      });
    }
}
