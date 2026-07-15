import 'package:fpdart/fpdart.dart';
import '../../core/error/failures.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

class GetChatHistoryUseCase {
  final ChatRepository repository;
  GetChatHistoryUseCase(this.repository);

  Future<Either<Failure, List<ChatMessage>>> call() async {
    return await repository.getChatHistory();
  }
}