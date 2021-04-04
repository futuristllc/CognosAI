
class CallModel {
  final String name;
  final String size;
  final String type;
  final String time;
  final String inout;
  final String caller;
  final String receiver;
  final String avatarUrl;
  final String duration;

  CallModel({this.name, this.size, this.type, this.time, this.inout, this.caller, this.receiver, this.avatarUrl, this.duration});
}

List<CallModel> call_list = [
  new CallModel(
    name: 'Elon Musk',
    size: '30 MB',
    type: 'voice',
    time: '27 July, 19:40',
    inout: 'out',
    caller: 'Chaitanya P',
    receiver: 'Elon Musk',
    avatarUrl: 'https://specials-images.forbesimg.com/imageserve/5f1c710f22386e23c26785e2/960x0.jpg?fit=scale',
    duration: '01:50',
  ),
  new CallModel(
    name: 'Jeff Bezos',
    size: '100 MB',
    type: 'voice',
    time: '30 July, 09:40',
    inout: 'miss',
    caller: 'Chaitanya P',
    receiver: 'JEff Bezos',
    avatarUrl: 'https://images.indianexpress.com/2020/07/jeff-bezos-amazon-inc-bloomberg-759.jpg',
    duration: '05:50',
  ),
  new CallModel(
    name: 'Bill Gates',
    size: '30 MB',
    type: 'video',
    time: '27 July, 11:40',
    inout: 'in',
    caller: 'Chaitanya P',
    receiver: 'Bill Gates',
    avatarUrl: 'https://static-ssl.businessinsider.com/image/5b1fd8081ae6623c008b514e-2000/rtx5qu7t.jpg',
    duration: '01:40',
  ),
];