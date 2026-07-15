import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/di/injection_container.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/error_view.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ChatBloc>()..add(const ChatStarted()),
      child: const _ChatView(),
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView();

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          AppStrings.appName,
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.whiteMuted),
            onPressed: () {
              context.read<ChatBloc>().add(const ChatHistoryCleared());
            },
          ),
        ],
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatLoaded) {
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          if (state is ChatLoading || state is ChatInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }

          if (state is ChatError) {
            return ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<ChatBloc>().add(const ChatStarted()),
            );
          }

          final chatState = state as ChatLoaded;

          return Column(
            children: [
              Expanded(
                child: chatState.messages.isEmpty
                    ? const Center(
                        child: Text(
                          'Ask me anything about crypto',
                          style: TextStyle(color: AppColors.whiteMuted),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: chatState.messages.length,
                        itemBuilder: (context, index) => ChatBubble(
                          message: chatState.messages[index],
                        ),
                      ),
              ),
              ChatInput(
                isSending: chatState.isSending,
                onSend: (text) {
                  context.read<ChatBloc>().add(ChatMessageSent(text: text));
                },
              ),
            ],
          );
        },
      ),
    );
  }
}