import 'package:cognos/models/call_model.dart';
import 'package:flutter/material.dart';

class CallsList extends StatefulWidget {
  @override
  _CallsListState createState() => _CallsListState();
}

class _CallsListState extends State<CallsList> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(top: 7),
        child: ListView.builder(
          itemCount: call_list.length,
          itemBuilder: (context, i) => new GestureDetector(
            child: InkWell(
              child: Column(
                children: <Widget>[
                  new Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading: new CircleAvatar(
                        foregroundColor: Theme.of(context).primaryColor,
                        backgroundColor: Colors.grey,
                        backgroundImage: new NetworkImage(call_list[i].avatarUrl),
                        radius: 24,
                      ),
                      title: new Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text(
                            call_list[i].name,
                            style: new TextStyle(fontWeight: FontWeight.bold),
                          ),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              call_list[i].inout=='in'?Icon(Icons.call_received, size: 18, color: Colors.green,):
                              call_list[i].inout=='miss'?Icon(Icons.call_received, size: 18, color: Colors.red,):
                              Icon(Icons.call_made, size: 18, color: Colors.green,),

                              Padding(padding: EdgeInsets.only(left: 3),
                                child: Text(call_list[i].time, style: new TextStyle(color: Colors.grey, fontSize: 16.0),),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: new Container(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: call_list[i].type=='voice'?Icon(Icons.call, color: Colors.blue,):Icon(Icons.videocam, color: Colors.blue,)
                      ),
                    ),
                  ),
                  new Divider(
                    height: 1.0,
                    indent: 65,
                    endIndent: 15,
                  ),
                ],
              ),
              onTap: (){},
              splashColor: Colors.black12,
            ),
          ),
        ),
      ),
    );
  }
}
