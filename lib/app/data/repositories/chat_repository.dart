import '../providers/chat_provider.dart';

class ChatRepository {
  final ChatProvider _chatProvider;

  ChatRepository(this._chatProvider);



  /// Fetch message history for a specific chat/receiver.
  Future<List<dynamic>> getChatMessages(String receiverId) async {
    return await _chatProvider.getChatMessages(receiverId);
  }


}
