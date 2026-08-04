
import '../../core/services/network/dio_client.dart';

class ChatProvider {
  final DioClient _dioClient;

  ChatProvider(this._dioClient);


  /// Fetch message history for a specific chat/receiver.
  Future<List<dynamic>> getChatMessages(String receiverId) async {
    return await _dioClient.get<List<dynamic>>(
      'chat/$receiverId/messages',
      fromJson: (json) {
        if (json is List) return json;
        if (json is Map && json.containsKey('messages')) {
          return json['messages'] is List ? json['messages'] as List : [];
        }
        if (json is Map && json.containsKey('data')) {
          return json['data'] is List ? json['data'] as List : [];
        }
        return [];
      },
    );
  }


}
