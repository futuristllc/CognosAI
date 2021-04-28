import 'package:cognos/models/userlist.dart';
import 'package:cognos/resources/firebase_repository.dart';
import 'package:cognos/screens/chatscreen/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatsList extends StatefulWidget {

  // In the constructor, require a Todo.
  ChatsList({Key key,}) : super(key: key);

  @override
  _ChatsListState createState() => _ChatsListState();
}

class _ChatsListState extends State<ChatsList> {

  List<UserList> userList;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    FirebaseRepository _repository = FirebaseRepository();

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

    return Scaffold(
      backgroundColor: Colors.white,
      body: (userList==null)? Container(child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: AssetImage('assets/images/bgchat.jpg'),
                width: 200,
              ),
              Text(
                'Chats appears here ...',
                style: TextStyle(
                  color: Colors.lightBlue,
                  fontSize: 20
                )
              )
            ],
          )
      )):
      Padding(
        padding: EdgeInsets.only(top: 7),
        child: ListView.builder(
            itemCount: userList.length,
            itemBuilder: (context, i) => new GestureDetector(
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
                            userList[i].lastTime,
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
            )),
      ),
    );
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

