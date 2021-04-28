import 'package:flutter/material.dart';

class Status extends StatefulWidget {
  @override
  _StatusState createState() => _StatusState();
}

class _StatusState extends State<Status> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:  Container(child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: AssetImage('assets/images/bgchat.jpg'),
                width: 200,
              ),
              Text(
                  'Status appears here ...',
                  style: TextStyle(
                      color: Colors.lightBlue,
                      fontSize: 20
                  )
              )
            ],
          )
      )),
    );
  }
}
