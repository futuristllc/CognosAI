import 'package:cognos/models/user.dart';
import 'package:cognos/resources/firebase_repository.dart';
import 'package:flutter/widgets.dart';

class UserProvider with ChangeNotifier {
  User _user;
  FirebaseRepository _firebaseRepository = FirebaseRepository();

  User get getUser => _user;

  void refreshUser() async {
    User user = await _firebaseRepository.getUserDetails();
    _user = user;
    notifyListeners();
  }

}