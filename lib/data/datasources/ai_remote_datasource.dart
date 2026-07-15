import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/constants/app_strings.dart';
import '../../domain/entities/chat_message.dart';

abstract class AiRemoteDataSource {
  Future<String> generateReply(String message, List<ChatMessage> history);
}

class AiRemoteDataSourceImpl implements AiRemoteDataSource {
  late final GenerativeModel _model;

  AiRemoteDataSourceImpl() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in .env file');
    }
    _model = GenerativeModel(
      model:'gemini-3.1-flash-lite',
      apiKey: apiKey,
      systemInstruction: Content.system(AppStrings.systemPrompt),
    );
  }

  @override
  Future<String> generateReply(
    String message,
    List<ChatMessage> history,
  ) async {
    try {
      final content = <Content>[];

      for (var msg in history) {
        content.add(
          Content(
            msg.isUser ? 'user' : 'model',
            [TextPart(msg.content)],
          ),
        );
      }

      content.add(Content('user', [TextPart(message)]));

      final response = await _model.generateContent(content);

      final text = response.text;
      if (text == null || text.isEmpty) {
        throw Exception('Gemini returned an empty response');
      }

      return text;
    } catch (e) {
      throw Exception('Failed to generate AI reply: $e');
    }
  }
}