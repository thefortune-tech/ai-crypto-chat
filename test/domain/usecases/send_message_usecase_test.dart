import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ai_crypto_chat/core/error/failures.dart';
import 'package:ai_crypto_chat/domain/entities/chat_message.dart';
import 'package:ai_crypto_chat/domain/repositories/chat_repository.dart';
import 'package:ai_crypto_chat/domain/usecases/send_message_usecase.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late SendMessageUseCase useCase;
  late MockChatRepository mockRepository;

  setUp(() {
    mockRepository = MockChatRepository();
    useCase = SendMessageUseCase(mockRepository);
  });

  const tMessage = 'What is Bitcoin?';
  const tHistory = <ChatMessage>[];
  const tReply = 'Bitcoin is a decentralized cryptocurrency.';

  test('should return AI reply text on success', () async {
    when(() => mockRepository.sendMessage(tMessage, tHistory))
        .thenAnswer((_) async => const Right(tReply));

    final result = await useCase(tMessage, tHistory);

    expect(result, const Right(tReply));
    verify(() => mockRepository.sendMessage(tMessage, tHistory)).called(1);
  });

  test('should return ServerFailure when AI call fails', () async {
    const tFailure = ServerFailure(message: 'Gemini unavailable');
    when(() => mockRepository.sendMessage(tMessage, tHistory))
        .thenAnswer((_) async => const Left(tFailure));

    final result = await useCase(tMessage, tHistory);

    expect(result, const Left(tFailure));
  });
}