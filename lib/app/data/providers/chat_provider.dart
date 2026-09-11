import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/network/dio_client.dart';
import '../models/user_profile.dart';

class ChatProvider {
  final DioClient _dioClient;

  ChatProvider(this._dioClient);

  /// Fetch active conversations inbox — GET /api/chats/inbox
  Future<List<dynamic>> getInbox() async {
    return await _dioClient.get<List<dynamic>>(
      AppConstants.chatInbox,
      fromJson: (json) {
        return _parseListPayload(json);
      },
    );
  }

  /// Fetch mutual matches list — GET /api/chats/matches
  Future<List<UserProfile>> getChatMatches() async {
    return await _dioClient.get<List<UserProfile>>(
      AppConstants.chatMatches,
      fromJson: (json) {
        return _parseUserProfileList(json);
      },
    );
  }

  /// Fetch chat history with a specific user/conversation — GET /api/chats/history/:id
  Future<List<Map<String, dynamic>>> getChatHistory(String targetId) async {
    return await _dioClient.get<List<Map<String, dynamic>>>(
      '${AppConstants.chatHistory}/$targetId',
      fromJson: (json) {
        return _parseMessageHistory(json);
      },
    );
  }

  // --- Helpers for parsing various backend response shapes ---

  List<dynamic> _parseListPayload(dynamic json) {
    if (json == null) return [];
    if (json is String) {
      try {
        json = jsonDecode(json);
      } catch (e) {
        debugPrint('[ChatProvider] JSON decode error in _parseListPayload: $e');
        return [];
      }
    }

    if (json is List) {
      return json;
    }

    if (json is Map) {
      if (json['data'] is List) return json['data'];
      if (json['chats'] is List) return json['chats'];
      if (json['inbox'] is List) return json['inbox'];
      if (json['conversations'] is List) return json['conversations'];
      if (json['results'] is List) return json['results'];
      if (json['matches'] is List) return json['matches'];
      if (json['chat'] != null) return [json['chat']];
    }

    return [];
  }

  List<UserProfile> _parseUserProfileList(dynamic json) {
    if (json == null) return [];
    if (json is String) {
      try {
        json = jsonDecode(json);
      } catch (e) {
        debugPrint('[ChatProvider] JSON decode error in _parseUserProfileList: $e');
        return [];
      }
    }

    List<dynamic> rawList = [];
    if (json is List) {
      rawList = json;
    } else if (json is Map) {
      if (json['data'] is List) {
        rawList = json['data'];
      } else if (json['matches'] is List) {
        rawList = json['matches'];
      } else if (json['users'] is List) {
        rawList = json['users'];
      } else if (json['profiles'] is List) {
        rawList = json['profiles'];
      }
    }

    return rawList
        .where((item) => item != null && item is Map)
        .map((item) {
          final map = Map<String, dynamic>.from(item as Map);
          if (map['user'] is Map) {
            return UserProfile.fromJson(Map<String, dynamic>.from(map['user'] as Map));
          }
          if (map['participant'] is Map) {
            return UserProfile.fromJson(Map<String, dynamic>.from(map['participant'] as Map));
          }
          if (map['matchedUser'] is Map) {
            return UserProfile.fromJson(Map<String, dynamic>.from(map['matchedUser'] as Map));
          }
          return UserProfile.fromJson(map);
        })
        .toList();
  }

  List<Map<String, dynamic>> _parseMessageHistory(dynamic json) {
    if (json == null) return [];
    if (json is String) {
      try {
        json = jsonDecode(json);
      } catch (e) {
        debugPrint('[ChatProvider] JSON decode error in _parseMessageHistory: $e');
        return [];
      }
    }

    List<dynamic> rawList = [];
    if (json is List) {
      rawList = json;
    } else if (json is Map) {
      if (json['data'] is List) {
        rawList = json['data'];
      } else if (json['messages'] is List) {
        rawList = json['messages'];
      } else if (json['history'] is List) {
        rawList = json['history'];
      } else if (json['chat'] is Map && json['chat']['messages'] is List) {
        rawList = json['chat']['messages'];
      }
    }

    return rawList
        .where((item) => item != null && item is Map)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }
}
