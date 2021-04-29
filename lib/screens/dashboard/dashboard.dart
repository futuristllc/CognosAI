import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cognos/screens/dashboard/database.dart';

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Container(
                decoration: new BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: new BorderRadius.circular(15),
                ),
              child: InkWell(
                child: Column(
                  children: <Widget>[
                    Card(
                        color: Colors.lightBlue,
                        elevation: 3,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
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
            ),
          ),
        ),
      ),
    );
  }
}
