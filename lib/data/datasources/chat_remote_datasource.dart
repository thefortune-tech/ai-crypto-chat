import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_message_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatMessageModel>> getChatHistory();
  Future<void> saveMessage(ChatMessageModel message);
  Future<void> clearHistory();
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  ChatRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  String get _userId {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _messagesRef => firestore
      .collection('users')
      .doc(_userId)
      .collection('messages');

  @override
  Future<List<ChatMessageModel>> getChatHistory() async {
    try {
      final snapshot = await _messagesRef.orderBy('timestamp').get();
      return snapshot.docs
          .map((doc) => ChatMessageModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch chat history: $e');
    }
  }

  @override
  Future<void> saveMessage(ChatMessageModel message) async {
    try {
      await _messagesRef.doc(message.id).set(message.toFirestore());
    } catch (e) {
      throw Exception('Failed to save message: $e');
    }
  }

  @override
  Future<void> clearHistory() async {
    try {
      final snapshot = await _messagesRef.get();
      final batch = firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to clear history: $e');
    }
  }
}