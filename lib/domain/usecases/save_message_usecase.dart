import 'package:fpdart/fpdart.dart';
import '../../core/error/failures.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

class SaveMessageUseCase {
  final ChatRepository repository;
  SaveMessageUseCase(this.repository);

  Future<Either<Failure, Unit>> call(ChatMessage message) async {
    return await repository.saveMessage(message);
  }
}