import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognos/models/userlist.dart';
import 'package:cognos/resources/firebase_repository.dart';
import 'package:cognos/screens/chatscreen/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:floating_search_bar/floating_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ContactSearch extends StatefulWidget {
  ContactSearch({Key key,}) : super(key: key);

  @override
  _ContactSearchState createState() => _ContactSearchState();
}

class _ContactSearchState extends State<ContactSearch> {

  List<UserList> userList;
  String currentUserId, time, date, uname, prourl;
  var now;

  @override
  void initState() {
    super.initState();
    FirebaseRepository _repository = FirebaseRepository();
    _repository.getCurrentUser().then((user) {
      setState(() {
        now = new DateTime.now();
        date = new DateFormat("dd-MM-yyyy").format(now);
        time = new DateFormat("H:m:s").format(now);
        currentUserId = user.uid;
      });
    });

    _repository.getCurrentUser().then((FirebaseUser user) {
      _repository.fetchAllUsers(user).then((List<UserList> list) {
        setState(() {
          userList = list;
        });
      });
    });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    //userList.clear();
  }


  @override
  Widget build(BuildContext context) {
    Firestore.instance.collection("users").document(currentUserId).get().then((value){
      prourl = value.data['profileurl'];
    });
    return Scaffold(
      body: (userList==null)? Container(child: Center(child: CircularProgressIndicator(),),):
      FloatingSearchBar.builder(
        pinned: true,
        itemCount: userList.length,
        padding: EdgeInsets.only(top: 10.0),
        itemBuilder: (BuildContext context, int i) {
          return GestureDetector(
            child: InkWell(
              child: Column(
                children: <Widget>[
                  new ListTile(
                    leading: new CircleAvatar(
                      foregroundColor: Theme.of(context).primaryColor,
                      backgroundColor: Colors.grey,
                      backgroundImage: (userList[i].profileurl!=null)? new NetworkImage(userList[i].profileurl):
                      AssetImage('assets/images/user.png'),
                    ),
                    title: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Text(
                          userList[i].name,
                          style: new TextStyle(fontWeight: FontWeight.bold),
                        ),
                        new Text(
                          'Hello',
                          style: new TextStyle(color: Colors.grey, fontSize: 14.0),
                        ),
                      ],
                    ),
                    subtitle: new Container(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: new Text(
                        userList[i].about,
                        style: new TextStyle(color: Colors.grey, fontSize: 15.0),
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
              onTap: (){
                _openChat(context,userList[i],i);
              },
              splashColor: Colors.black12,
            ),
          );
        },

        leading: CircleAvatar(
          backgroundImage: prourl==null? AssetImage('images/user.png'): NetworkImage(prourl,),
        ),
        endDrawer: Drawer(
          child: Container(),
        ),
        onChanged: (String value) {
        },
        onTap: () {},
        decoration: InputDecoration.collapsed(
          hintText: "Search...",
        ),
      )
    );
      /*Padding(
        padding: EdgeInsets.only(top: 7),
        child: ListView.builder(
            itemCount: userList.length,
            itemBuilder: (context, i) => new ),
      ),
    );*/
  }

  void _openChat(BuildContext context, UserList userDetail, int i) async {
    UserList clickedUser = UserList(
      uid: userList[i].uid,
      profileurl: userList[i].profileurl,
      name: userList[i].name,
      about: userList[i].about,
      email: userList[i].email,
      phone: userList[i].phone,
    );
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen(receiver: clickedUser)),
    );
  }

}

