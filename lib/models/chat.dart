import 'package:firebase/models/message.dart';

class Chat {
  String? id;
  List<String>? participants;
  List<Message>? messages;
  Chat({
    required this.id,
    required this.messages,
    required this.participants,
  });
  Chat.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    participants = List<String>.from(json['participants']);
    if (json['messages'] != null) {
      messages = List<Message>.from(
        json['messages'].map((m) => Message.fromJson(m)),
      );
    }
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['participants'] = participants;
    data['messages'] = messages?.map((m) => m.toJson());

    return data;
  }
}
