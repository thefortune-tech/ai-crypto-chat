import 'package:hive_flutter/hive_flutter.dart';
import '../models/chat_message_model.dart';

abstract class ChatLocalDataSource {
  Future<List<ChatMessageModel>> getCachedMessages();
  Future<void> cacheMessages(List<ChatMessageModel> messages);
  Future<void> cacheSingleMessage(ChatMessageModel message);
  Future<void> clearCachedMessages();
}

class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  static const String boxName = 'chat_messages_box';

  Future<Box> _openBox() async {
    return await Hive.openBox(boxName);
  }

  @override
  Future<List<ChatMessageModel>> getCachedMessages() async {
    final box = await _openBox();
    final List<ChatMessageModel> messages = [];

    for (var key in box.keys) {
      final raw = box.get(key);
      if (raw != null) {
        final json = Map<String, dynamic>.from(raw as Map);
        messages.add(ChatMessageModel.fromJson(json));
      }
    }

    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return messages;
  }

  @override
  Future<void> cacheMessages(List<ChatMessageModel> messages) async {
    final box = await _openBox();
    await box.clear();

    for (var message in messages) {
      await box.put(message.id, message.toJson());
    }
  }

  @override
  Future<void> cacheSingleMessage(ChatMessageModel message) async {
    final box = await _openBox();
    await box.put(message.id, message.toJson());
  }

  @override
  Future<void> clearCachedMessages() async {
    final box = await _openBox();
    await box.clear();
  }
}