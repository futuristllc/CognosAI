import 'dart:io';
import 'package:cognos/image_provider/image_upload_provider.dart';
import 'package:cognos/models/user.dart';
import 'package:cognos/models/userlist.dart';
import 'package:cognos/screens/chatscreen/messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cognos/resources/firebase_methods.dart';
import 'package:flutter/material.dart';
import 'package:cognos/models/calls_data.dart';

class FirebaseRepository {
  FirebaseMethods _firebaseMethods = FirebaseMethods();

  Future<FirebaseUser> getCurrentUser() => _firebaseMethods.getCurrentUser();

  Future<FirebaseUser> signIn() => _firebaseMethods.signIn();

  Future<bool> authenticateUser(FirebaseUser user) =>
      _firebaseMethods.authenticateUser(user);

  Future<void> addDataToDb(FirebaseUser user) =>
      _firebaseMethods.addDataToDb(user);

  ///responsible for signing out
  Future<void> signOut() => _firebaseMethods.signOut();

  Future<User> getUserDetails() => _firebaseMethods.getUserDetails();

  Future<List<UserList>> fetchAllUsers(FirebaseUser user) =>
      _firebaseMethods.fetchAllUsers(user);

  Future<void> addMessageToDb(Message message, UserList sender, UserList receiver) =>
      _firebaseMethods.addMessageToDb(message, sender, receiver);

  Future<String> uploadImageToStorage(File imageFile) =>
      _firebaseMethods.uploadImageToStorage(imageFile);

  Future<String> uploadDocToStorage(File doc) =>
      _firebaseMethods.uploadDocToStorage(doc);

  // void showLoading(String receiverId, String senderId) =>
  //     _firebaseMethods.showLoading(receiverId, senderId);

  // void hideLoading(String receiverId, String senderId) =>
  //     _firebaseMethods.hideLoading(receiverId, senderId);

  void uploadImageMsgToDb(String url, String receiverId, String senderId) =>
      _firebaseMethods.setImageMsg(url, receiverId, senderId);

  void uploadDocMsgToDb(String url, String receiverId, String senderId) =>
      _firebaseMethods.setDocMsg(url, receiverId, senderId);

  void uploadImage({
    @required File image,
    @required String receiverId,
    @required String senderId,
    @required ImageUploadProvider imageUploadProvider
  }) =>
      _firebaseMethods.uploadImage(image, receiverId, senderId, imageUploadProvider);

  void uploadDoc({
    @required File doc,
    @required String receiverId,
    @required String senderId,
    @required ImageUploadProvider imageUploadProvider,
  }) =>
      _firebaseMethods.uploadDoc(doc, receiverId, senderId, imageUploadProvider);
}
