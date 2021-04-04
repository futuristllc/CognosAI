import 'dart:io';
import 'dart:math';
import 'package:bubble/bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognos/const/strings.dart';
import 'package:cognos/enum/view_state.dart';
import 'package:cognos/image_provider/image_upload_provider.dart';
import 'package:cognos/models/userlist.dart';
import 'package:cognos/screens/chatscreen/cache_image/cache_image.dart';
import 'package:cognos/screens/chatscreen/messages.dart';
import 'package:cognos/utils/call_utils.dart';
import 'package:cognos/utils/permissions.dart';
import 'package:cognos/utils/utilities.dart';
import 'package:cognos/resources/firebase_repository.dart';
import 'package:cognos/screens/chatscreen/custom_tile.dart';
import 'package:cognos/utils/universal_variables.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {

  final UserList receiver;

  ChatScreen({this.receiver});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  TextEditingController textFieldController = TextEditingController();
  FirebaseRepository _repository = FirebaseRepository();
  ScrollController _listScrollController = ScrollController();
  //ImageUploadProvider _imageUploadProvider;
  UserList sender;
  FocusNode textFieldFocus = FocusNode();
  String _currentUserId;
  ImageUploadProvider _imageUploadProvider;

  bool isWriting = false;
  bool showEmojiPicker = false;

  String _path;
  Map<String, String> _paths;
  String _extension;
  FileType _pickType;
  bool _multiPick = false;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  List<StorageUploadTask> _tasks = <StorageUploadTask>[];

  @override
  void initState() {
    super.initState();

    _repository.getCurrentUser().then((user) {
      _currentUserId = user.uid;

      setState(() {
        Firestore.instance.collection("users").document(user.uid).get().then((value){
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
  Widget build(BuildContext context) {

    _imageUploadProvider = Provider.of<ImageUploadProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0.0,
        title: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            InkWell(
              splashColor: Colors.white,
              child: Row(
                //Inkwell
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white,),
                  ),
                  CircleAvatar(backgroundImage: widget.receiver.profileurl!=null? NetworkImage(widget.receiver.profileurl): AssetImage('assets/images/user.png'), radius: 20,),
                ],
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            InkWell(
              splashColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(left:8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('${widget.receiver.name}',style: TextStyle(fontSize: 18),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left:1),
                      child: Text('11:20 PM',style: TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {
                //USer Profile
              },
            )
          ],
        ),
        actions: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.videocam),
                  onPressed: () async =>
                  await Permissions.cameraAndMicrophonePermissionsGranted()
                      ? CallUtils.dial(
                    from: sender,
                    to: widget.receiver,
                    context: context,
                  ):{},
              ),
              IconButton(
                icon: Icon(Icons.phone),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.more_vert),
                onPressed: () {},
              ),
            ],
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: messageList(),
          ),
          _imageUploadProvider.getViewState == ViewState.LOADING
              ? Container(
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(right: 15),
            child: CircularProgressIndicator(),
          )
              : Container(),
          chatControls(),
          showEmojiPicker ? Container(child: emojiContainer()) : Container(),
        ],
      ),
    );
  }

  emojiContainer() {
    return EmojiPicker(
      bgColor: Colors.white10,
      indicatorColor: Colors.lightBlue,
      rows: 4,
      columns: 10,
      onEmojiSelected: (emoji, category) {
        setState(() {
          isWriting = true;
        });

        textFieldController.text = textFieldController.text + emoji.emoji;
      },
      recommendKeywords: ["face", "happy", "party", "sad"],
      numRecommended: 50,
    );
  }

  getMessage(Message message) {

    return message.type == MESSAGE_TYPE_IMAGE
        ? InkWell(child: Hero(tag: "imageView", child: CachedImage(message.photoUrl)), onTap: (){viewImage(context, message.photoUrl);})
        : message.type == MESSAGE_TYPE_DOC? Text(
          'DOCUMENT',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.0,
          ),
        )
        : Text(
              message.message,
              style: TextStyle(
              color: Colors.black,
              fontSize: 16.0,
          ));
  }

  void pickImage({@required ImageSource source}) async {
    File selectedImage = await Utils.pickImage(source: source);
    _repository.uploadImage(
        image: selectedImage,
        receiverId: widget.receiver.uid,
        senderId: _currentUserId,
        imageUploadProvider: _imageUploadProvider);
  }

  void openFileExplorer() async {
    try {
      _path = null;
      _path = await FilePicker.getFilePath(
            type: FileType.ANY, fileExtension: _extension);
      _repository.uploadDoc(
          doc : File(_path),
          receiverId: widget.receiver.uid,
          senderId: _currentUserId,
          imageUploadProvider: _imageUploadProvider);
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }

    // if (!mounted) return;
  }

  Widget messageList() {
    return StreamBuilder(
      stream: Firestore.instance
          .collection("messages")
          .document(_currentUserId)
          .collection(widget.receiver.uid)
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data == null) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          padding: EdgeInsets.all(10),
          reverse: true,
          controller: _listScrollController,
          itemCount: snapshot.data.documents.length,
          itemBuilder: (context, index) {
            return chatMessageItem(snapshot.data.documents[index]);
          },
        );
      },
    );
  }

  Widget chatMessageItem(DocumentSnapshot snapshot) {
    Message _message = Message.fromMap(snapshot.data);

    return Container(
      child: Container(
        alignment: _message.senderId == _currentUserId
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: _message.senderId == _currentUserId
            ? senderLayout(_message, _message.msgTime)
            : receiverLayout(_message, _message.msgTime),
      ),
    );
  }

  Widget senderLayout(Message message, String msgTime) {
    //Radius messageRadius = Radius.circular(10);

    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      child: Bubble(
        margin: BubbleEdges.only(top: 10),
        alignment: Alignment.topRight,
        nip: BubbleNip.rightTop,
        color: Color.fromRGBO(225, 255, 199, 1.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            getMessage(message),
            Padding(
                padding: EdgeInsets.only(top: 3),
                child: Text(msgTime, style: TextStyle(fontSize: 10, color: Colors.grey))
            )
          ],
        ),
        // getMessage(message),
      ),
    );
  }

  Widget receiverLayout(Message message, String msgTime) {
    //Radius messageRadius = Radius.circular(10);

    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      child: Bubble(
        margin: BubbleEdges.only(top: 10),
        alignment: Alignment.topLeft,
        nip: BubbleNip.leftTop,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            getMessage(message),
            Padding(
              padding: EdgeInsets.only(top: 3),
              child: Text(msgTime, style: TextStyle(fontSize: 10, color: Colors.grey))
            )
          ],
        ),
      ),
    );
  }

  showKeyboard() => textFieldFocus.requestFocus();

  hideKeyboard() => textFieldFocus.unfocus();

  hideEmojiContainer() {
    setState(() {
      showEmojiPicker = false;
    });
  }

  showEmojiContainer() {
    setState(() {
      showEmojiPicker = true;
    });
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
                padding: EdgeInsets.only(top:20, bottom:20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                CircleAvatar(radius: 24 ,backgroundColor: Colors.lightBlue, child: Icon(Icons.image,size: 27, color: Colors.white,)),
                                Padding(
                                    padding: EdgeInsets.only(top:7),
                                    child: Text('Gallery', style: TextStyle(fontSize: 14, color: Colors.black54))),
                              ],
                            ),
                            onTap: (){
                              pickImage(source: ImageSource.gallery);
                            },
                          ),
                          InkWell(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                CircleAvatar(radius: 24 ,backgroundColor: Colors.deepPurpleAccent, child: Icon(Icons.insert_drive_file,size: 27, color: Colors.white,)),
                                Padding(
                                    padding: EdgeInsets.only(top:7),
                                    child: Text('Document', style: TextStyle(fontSize: 14, color: Colors.black54))),
                              ],
                            ),
                            onTap: (){
                              openFileExplorer();
                            },
                          ),
                          InkWell(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                CircleAvatar(radius: 24 ,backgroundColor: Colors.pink, child: Icon(Icons.contacts,size: 27, color: Colors.white,)),
                                Padding(
                                    padding: EdgeInsets.only(top:7),
                                    child: Text('Contact', style: TextStyle(fontSize: 14, color: Colors.black54))),
                              ],
                            ),
                            onTap: (){
                              pickImage(source: ImageSource.gallery);
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                CircleAvatar(radius: 24 ,backgroundColor: Colors.green.shade400, child: Icon(Icons.location_on,size: 27, color: Colors.white,)),
                                Padding(
                                    padding: EdgeInsets.only(top:7),
                                    child: Text('Location', style: TextStyle(fontSize: 14, color: Colors.black54))),
                              ],
                            ),
                            onTap: (){
                              pickImage(source: ImageSource.gallery);
                            },
                          ),
                          InkWell(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                CircleAvatar(radius: 24 ,backgroundColor: Colors.indigoAccent, child: Icon(Icons.add_call,size: 27, color: Colors.white,)),
                                Padding(
                                    padding: EdgeInsets.only(top:7),
                                    child: Text('Meetings', style: TextStyle(fontSize: 14, color: Colors.black54))),
                              ],
                            ),
                            onTap: (){
                              pickImage(source: ImageSource.gallery);
                            },
                          ),
                          InkWell(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                CircleAvatar(radius: 24 ,backgroundColor: Colors.orange, child: Icon(Icons.library_music,size: 27, color: Colors.white,)),
                                Padding(
                                    padding: EdgeInsets.only(top:7),
                                    child: Text('Audio', style: TextStyle(fontSize: 14, color: Colors.black54))),
                              ],
                            ),
                            onTap: (){
                              pickImage(source: ImageSource.gallery);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  Widget chatControls() {
    setWritingTo(bool val) {
      setState(() {
        isWriting = val;
      });
    }

    addMediaModal(context) {
      showModalBottomSheet(
          context: context,
          elevation: 0,
          backgroundColor: Colors.white,
          builder: (context) {
            return Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    children: <Widget>[
                      FlatButton(
                        child: Icon(
                          Icons.close,
                        ),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Content and tools",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView(
                    children: <Widget>[
                      ModalTile(
                        title: "Media",
                        subtitle: "Share Photos and Video",
                        icon: Icons.image,
                        onTap: () => pickImage(source: ImageSource.gallery),
                      ),
                      ModalTile(
                          title: "File",
                          subtitle: "Share files",
                          icon: Icons.tab),
                      ModalTile(
                          title: "Contact",
                          subtitle: "Share contacts",
                          icon: Icons.contacts),
                      ModalTile(
                          title: "Location",
                          subtitle: "Share a location",
                          icon: Icons.add_location),
                      ModalTile(
                          title: "Schedule Call",
                          subtitle: "Arrange a skype call and get reminders",
                          icon: Icons.schedule),
                      ModalTile(
                          title: "Create Poll",
                          subtitle: "Share polls",
                          icon: Icons.poll)
                    ],
                  ),
                ),
              ],
            );
          });
    }

    sendMessage() {
      var text = textFieldController.text;

      Message _message = Message(
        receiverId: widget.receiver.uid,
        senderId: sender.uid,
        message: text,
        timestamp: Timestamp.now(),
        msgTime: DateFormat("H:m").format(DateTime.now()),
        type: 'text',
      );

      setState(() {
        isWriting = false;
      });

      textFieldController.text = "";

      _repository.addMessageToDb(_message, sender, widget.receiver);
    }


    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () => _settingModalBottomSheet(context),
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                gradient: UniversalVariables.fabGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, color: Colors.white,),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                TextField(
                  controller: textFieldController,
                  focusNode: textFieldFocus,
                  onTap: () => hideEmojiContainer(),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  onChanged: (val) {
                    (val.length > 0 && val.trim() != "")
                        ? setWritingTo(true)
                        : setWritingTo(false);
                  },
                  decoration: InputDecoration(
                    hintText: "Type a message",
                    hintStyle: TextStyle(
                      color: UniversalVariables.greyColor,
                    ),
                    border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(50.0),
                        ),
                        borderSide: BorderSide.none),
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    filled: true,
                    fillColor: UniversalVariables.separatorColor,
                  ),
                ),
                IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: () {
                    if (!showEmojiPicker) {
                      // keyboard is visible
                      hideKeyboard();
                      showEmojiContainer();
                    } else {
                      //keyboard is hidden
                      showKeyboard();
                      hideEmojiContainer();
                    }
                  },
                  icon: Icon(Icons.face, color: Colors.white,),
                ),
              ],
            ),
          ),
          isWriting
              ? Container()
              : Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.record_voice_over, color: Colors.lightBlue,),
          ),
          isWriting
              ? Container()
              : GestureDetector(
            child: Icon(Icons.camera_alt, color: Colors.lightBlue,),
            onTap: () => pickImage(source: ImageSource.camera),
          ),
          isWriting
              ? Container(
              margin: EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                  gradient: UniversalVariables.fabGradient,
                  shape: BoxShape.circle),
              child: IconButton(
                icon: Icon(
                  Icons.send,
                  size: 15,
                  color: Colors.white,
                ),
                onPressed: () => sendMessage(),
              ))
              : Container()
        ],
      ),
    );
  }

  void viewImage(BuildContext context, String photoUrl) {
    Navigator.of(context).push(MaterialPageRoute(
      builder:(context) => Scaffold(
        body: Center(
          child: Hero(
            child: CachedImage(photoUrl),
          ),
        )
      ),
    ));
  }
}

class ModalTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Function onTap;

  const ModalTile({
    @required this.title,
    @required this.subtitle,
    @required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: CustomTile(
        mini: false,
        onTap: onTap,
        leading: Container(
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.lightBlue,
          ),
          padding: EdgeInsets.all(10),
          child: Icon(
            icon,
            color: Colors.white,
            size: 38,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}