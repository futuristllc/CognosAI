class Voice {
  String callerId;
  String callerName;
  String callerPic;
  String receiverId;
  String receiverName;
  String receiverPic;
  String channelId;
  bool hasDialled;
  String type;

  Voice({
    this.callerId,
    this.callerName,
    this.callerPic,
    this.receiverId,
    this.receiverName,
    this.receiverPic,
    this.channelId,
    this.hasDialled,
    this.type,
  });

  // to map
  Map<String, dynamic> toMap(Voice voice) {
    Map<String, dynamic> voiceMap = Map();
    voiceMap["caller_id"] = voice.callerId;
    voiceMap["caller_name"] = voice.callerName;
    voiceMap["caller_pic"] = voice.callerPic;
    voiceMap["receiver_id"] = voice.receiverId;
    voiceMap["receiver_name"] = voice.receiverName;
    voiceMap["receiver_pic"] = voice.receiverPic;
    voiceMap["channel_id"] = voice.channelId;
    voiceMap["has_dialled"] = voice.hasDialled;
    voiceMap["type"] = "VOICE";
    return voiceMap;
  }

  Voice.fromMap(Map voiceMap) {
    this.callerId = voiceMap["caller_id"];
    this.callerName = voiceMap["caller_name"];
    this.callerPic = voiceMap["caller_pic"];
    this.receiverId = voiceMap["receiver_id"];
    this.receiverName = voiceMap["receiver_name"];
    this.receiverPic = voiceMap["receiver_pic"];
    this.channelId = voiceMap["channel_id"];
    this.hasDialled = voiceMap["has_dialled"];
    this.type = voiceMap["type"];
  }
}