import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ChatStarted extends ChatEvent {
  const ChatStarted();
}

class ChatMessageSent extends ChatEvent {
  final String text;

  const ChatMessageSent({required this.text});

  @override
  List<Object?> get props => [text];
}

class ChatHistoryCleared extends ChatEvent {
  const ChatHistoryCleared();
}