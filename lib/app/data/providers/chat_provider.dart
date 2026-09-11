import 'dart:convert';
import 'package:dio/dio.dart';
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
      options: Options(
        extra: {'suppressGlobalError': true},
      ),
      fromJson: (json) {
        return _parseListPayload(json);
      },
    );
  }

  /// Fetch mutual matches list — GET /api/chats/matches
  Future<List<UserProfile>> getChatMatches() async {
    return await _dioClient.get<List<UserProfile>>(
      AppConstants.chatMatches,
      options: Options(
        extra: {'suppressGlobalError': true},
      ),
      fromJson: (json) {
        return _parseUserProfileList(json);
      },
    );
  }

  /// Fetch chat history with a specific user/conversation — GET /api/chats/history/:id
  Future<List<Map<String, dynamic>>> getChatHistory(String targetId) async {
    return await _dioClient.get<List<Map<String, dynamic>>>(
      '${AppConstants.chatHistory}/$targetId',
      options: Options(
        extra: {'suppressGlobalError': true},
      ),
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
      // 1. Check direct common list keys
      for (final key in ['chats', 'inbox', 'conversations', 'results', 'matches', 'messages', 'chatList', 'docs', 'data']) {
        if (json[key] is List) {
          return json[key] as List<dynamic>;
        }
      }
      // 2. Check nested data map
      if (json['data'] is Map) {
        final nested = json['data'] as Map;
        for (final key in ['chats', 'inbox', 'conversations', 'results', 'matches', 'messages', 'chatList', 'docs', 'data']) {
          if (nested[key] is List) {
            return nested[key] as List<dynamic>;
          }
        }
        for (final val in nested.values) {
          if (val is List) return val;
        }
      }
      // 3. Fallback: check any list value in top-level map
      for (final val in json.values) {
        if (val is List) {
          return val;
        }
      }
      if (json['chat'] != null && json['chat'] is Map) {
        return [json['chat']];
      }
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
      for (final key in ['matches', 'users', 'profiles', 'feed', 'results', 'docs', 'data']) {
        if (json[key] is List) {
          rawList = json[key] as List<dynamic>;
          break;
        }
      }
      if (rawList.isEmpty && json['data'] is Map) {
        final nested = json['data'] as Map;
        for (final key in ['matches', 'users', 'profiles', 'feed', 'results', 'docs', 'data']) {
          if (nested[key] is List) {
            rawList = nested[key] as List<dynamic>;
            break;
          }
        }
        if (rawList.isEmpty) {
          for (final val in nested.values) {
            if (val is List) {
              rawList = val;
              break;
            }
          }
        }
      }
      if (rawList.isEmpty) {
        for (final val in json.values) {
          if (val is List) {
            rawList = val;
            break;
          }
        }
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
          if (map['targetUser'] is Map) {
            return UserProfile.fromJson(Map<String, dynamic>.from(map['targetUser'] as Map));
          }
          if (map['otherUser'] is Map) {
            return UserProfile.fromJson(Map<String, dynamic>.from(map['otherUser'] as Map));
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
      for (final key in ['messages', 'history', 'chats', 'results', 'docs', 'data']) {
        if (json[key] is List) {
          rawList = json[key] as List<dynamic>;
          break;
        }
      }
      if (rawList.isEmpty && json['data'] is Map) {
        final nested = json['data'] as Map;
        for (final key in ['messages', 'history', 'chat', 'results', 'docs', 'data']) {
          if (nested[key] is List) {
            rawList = nested[key] as List<dynamic>;
            break;
          }
        }
        if (rawList.isEmpty && nested['chat'] is Map && nested['chat']['messages'] is List) {
          rawList = nested['chat']['messages'] as List<dynamic>;
        }
      }
      if (rawList.isEmpty && json['chat'] is Map && json['chat']['messages'] is List) {
        rawList = json['chat']['messages'] as List<dynamic>;
      }
      if (rawList.isEmpty) {
        for (final val in json.values) {
          if (val is List) {
            rawList = val;
            break;
          }
        }
      }
    }

    return rawList
        .where((item) => item != null && item is Map)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }
}
