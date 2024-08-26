import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { Text, Image }

class Message {
  String? senderID, content;
  MessageType? messageType;
  Timestamp? sentAt;

  Message({
    required this.content,
    required this.senderID,
    required this.sentAt,
    required this.messageType,
  });
  Message.fromJson(Map<String, dynamic> json) {
    senderID = json['senderID'];
    content = json['content'];
    messageType = MessageType.values.byName(json['messageType']);
    sentAt = json['sentAt'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['senderID'] = senderID;
    data['content'] = content;
    data['sentAt'] = sentAt;
    data['messageType'] = messageType!.name;
    return data;
  }
}
