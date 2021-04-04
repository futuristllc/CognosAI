class UserList {
  String uid;
  String name;
  String email;
  String phone;
  String about;
  String profileurl;

  UserList({
    this.uid,
    this.name,
    this.email,
    this.phone,
    this.about,
    this.profileurl,
  });

  // Named constructor
  UserList.fromMap(Map<String, dynamic> mapData) {
    this.uid = mapData['uid'];
    this.name = mapData['name'];
    this.email = mapData['email'];
    this.about = mapData['about'];
    this.phone = mapData['phone'];
    this.profileurl = mapData['profileurl'];
  }
}
