import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognos/resources/firebase_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:toast/toast.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {

  FirebaseRepository _repository = FirebaseRepository();

  TextEditingController phoneCon = new TextEditingController();
  TextEditingController emailCon = new TextEditingController();
  TextEditingController nameCon = new TextEditingController();
  TextEditingController abCon = new TextEditingController();

  String currentUserId;
  String initials;
  String time, date, uname, prourl, phone, email,dob;
  var now;

  String fileType = '';
  File file;
  String fileName = '';
  String operationText = '';
  bool isUploaded = true;
  String result = '';
  bool userUpdated = false;
  File _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _repository.getCurrentUser().then((user) {
      setState(() {
        now = new DateTime.now();
        date = new DateFormat("dd-MM-yyyy").format(now);
        time = new DateFormat("H:m:s").format(now);
        currentUserId = user.uid;
        getData();
        //getDir();
        getProfileUrl();
      });
    });
  }

  void getData() async{
    Firestore.instance.collection("users").document(currentUserId).get().then((value){
      setState(() {
        emailCon.text = value.data['email'];
        phoneCon.text = value.data['phone'];
        nameCon.text = value.data['name'];
        abCon.text = value.data['about'];
        prourl = value.data['profileurl'];
      });
    });
  }

  /*void getDir() async {
    var path = await ExtStorage.getExternalStorageDirectory();
    print(path);  // /storage/emulated/0
    new Directory('${path}/Cognos').create()
    // The created directory is returned as a Future.
        .then((Directory directory) {
      print(directory.path);
    });
  }*/

  Future imagePicker() async {
    final File pickedFile = await ImagePicker.pickImage(source: ImageSource.gallery, maxWidth: 500, maxHeight: 500, imageQuality: 85);
    setState(() {
      _image = File(pickedFile.path);
    });
    Toast.show("Wait while we upload your your Profile Image", context, duration: Toast.LENGTH_LONG, backgroundRadius: 5, gravity: Toast.CENTER);
    _uploadFile(pickedFile, _image);
  }

  Future cameraPicker() async {
    final File pickedFile = await ImagePicker.pickImage(source: ImageSource.camera, maxWidth: 500, maxHeight: 500, imageQuality: 85);
    setState(() {
      _image = File(pickedFile.path);
    });
    Toast.show("Wait while we upload your your Profile Image", context, duration: Toast.LENGTH_LONG, backgroundRadius: 5, gravity: Toast.CENTER);
    _uploadFile(pickedFile, _image);
  }

  Future<void> _uploadFile(File file, File filename) async {
    StorageReference storageReference;
    storageReference = FirebaseStorage.instance.ref().child('images/${currentUserId}');
    final StorageUploadTask uploadTask = storageReference.putFile(file);
    final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    final String url = (await downloadUrl.ref.getDownloadURL());
    print("URL is $url");
    DocumentReference userRef = Firestore.instance.collection("users").document(currentUserId);

    userRef.setData({
      "name": nameCon.text,
      "about": abCon.text,
      "phone": phoneCon.text,
      "email": emailCon.text,
      "profileurl": url,
      "uid": currentUserId,
    }).then((_) {
      Toast.show('Profile Image has been uploaded successfully', context, duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER, backgroundRadius: 5);
      prourl = url;
    });
    prourl = url;
  }

  @override
  void dispose() {
    phoneCon.dispose();
    emailCon.dispose();
    nameCon.dispose();
    abCon.dispose();
    super.dispose();
  }

  void userToDb(String currentUserId) {
    userUpdated = false;
    DocumentReference userRef = Firestore.instance.collection("users").document(currentUserId);
    if(nameCon.text.length!=0 && abCon.text.length!=0 && phoneCon.text.length!=0 && emailCon.text.length!=0){
      userRef.setData({
        "name": nameCon.text,
        "about": abCon.text,
        "phone": phoneCon.text,
        "email": emailCon.text,
        "profileurl": prourl,
        "uid": currentUserId,
      }).then((_){
        Toast.show("User Updated Successfully", context, duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER, backgroundRadius: 5);
      });
    }
    else {
      Toast.show("Please enter the required details", context, duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER, backgroundRadius: 5);
    }
  }

  Future <void> getProfileUrl() async{
    Firestore.instance.collection("users").document(currentUserId).get().then((value){
      setState(() {
        prourl = value.data['profileurl'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    getProfileUrl();
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: ListView(
          children: <Widget>[
            /*Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                child: Text(
                  'User Profile',
                  style: TextStyle(
                    fontSize: 27,
                    color: Colors.lightBlue,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),*/
            Padding(
              padding: EdgeInsets.all(5),
              child:
              /*Card(
                elevation: 5,
                shadowColor: Colors.grey,
                child:
              ),*/
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      children: <Widget>[
                        Center(
                          child: Stack(
                            children: <Widget>[
                              Container(
                                alignment: Alignment.center,
                                clipBehavior: Clip.hardEdge,
                                height: 180,
                                width: 180,
                                decoration: new BoxDecoration(
                                  color: Colors.grey.shade300,
                                  shape: BoxShape.circle,
                                ),
                                child: (prourl != null)
                                    ? CircleAvatar(
                                  radius: 150,
                                  backgroundImage: NetworkImage(prourl),
                                )
                                    :new Container(
                                  child: Icon(
                                    Icons.person,
                                    size: 100,
                                    color: Colors.black38,
                                  ) ,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 130,left: 130),
                                child: ButtonTheme(
                                  height: 50,
                                  child: RaisedButton(
                                    color: Colors.lightBlue,
                                    shape: CircleBorder(),
                                    onPressed: () {_settingModalBottomSheet(context);},
                                    elevation: 7,
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),),
                        Center(
                          child: TextField(
                            autofocus: false,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20, color: Colors.lightBlue, fontFamily: 'Pacifico', fontWeight: FontWeight.bold),
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Your Name",hintStyle: TextStyle(fontSize: 20, color: Colors.grey, fontFamily: 'Pacifico'),
                            ),
                            controller: nameCon,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 5,right: 5,top: 0,bottom: 0),
              child: Container(
                decoration: new BoxDecoration(
                  color: Colors.white,
                  borderRadius: new BorderRadius.circular(15),
                ),
                child: Column(
                  children: <Widget>[
                    Divider(
                      color: Colors.white,
                      indent: 16.0,
                      endIndent: 16.0,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top:10),
                      child: ListTile(
                        leading: Icon(Icons.person, color: Colors.lightBlue,),
                        title: Text('About', style: TextStyle(fontSize: 11, color: Colors.grey, ),),
                        subtitle: TextField(
                          autofocus: false,
                          style: TextStyle(fontSize: 15, color: Colors.lightBlue),
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "About You",hintStyle: TextStyle(fontSize: 15, color: Colors.grey),
                          ),
                          controller: abCon,
                        ),
                      ),
                    ),
                    Divider(indent: 16, endIndent: 16, thickness: 1,),
                    Padding(
                      padding: EdgeInsets.only(top: 14),
                      child: ListTile(
                        leading: Icon(Icons.phone, color: Colors.lightBlue,),
                        title: Text('Phone', style: TextStyle(fontSize: 11, color: Colors.grey, ),),
                        subtitle: TextField(
                          autofocus: false,
                          style: TextStyle(fontSize: 15, color: Colors.lightBlue),
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter Phone Number",hintStyle: TextStyle(fontSize: 15, color: Colors.grey),
                          ),
                          controller: phoneCon,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.email, color: Colors.lightBlue,),
                      title: Text('Email', style: TextStyle(fontSize: 11, color: Colors.grey, ),),
                      subtitle: TextField(
                        autofocus: false,
                        style: TextStyle(fontSize: 15, color: Colors.lightBlue),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter Email",hintStyle: TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                        controller: emailCon,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: FloatingActionButton(
                onPressed: () {
                  userToDb(currentUserId);
                },
                tooltip: 'Set Profile',
                child: Icon(Icons.done, color: Colors.white,),
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      ),
    );
  }

  void get_p() {
    if(phone.toString() != ''){
      phoneCon.text = phone.toString();
    }
  }

  void get_e() {
    if(email != '');
    emailCon.text = email.toString();
  }

  void _settingModalBottomSheet(context) {
    showModalBottomSheet(context: context, builder: (BuildContext bc) {
      return new Container(
        //could change this to Color(0xFF737373),
        //so you don't have to change MaterialApp canvasColor
        child: new Container(
          decoration: new BoxDecoration(
              color: Colors.white,
              borderRadius: new BorderRadius.only(
                  topLeft: const Radius.circular(10.0),
                  topRight: const Radius.circular(10.0))),
          child: new Wrap(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top:50, bottom:50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.camera, size: 35, color: Colors.deepPurple,),
                          Padding(
                              padding: EdgeInsets.only(top:15),
                              child: Text('Camera', style: TextStyle(fontSize: 16),)),
                        ],
                      ),
                      onTap: (){
                        cameraPicker();
                      },
                    ),
                    InkWell(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.image,size: 35, color: Colors.lightBlue,),
                          Padding(
                              padding: EdgeInsets.only(top:15),
                              child: Text('Gallery', style: TextStyle(fontSize: 16))),
                        ],
                      ),
                      onTap: (){
                        imagePicker();
                      },
                    ),
                  ],
                ),
              )
            ],),),
      );
    });
  }
}


