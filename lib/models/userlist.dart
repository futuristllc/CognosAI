class UserList {
  String uid;
  String name;
  String email;
  String phone;
  String about;
  String profileurl;
  String lastTime;
  String state;

  UserList({
    this.uid,
    this.name,
    this.email,
    this.phone,
    this.about,
    this.profileurl,
    this.lastTime,
    this.state,
  });

  // Named constructor
  UserList.fromMap(Map<String, dynamic> mapData) {
    this.uid = mapData['uid'];
    this.name = mapData['name'];
    this.email = mapData['email'];
    this.about = mapData['about'];
    this.phone = mapData['phone'];
    this.profileurl = mapData['profileurl'];
    this.lastTime = mapData['lastTime'];
    this.state = mapData['state'];
  }
}
