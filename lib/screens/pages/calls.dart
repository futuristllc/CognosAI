import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognos/models/call_model.dart';
import 'package:cognos/models/calls_data.dart';
import 'package:cognos/models/userlist.dart';
import 'package:cognos/resources/firebase_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cognos/utils/call_utils.dart';
import 'package:cognos/utils/permissions.dart';


class CallsList extends StatefulWidget {

  @override
  _CallsListState createState() => _CallsListState();
}

class _CallsListState extends State<CallsList> {
  List<Call> call_logs;

  String currentUser;
  String _currentUserId;
  UserList sender, receiver;

  @override
  void initState() {
    super.initState();
    FirebaseRepository _repository = FirebaseRepository();
    _repository.getCurrentUser().then((user) => currentUser = user.uid);

    fetchContacts(currentUser).then((List<Call> list){
      call_logs = list;
    });

    _repository.getCurrentUser().then((user) {
      _currentUserId = user.uid;

      setState(() {
        Firestore.instance.collection("users").document(user.uid).get().then((
            value) {
          String name = value.data['name'];
          String uid = value.data['uid'];
          String prourl = value.data['profileurl'];

          sender = UserList(
            uid: uid,
            name: name,
            profileurl: prourl,
          );
        });
      });
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
      calls.sort((a, b) => b.date.compareTo(a.date));
      call_logs = calls;
    });
    if (call_logs != null) {
      return Scaffold(
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
                      //var url = _currentUserId == call_logs[i].receiverId.toString()? call_logs[i].callerPic: call_logs[i].receiverPic;
                      leading: new CircleAvatar(
                        foregroundColor: Theme.of(context).primaryColor,
                        backgroundColor: Colors.grey,
                        backgroundImage: _currentUserId==call_logs[i].receiverId ?
                        call_logs[i].callerPic!=null?NetworkImage(call_logs[i].callerPic):
                      AssetImage('assets/images/user.png') :
                          call_logs[i].receiverPic!=null?NetworkImage(call_logs[i].receiverPic):
                          AssetImage('assets/images/user.png'),
                      radius: 22,

                      ),
                      title: new Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text(
                            _currentUserId == call_logs[i].receiverId.toString()? call_logs[i].callerName: call_logs[i].receiverName,
                            style: new TextStyle(fontWeight: FontWeight.bold),
                          ),
                          new Padding(
                            padding: EdgeInsets.only(top: 3),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                _currentUserId==call_logs[i].receiverId ?
                                Icon(Icons.call_received, size: 18, color: Colors.green,):
                                Icon(Icons.call_made, size: 18, color: Colors.green,),
                                Padding(padding: EdgeInsets.only(left: 3,),
                                  child: Text(call_logs[i].time, style: new TextStyle(color: Colors.grey, fontSize: 16.0),),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      trailing: new Container(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: call_logs[i].type=='VOICE'? IconButton(
                            icon: Icon(Icons.phone, color: Colors.lightBlue,),
                            onPressed: () async {
                              receiver = UserList(
                                uid: _currentUserId == call_logs[i].receiverId.toString()? call_logs[i].callerId: call_logs[i].receiverId,
                                name: _currentUserId == call_logs[i].receiverId.toString()? call_logs[i].callerName: call_logs[i].receiverName,
                                profileurl: _currentUserId == call_logs[i].receiverId.toString()? call_logs[i].callerPic: call_logs[i].receiverPic,
                              );
                              await Permissions
                                  .cameraAndMicrophonePermissionsGranted()
                                  ? CallUtils.dial(
                                from: sender,
                                to: receiver,
                                type: "VOICE",
                                context: context,
                              ) : {};
                            }):
                          IconButton(
                            icon: Icon(Icons.videocam, color: Colors.lightBlue,),
                            onPressed: () async {
                              receiver = UserList(
                                uid: _currentUserId == call_logs[i].receiverId.toString()? call_logs[i].callerId: call_logs[i].receiverId,
                                name: _currentUserId == call_logs[i].receiverId.toString()? call_logs[i].callerName: call_logs[i].receiverName,
                                profileurl: _currentUserId == call_logs[i].receiverId.toString()? call_logs[i].callerPic: call_logs[i].receiverPic,
                              );
                            await Permissions.cameraAndMicrophonePermissionsGranted()
                                ? CallUtils.dial(
                              from: sender,
                              to: receiver,
                              type: "VIDEO",
                              context: context,
                            ):{};},
                          ),
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
    } else {
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
}
