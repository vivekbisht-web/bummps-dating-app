import '../models/user_profile.dart';
import '../providers/chat_provider.dart';

class ChatRepository {
  final ChatProvider _chatProvider;

  ChatRepository(this._chatProvider);

  /// Fetch active conversations inbox
  Future<List<dynamic>> getInbox() async {
    return await _chatProvider.getInbox();
  }

  /// Fetch mutual matches list
  Future<List<UserProfile>> getChatMatches() async {
    return await _chatProvider.getChatMatches();
  }

  /// Fetch chat history with a specific user/conversation
  Future<List<Map<String, dynamic>>> getChatHistory(String targetId) async {
    return await _chatProvider.getChatHistory(targetId);
  }
}
