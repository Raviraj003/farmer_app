

import 'package:cloud_firestore/cloud_firestore.dart';

class Message {

  String senderUid;
  String receiverUid;
  String titleIsId;
  String message;
  FieldValue timestamp;
  String photoUrl;

  Message({this.senderUid, this.receiverUid, this.titleIsId, this.message, this.timestamp});
  Message.withoutMessage({this.senderUid, this.receiverUid, this.titleIsId, this.timestamp, this.photoUrl});

  Map toMap() {
    var map = Map<String, dynamic>();
    map['senderUid'] = this.senderUid;
    map['receiverUid'] = this.receiverUid;
    map['titleIsId'] = this.titleIsId;
    map['message'] = this.message;
    map['timestamp'] = this.timestamp;
    return map;
  }

  Message fromMap(Map<String, dynamic> map) {
    Message _message = Message();
    _message.senderUid = map['senderUid'];
    _message.receiverUid = map['receiverUid'];
    _message.titleIsId = map['titleIsId'];
    _message.message = map['message'];
    _message.timestamp = map['timestamp'];
    return _message;
  }



}