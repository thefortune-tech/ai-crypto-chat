import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/get_chat_history_usecase.dart';
import '../../domain/usecases/save_message_usecase.dart';
import '../../domain/usecases/clear_history_usecase.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendMessageUseCase sendMessageUseCase;
  final GetChatHistoryUseCase getChatHistoryUseCase;
  final SaveMessageUseCase saveMessageUseCase;
  final ClearHistoryUseCase clearHistoryUseCase;
  final Uuid uuid;

  ChatBloc({
    required this.sendMessageUseCase,
    required this.getChatHistoryUseCase,
    required this.saveMessageUseCase,
    required this.clearHistoryUseCase,
    required this.uuid,
  }) : super(const ChatInitial()) {
    on<ChatStarted>(_onChatStarted);
    on<ChatMessageSent>(_onChatMessageSent);
    on<ChatHistoryCleared>(_onChatHistoryCleared);
  }

  Future<void> _onChatStarted(
    ChatStarted event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());

    final result = await getChatHistoryUseCase();

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (messages) => emit(ChatLoaded(messages: messages)),
    );
  }

  Future<void> _onChatMessageSent(
    ChatMessageSent event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    final userMessage = ChatMessage(
      id: uuid.v4(),
      content: event.text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final updatedMessages = [...currentState.messages, userMessage];
    emit(currentState.copyWith(messages: updatedMessages, isSending: true));

    await saveMessageUseCase(userMessage);

    final aiResult = await sendMessageUseCase(event.text, currentState.messages);

    await aiResult.fold(
      (failure) async {
        emit(currentState.copyWith(
          messages: updatedMessages,
          isSending: false,
        ));
      },
      (replyText) async {
        final aiMessage = ChatMessage(
          id: uuid.v4(),
          content: replyText,
          isUser: false,
          timestamp: DateTime.now(),
        );

        await saveMessageUseCase(aiMessage);

        emit(currentState.copyWith(
          messages: [...updatedMessages, aiMessage],
          isSending: false,
        ));
      },
    );
  }

  Future<void> _onChatHistoryCleared(
    ChatHistoryCleared event,
    Emitter<ChatState> emit,
  ) async {
    final result = await clearHistoryUseCase();

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (_) => emit(const ChatLoaded(messages: [])),
    );
  }
}