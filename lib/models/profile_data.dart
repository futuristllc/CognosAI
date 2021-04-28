import 'package:firebase_database/firebase_database.dart';

class Profile {
  String _uname;
  String _phone;
  String _email;
  String _profileUrl;
  String _lastTime;
  String _state;

  Profile(this._uname, this._phone, this._email, this._profileUrl);

  Profile.map(dynamic obj) {
    this._uname = obj['uname'];
    this._phone = obj['phone'];
    this._email = obj['email'];
    this._profileUrl = obj['profileurl'];
    this._lastTime = obj['lastTime'];
    this._state = obj['state'];
  }

  String get uname => _uname;
  String get phone => _phone;
  String get email => _email;
  String get profileurl => _profileUrl;
  String get lastTime => _lastTime;
  String get state => _state;

  Profile.fromSnapshot(DataSnapshot snapshot) {
    _uname = snapshot.value['uname'];
    _phone = snapshot.value['phone'];
    _email = snapshot.value['email'];
    _profileUrl = snapshot.value['profileurl'];
    _lastTime = snapshot.value['lastTime'];
    _state = snapshot.value['state'];

  }


}