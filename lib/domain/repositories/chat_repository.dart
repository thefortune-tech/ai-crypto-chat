import 'package:fpdart/fpdart.dart';
import '../../core/error/failures.dart';
import '../entities/chat_message.dart';

abstract class ChatRepository {
  Future<Either<Failure, String>> sendMessage(
    String message,
    List<ChatMessage> history,
  );
  Future<Either<Failure, List<ChatMessage>>> getChatHistory();
  Future<Either<Failure, Unit>> saveMessage(ChatMessage message);
  Future<Either<Failure, Unit>> clearHistory();
}