import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognos/image_provider/user_provider.dart';
import 'package:cognos/screens/call_screen/pickup/pickup_layout.dart';
import 'package:cognos/screens/float_screens/call_search.dart';
import 'package:cognos/screens/float_screens/contact_search.dart';
import 'package:cognos/screens/float_screens/status_picker.dart';
import 'package:cognos/signup.dart';
import 'package:cognos/utils/utilities.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cognos/const/constants.dart';
import 'package:cognos/resources/firebase_repository.dart';
import 'package:cognos/screens/pages/calls.dart';
import 'package:cognos/screens/pages/chat_list.dart';
import 'package:cognos/screens/pages/status.dart';
import 'package:cognos/screens/pages/userprofile.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {

  final FirebaseUser user;

  Home({Key key, this.user}): super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

final FirebaseRepository _repository = FirebaseRepository();

class _HomeState extends State<Home> {

  String currentUserId, photourl;
  String initials, userName;
  String time, date, uname, prourl;
  var now;


  FirebaseRepository _repository = FirebaseRepository();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  PageController _myPage = PageController(initialPage: 1);

  int _page = 1;
  int _count = 0;

  UserProvider userProvider;


  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.refreshUser();
    });
    _repository.getCurrentUser().then((user) {
      setState(() {
        now = new DateTime.now();
        date = new DateFormat("dd-MM-yyyy").format(now);
        time = new DateFormat("H:m:s").format(now);
        currentUserId = user.uid;
        /*uname = user.displayName;
        prourl = user.photoUrl;*/
        initials = Utils.getInitials(user.displayName);
        updateTimeStart();
      });
    });
  }

  Future<void> updateTimeStart() async {

    DocumentReference userRef = Firestore.instance.collection("users").document(currentUserId);

    userRef.updateData({
      "state": "online",
      "lastTime": DateFormat("H:m").format(DateTime.now()).toString(),
    });
  }

  Future<void> removeState() async {

    DocumentReference userRef = Firestore.instance.collection("users").document(currentUserId);

    userRef.updateData({
      "state": "offline",
      "lastTime": DateFormat("H:m").format(DateTime.now()).toString(),
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    removeState();
    super.deactivate();
  }

  void _openDrawer() {
    _scaffoldKey.currentState.openDrawer();
  }

  void _closeDrawer() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    Firestore.instance.collection("users").document(currentUserId).get().then((value){
      setState(() {
        prourl = value.data['profileurl'];
      });
    });
    return PickupLayout(
      scaffold: WillPopScope(
        onWillPop: () async {
          removeState().then((_){
            return false;
          });
          //dispose();
          Navigator.of(context).dispose();
          //return true;
        },
        key: _scaffoldKey,
        child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlue,
          title: Text(_page == 0 ? 'User Profile ': 'Cognos AI', style: TextStyle(color: Colors.white, fontFamily: 'Cookie', fontSize: 30),),
          centerTitle: true,
          elevation: 2,
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: PageView(
            controller: _myPage,
            onPageChanged: (int) {
              print('Page Changes to index $int');
              setState(() {
                _page = int;
              });
            },
            children: <Widget>[
              Center(
                child: Container(
                  child: UserPage(),
                  //UserProfile(),
                ),
              ),
              Center(
                child: ChatsList(),
              ),
              Center(
                child: Container(
                  child: Status(),
                ),
              ),
              Center(
                child: Container(
                  child: CallsList(),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          child: Container(
            height: 50.0,
            child: new Row(
              mainAxisAlignment: _page!=0 ? MainAxisAlignment.start:MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  icon: CircleAvatar(
                    child: CircleAvatar(
                      child: CircleAvatar(
                        //User Image
                        radius: 11,
                        backgroundImage: prourl!=null?NetworkImage(prourl):null,
                      ),
                      backgroundColor: Colors.white,
                      radius: 12,
                    ),
                    backgroundColor: (_page == 0)? Colors.black : Colors.white,
                    radius: 13,
                  ),
                  iconSize: 13,
                  onPressed: () {
                    setState(() {
                      _myPage.jumpToPage(0);
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () {
                    _openDrawer();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.message,
                      color: (_page == 1) ? Colors.lightBlue : Colors.black ),
                  tooltip: 'Chats',
                  onPressed: () {
                    setState(() {
                      _myPage.jumpToPage(1);
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.add_a_photo),
                  color: (_page == 2) ? Colors.lightBlue : Colors.black ,
                  tooltip: 'Status',

                  onPressed: () {
                    setState(() {
                      _myPage.jumpToPage(2);
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.call),
                  color: (_page == 3) ? Colors.lightBlue : Colors.black ,
                  tooltip: 'Calls',
                  onPressed: () {
                    setState(() {
                      _myPage.jumpToPage(3);
                    });
                  },
                ),
                PopupMenuButton<String>(
                  onSelected: choiceAction,
                  itemBuilder: (BuildContext context){
                    return Constants.choices.map((String choice){
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                )
              ],
            ),
          ),
        ),
        floatingActionButton: _page!=0 ? FloatingActionButton(
          onPressed: (){
            if(_page==1){
              Navigator.push(context, MaterialPageRoute(builder: (context) => ContactSearch()));
            }
            else if(_page==2){
              Navigator.push(context, MaterialPageRoute(builder: (context) => StatusPicker()));
            }
            else {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CallSearch()));
            }

          },
          tooltip: 'Add Post',
          child: _page==1?Icon(Icons.message):(_page==2)?Icon(Icons.add_photo_alternate):Icon(Icons.add_call)
        ):null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,

        drawer: Drawer(
          child: SafeArea(
            child: Text(
              'COGNOS by Futurist',
              style: TextStyle(
                fontFamily: 'Cookie',
                fontSize: 20,
                color: Colors.lightBlue,
              ),
            ),
          )
        ),
        // Disable opening the drawer with a swipe gesture.
        drawerEnableOpenDragGesture: true,
        drawerScrimColor: Colors.lightBlue,
      ),
    ));
  }

  void choiceAction(String choice){
    if(choice == Constants.Logout) {
      /*_firebaseAuth.signOut();
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => App()));*/
      _repository.signOut();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => SignUp()));
    }
  }
}
