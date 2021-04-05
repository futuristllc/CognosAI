import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognos/models/calls_data.dart';
import 'package:cognos/const/strings.dart';
import 'package:cognos/models/voice_call.dart';

class VoiceCallMethods {
  final CollectionReference callCollection =
  Firestore.instance.collection(CALL_COLLECTION);

  Stream<DocumentSnapshot> vcallStream({String uid}) =>
      callCollection.document(uid).snapshots();

  Future<bool> vmakeCall({Voice voice}) async {
    try {
      voice.hasDialled = true;
      Map<String, dynamic> hasDialledMap = voice.toMap(voice);

      voice.hasDialled = false;
      Map<String, dynamic> hasNotDialledMap = voice.toMap(voice);

      await callCollection.document(voice.callerId).setData(hasDialledMap);
      await callCollection.document(voice.receiverId).setData(hasNotDialledMap);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> vendCall({Voice voice}) async {
    try {
      await callCollection.document(voice.callerId).delete();
      await callCollection.document(voice.receiverId).delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}