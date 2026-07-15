import 'package:fpdart/fpdart.dart';
import '../../core/error/failures.dart';
import '../repositories/chat_repository.dart';

class ClearHistoryUseCase {
  final ChatRepository repository;
  ClearHistoryUseCase(this.repository);

  Future<Either<Failure, Unit>> call() async {
    return await repository.clearHistory();
  }
}