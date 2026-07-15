import 'package:fpdart/fpdart.dart';
import '../../core/error/failures.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;
  SendMessageUseCase(this.repository);

  Future<Either<Failure, String>> call(
    String message,
    List<ChatMessage> history,
  ) async {
    return await repository.sendMessage(message, history);
  }
}