import 'package:fpdart/fpdart.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/ai_remote_datasource.dart';
import '../datasources/chat_remote_datasource.dart';
import '../datasources/chat_local_datasource.dart';
import '../models/chat_message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final AiRemoteDataSource aiRemoteDataSource;
  final ChatRemoteDataSource chatRemoteDataSource;
  final ChatLocalDataSource chatLocalDataSource;

  ChatRepositoryImpl({
    required this.aiRemoteDataSource,
    required this.chatRemoteDataSource,
    required this.chatLocalDataSource,
  });

  @override
  Future<Either<Failure, String>> sendMessage(
    String message,
    List<ChatMessage> history,
  ) async {
    try {
      final reply = await aiRemoteDataSource.generateReply(message, history);
      return Right(reply);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getChatHistory() async {
    try {
      final remoteMessages = await chatRemoteDataSource.getChatHistory();
      await chatLocalDataSource.cacheMessages(remoteMessages);
      return Right(remoteMessages);
    } catch (e) {
      try {
        final cachedMessages = await chatLocalDataSource.getCachedMessages();
        if (cachedMessages.isNotEmpty) {
          return Right(cachedMessages);
        }
        return Left(ServerFailure(message: e.toString()));
      } catch (cacheError) {
        return Left(CacheFailure(message: cacheError.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, Unit>> saveMessage(ChatMessage message) async {
    final model = ChatMessageModel.fromEntity(message);

    try {
      await chatLocalDataSource.cacheSingleMessage(model);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }

    try {
      await chatRemoteDataSource.saveMessage(model);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }

    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> clearHistory() async {
    try {
      await chatRemoteDataSource.clearHistory();
      await chatLocalDataSource.clearCachedMessages();
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}