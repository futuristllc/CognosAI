import 'package:cognos/models/userlist.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileView extends StatefulWidget {

  final UserList receiver;

  ProfileView({this.receiver});

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {

  bool _pinned = true;
  bool _snap = false;
  bool _floating = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
            stretch: true,
            onStretchTrigger: () {
              // Function callback for stretch
              return;
            },
            expandedHeight: 300.0,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: <StretchMode>[
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
                StretchMode.fadeTitle,
              ],
              centerTitle: true,
              title: Container(  //HERE...
                padding: const EdgeInsets.all(0),
                child: Text(
                  widget.receiver.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  widget.receiver.profileurl != null ?
                  Image.network(
                    widget.receiver.profileurl,
                    fit: BoxFit.cover,
                  ):
                  AssetImage('assets/images/user.png'),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(0.0, 0.5),
                        end: Alignment(0.0, 0.0),
                        colors: <Color>[
                          Color(0x60000000),
                          Color(0x00000000),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock, color: Colors.lightBlue, size: 15,
                      ),
                      Text(
                        ' Chats are encrypted end to end ',
                        style: TextStyle(color: Colors.blue, fontSize: 15),
                      ),
                    ],
                  ),
                )
              ),
              Padding(
                padding: EdgeInsets.only(left: 15, right: 15, bottom: 20, top: 5),
                child: Card(
                  elevation: 2,
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
                          title: Text('About', style: TextStyle(fontSize: 15, color: Colors.grey, ),),
                          subtitle: Text(
                            widget.receiver.about,
                            style: TextStyle(fontSize: 15, color: Colors.lightBlue),
                            ),
                          ),
                        ),
                      Divider(indent: 16, endIndent: 16, thickness: 1,),
                      Padding(
                        padding: EdgeInsets.only(top: 14),
                        child: ListTile(
                          leading: Icon(Icons.phone, color: Colors.lightBlue,),
                          title: Text('Phone', style: TextStyle(fontSize: 15, color: Colors.grey, ),),
                          subtitle: Text(
                            widget.receiver.phone,
                            style: TextStyle(fontSize: 15, color: Colors.lightBlue),
                            ),
                          ),
                      ),
                      ListTile(
                        leading: Icon(Icons.email, color: Colors.lightBlue,),
                        title: Text('Email', style: TextStyle(fontSize: 15, color: Colors.grey, ),),
                        subtitle: Text(widget.receiver.email,
                          style: TextStyle(fontSize: 15, color: Colors.lightBlue),
                        ),
                      ),
                    ],
                  ),
                ),
              ),),
              Padding(
                padding: EdgeInsets.only(top: 60, bottom: 20),
                child:  Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'COGNOS ',
                      style: GoogleFonts.aldrich(
                        textStyle: TextStyle(color: Colors.lightBlue, letterSpacing: .5, fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                    Text(
                      'by Futurist',
                      style: TextStyle(color: Colors.grey, fontSize: 20),
                    )
                  ],
                ),
              )
              // ListTiles++
            ]),
          ),
        ],
      ),
    );
  }

}
  /*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            leading: Builder(
              builder: (BuildContext context){
                return IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: (){
                      Navigator.pop(context);
                    }
                );
              },
            ),
            pinned: _pinned,
            snap: _snap,
            floating: _floating,
            expandedHeight: 160.0,
            flexibleSpace: const FlexibleSpaceBar(
              title: Text(),
              background: Image(image: NetworkImage(widget.receiver.profileurl.toString()),),
            ),
          ),
          /*const SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child:Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('About'),
              ),
            ),
          ),*/
          //Padding(padding: EdgeInsets.all(8)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 8,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('About',
                        style: TextStyle(
                          color: Colors.blueAccent
                        ),
                      ),
                      Text('AKM',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20
                        ),
                      )
                    ],
                  )
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Card(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Phone Number and Email',
                          style: TextStyle(
                              color: Colors.blueAccent
                          ),
                        ),
                        Padding(padding: EdgeInsets.all(10)),
                        Text('8879437588',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20
                          ),
                        ),
                        Text('Mobile',
                          style: TextStyle(color: Colors.black38),
                        ),
                        Divider(),
                        Text('swapnilathavale1999@gmail.com',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18
                          ),
                        ),
                        Text('Email',
                          style: TextStyle(color: Colors.black38),
                        ),
                        Padding(padding: EdgeInsets.all(8))
                      ],
                    )
                ),
              ),
            ),
          ),
          /*SliverList(
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                return Container(
                  color: index.isOdd ? Colors.white : Colors.black12,
                  height: 100.0,
                  child: Center(
                    child: Text('$index', textScaleFactor: 5),
                  ),
                );
              },
              childCount: 1,
            ),
          ),*/
        ],
      ),
      /*bottomNavigationBar: BottomAppBar(
        child: ButtonBar(
          alignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Text('pinned'),
                Switch(
                  onChanged: (bool val) {
                    setState(() {
                      _pinned = val;
                    });
                  },
                  value: _pinned,
                ),
              ],
            ),
            Row(
              children: <Widget>[
                const Text('snap'),
                Switch(
                  onChanged: (bool val) {
                    setState(() {
                      _snap = val;
                      // Snapping only applies when the app bar is floating.
                      _floating = _floating || _snap;
                    });
                  },
                  value: _snap,
                ),
              ],
            ),
            Row(
              children: <Widget>[
                const Text('floating'),
                Switch(
                  onChanged: (bool val) {
                    setState(() {
                      _floating = val;
                      _snap = _snap && _floating;
                    });
                  },
                  value: _floating,
                ),
              ],
            ),
          ],
        ),
      )*/
    );
  }
}
*/