import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognos/models/call_model.dart';
import 'package:cognos/models/calls_data.dart';
import 'package:cognos/models/userlist.dart';
import 'package:cognos/resources/firebase_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CallsList extends StatefulWidget {
  @override
  _CallsListState createState() => _CallsListState();
}

class _CallsListState extends State<CallsList> {
  List<Call> call_logs;

  String currentUser;

  @override
  void initState() {
    super.initState();
    FirebaseRepository _repository = FirebaseRepository();
    _repository.getCurrentUser().then((user) => currentUser = user.uid);

    fetchContacts(currentUser).then((List<Call> list){
      call_logs = list;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<List<Call>> fetchContacts(String currentUser) async {
    List<Call> cl = List<Call>();

    QuerySnapshot querySnapshot = await Firestore.instance.collection("call_logs").document(currentUser).collection(currentUser).getDocuments();
    for (var i = 0; i < querySnapshot.documents.length; i++) {
      //if (querySnapshot.documents[i].documentID == currentUser) {
      cl.add(Call.fromMap(querySnapshot.documents[i].data));
      // }
    }
    // print(cl[0].callerId+' '+cl[0].receiverName);
    return cl;
  }

  @override
  Widget build(BuildContext context) {

    fetchContacts(currentUser).then((calls){
      calls.sort((a, b) => b.time.compareTo(a.time));
      call_logs = calls;
    });
    return call_logs != null ? Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(top: 7),
        child: ListView.builder(
          itemCount: call_logs.length,
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
                        backgroundImage: call_logs[i].receiverPic!=null?
                        NetworkImage(call_logs[i].receiverPic): AssetImage('assets/images/user.png'),
                        radius: 22,
                      ),
                      title: new Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text(
                            call_logs[i].receiverName,
                            style: new TextStyle(fontWeight: FontWeight.bold),
                          ),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              call_logs[i].hasDialled=='false'?Icon(Icons.call_received, size: 18, color: Colors.green,):
                              call_logs[i].hasDialled=='true'?Icon(Icons.call_received, size: 18, color: Colors.red,):
                              Icon(Icons.call_made, size: 18, color: Colors.green,),

                              Padding(padding: EdgeInsets.only(left: 3),
                                child: Text(call_logs[i].time, style: new TextStyle(color: Colors.grey, fontSize: 16.0),),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: new Container(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: call_logs[i].type=='VOICE'?Icon(Icons.call, color: Colors.lightBlue,):Icon(Icons.videocam, color: Colors.lightBlue,)
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
    ):
    Scaffold(
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
                  'Call Logs appears here ...',
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
