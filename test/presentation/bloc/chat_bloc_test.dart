import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import 'package:ai_crypto_chat/core/error/failures.dart';
import 'package:ai_crypto_chat/domain/entities/chat_message.dart';
import 'package:ai_crypto_chat/domain/usecases/send_message_usecase.dart';
import 'package:ai_crypto_chat/domain/usecases/get_chat_history_usecase.dart';
import 'package:ai_crypto_chat/domain/usecases/save_message_usecase.dart';
import 'package:ai_crypto_chat/domain/usecases/clear_history_usecase.dart';
import 'package:ai_crypto_chat/presentation/bloc/chat_bloc.dart';
import 'package:ai_crypto_chat/presentation/bloc/chat_event.dart';
import 'package:ai_crypto_chat/presentation/bloc/chat_state.dart';

class MockSendMessageUseCase extends Mock implements SendMessageUseCase {}
class MockGetChatHistoryUseCase extends Mock implements GetChatHistoryUseCase {}
class MockSaveMessageUseCase extends Mock implements SaveMessageUseCase {}
class MockClearHistoryUseCase extends Mock implements ClearHistoryUseCase {}
class MockUuid extends Mock implements Uuid {}

void main() {
  late MockSendMessageUseCase mockSendMessage;
  late MockGetChatHistoryUseCase mockGetChatHistory;
  late MockSaveMessageUseCase mockSaveMessage;
  late MockClearHistoryUseCase mockClearHistory;
  late MockUuid mockUuid;

  setUpAll(() {
    registerFallbackValue( ChatMessage(
      id: 'fallback',
      content: 'fallback',
      isUser: true,
      timestamp: DateTime.now()
    ));
  });

  setUp(() {
    mockSendMessage = MockSendMessageUseCase();
    mockGetChatHistory = MockGetChatHistoryUseCase();
    mockSaveMessage = MockSaveMessageUseCase();
    mockClearHistory = MockClearHistoryUseCase();
    mockUuid = MockUuid();
    when(() => mockUuid.v4()).thenReturn('test-uuid');
  });

  ChatBloc buildBloc() => ChatBloc(
        sendMessageUseCase: mockSendMessage,
        getChatHistoryUseCase: mockGetChatHistory,
        saveMessageUseCase: mockSaveMessage,
        clearHistoryUseCase: mockClearHistory,
        uuid: mockUuid,
      );

  group('ChatStarted', () {
    blocTest<ChatBloc, ChatState>(
      'emits [ChatLoading, ChatLoaded] when history loads successfully',
      build: () {
        when(() => mockGetChatHistory())
            .thenAnswer((_) async => const Right(<ChatMessage>[]));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ChatStarted()),
      expect: () => [
        const ChatLoading(),
        const ChatLoaded(messages: []),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'emits [ChatLoading, ChatError] when history load fails',
      build: () {
        when(() => mockGetChatHistory()).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'fetch failed')),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ChatStarted()),
      expect: () => [
        const ChatLoading(),
        const ChatError(message: 'fetch failed'),
      ],
    );
  });

  group('ChatHistoryCleared', () {
    blocTest<ChatBloc, ChatState>(
      'emits ChatLoaded with empty messages on successful clear',
      build: () {
        when(() => mockClearHistory())
            .thenAnswer((_) async => const Right(unit));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ChatHistoryCleared()),
      expect: () => [const ChatLoaded(messages: [])],
    );
  });
}
