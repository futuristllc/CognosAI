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
  String faceExpr;

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
        body: Center(
          child: Text(
            faceExpr
          ),
        ),
      ),
    );
  }
}
