import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.content,
    required super.isUser,
    required super.timestamp,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      content: json['content'] as String,
      isUser: json['isUser'] as bool,
      timestamp: json['timestamp'] is Timestamp
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory ChatMessageModel.fromEntity(ChatMessage message) {
    return ChatMessageModel(
      id: message.id,
      content: message.content,
      isUser: message.isUser,
      timestamp: message.timestamp,
    );
  }
}