import 'package:flutter/material.dart';

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
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.developer_board, color: Colors.white,),
              color: Colors.lightBlue,
              onPressed: () {

              },
            ),
            ListView.builder(
                itemCount: 2,
                itemBuilder: (context, i) => new GestureDetector(
                  child: Card(
                    color: Colors.lightBlue,
                    elevation: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Result',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        Text(
                          'Predicted Output: 70% Laughing',
                          style: TextStyle(color: Colors.white, fontSize: 22),
                        ),
                      ],
                    )
                  ),
                ),
            ),
          ],
        )
      ),
    );
  }
}
