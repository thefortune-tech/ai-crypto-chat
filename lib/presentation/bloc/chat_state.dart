import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_message.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  final bool isSending;

  const ChatLoaded({
    required this.messages,
    this.isSending = false,
  });

  ChatLoaded copyWith({
    List<ChatMessage>? messages,
    bool? isSending,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
    );
  }

  @override
  List<Object?> get props => [messages, isSending];
}

class ChatError extends ChatState {
  final String message;

  const ChatError({required this.message});

  @override
  List<Object?> get props => [message];
}