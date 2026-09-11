import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../storage/secure_storage_service.dart';
import '../../constants/app_constants.dart';
import '../../utils/pretty_logger.dart';

/// Manages real-time Socket.IO communication for chat messaging & user status.
class SocketService extends GetxService {
  io.Socket? _socket;
  final RxBool isConnected = false.obs;

  // Observables for real-time socket events
  final Rxn<Map<String, dynamic>> latestIncomingMessage = Rxn<Map<String, dynamic>>();
  final Rxn<Map<String, dynamic>> latestUserStatus = Rxn<Map<String, dynamic>>();
  final Rxn<List<dynamic>> latestChatsList = Rxn<List<dynamic>>();
  final Rxn<List<dynamic>> latestMatchesList = Rxn<List<dynamic>>();

  Future<SocketService> init() async {
    await connectSocket();
    return this;
  }

  Future<void> connectSocket() async {
    try {
      final storage = Get.find<SecureStorageService>();
      final token = await storage.getToken();
      final userId = await storage.getUserId();

      // Extract socket origin URL (e.g., https://datingapp-oz22.onrender.com)
      final String rawBase = AppConstants.baseUrl;
      String socketUrl = rawBase;
      try {
        final uri = Uri.parse(rawBase);
        socketUrl = '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
      } catch (_) {
        socketUrl = rawBase.replaceAll('/api/', '').replaceAll('/api', '');
      }

      PrettyLogger.printBox(
        tag: 'SOCKET',
        title: 'Socket Connection ║ Connecting',
        lines: [
          'URL: $socketUrl',
          'Token Length: ${token?.length ?? 0}',
          'UserId: $userId',
        ],
      );

      _socket = io.io(
        socketUrl,
        io.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .setAuth({
              'token': token ?? '',
              'authorization': token != null && token.isNotEmpty ? 'Bearer $token' : '',
              'userId': userId ?? '',
            })
            .setExtraHeaders({
              'Authorization': token != null && token.isNotEmpty ? 'Bearer $token' : '',
              'token': token ?? '',
            })
            .setQuery({
              'token': token ?? '',
              'userId': userId ?? '',
            })
            .enableAutoConnect()
            .enableReconnection()
            .build(),
      );

      _socket?.connect();

      _socket?.onAny((event, data) {
        debugPrint("");
        debugPrint("===========================================");
        debugPrint("[SOCKET EVENT RECEIVED]");
        debugPrint("Event : $event");
        debugPrint("Data  : $data");
        debugPrint("===========================================");
      });

      _socket?.onConnect((_) {
        PrettyLogger.printBox(
          tag: 'SOCKET',
          title: 'Socket Connection ║ Connected',
          lines: [
            'Server: $socketUrl',
          ],
        );
        isConnected.value = true;
      });

      _socket?.onDisconnect((reason) {
        PrettyLogger.printBox(
          tag: 'SOCKET',
          title: 'Socket Connection ║ Disconnected',
          lines: [
            'Reason: $reason',
          ],
        );
        isConnected.value = false;
      });

      _socket?.onConnectError((data) {
        PrettyLogger.printBox(
          tag: 'SOCKET',
          title: 'Socket Connection ║ Connect Error',
          lines: [
            'Error: $data',
          ],
        );
        isConnected.value = false;
      });

      _socket?.onError((err) {
        debugPrint("[SOCKET ERROR] $err");
      });

      _socket?.onReconnect((data) {
        debugPrint("[SOCKET RECONNECTED] $data");
        isConnected.value = true;
      });

      // 4. Listen for Incoming Live Messages (multi-event aliases)
      final incomingEvents = ['receiveMessage', 'newMessage', 'new_message', 'message', 'chatMessage', 'receive_message'];
      for (final evt in incomingEvents) {
        _socket?.on(evt, (data) {
          PrettyLogger.printJson(
            tag: 'SOCKET',
            title: 'Socket Event ║ $evt',
            data: data,
          );
          if (data != null && data is Map) {
            latestIncomingMessage.value = Map<String, dynamic>.from(data);
          }
        });
      }

      // 7. Listen for Status Changes in Real-Time
      final statusEvents = ['userStatusChanged', 'userOnline', 'userOffline', 'statusChanged', 'presence'];
      for (final evt in statusEvents) {
        _socket?.on(evt, (data) {
          PrettyLogger.printJson(
            tag: 'SOCKET',
            title: 'Socket Event ║ $evt',
            data: data,
          );
          if (data != null && data is Map) {
            latestUserStatus.value = Map<String, dynamic>.from(data);
          }
        });
      }

      // 8. Listen for Live Inbox / Chat updates
      final inboxEvents = ['chats', 'getChats', 'chatList', 'inbox', 'conversations'];
      for (final evt in inboxEvents) {
        _socket?.on(evt, (data) {
          debugPrint('[Socket] Received event "$evt" with data: $data');
          List<dynamic> list = [];
          if (data is List) {
            list = data;
          } else if (data is Map && data.containsKey('chats')) {
            list = data['chats'] ?? [];
          } else if (data is Map && data.containsKey('data')) {
            if (data['data'] is List) list = data['data'];
          }
          if (list.isNotEmpty) {
            latestChatsList.value = list;
          }
        });
      }

      // 9. Listen for Live Matches updates
      final matchEvents = ['matches', 'getNewMatches', 'newMatches', 'match'];
      for (final evt in matchEvents) {
        _socket?.on(evt, (data) {
          debugPrint('[Socket] Received event "$evt" with data: $data');
          List<dynamic> list = [];
          if (data is List) {
            list = data;
          } else if (data is Map && data.containsKey('matches')) {
            list = data['matches'] ?? [];
          } else if (data is Map && data.containsKey('data')) {
            if (data['data'] is List) list = data['data'];
          }
          if (list.isNotEmpty) {
            latestMatchesList.value = list;
          }
        });
      }

    } catch (e) {
      PrettyLogger.printBox(
        tag: 'SOCKET',
        title: 'Socket Connection ║ Init Exception',
        lines: [
          'Exception: $e',
        ],
      );
    }
  }

  // 1. Send Message ("sendMessage")
  void sendMessage({
    required String receiverId,
    required String message,
    String? roomId,
    Function(dynamic response)? onAck,
  }) {
    PrettyLogger.printBox(
      tag: 'SOCKET',
      title: 'Socket Emit ║ sendMessage',
      lines: [
        'ReceiverId: $receiverId',
        'Message: $message',
        if (roomId != null) 'RoomId: $roomId',
      ],
    );

    if (_socket == null) {
      PrettyLogger.printBox(
        tag: 'SOCKET',
        title: 'Socket Emit Error ║ sendMessage',
        lines: ['ERROR: Socket client is null.'],
      );
    } else if (!_socket!.connected) {
      PrettyLogger.printBox(
        tag: 'SOCKET',
        title: 'Socket Emit Warning ║ sendMessage',
        lines: ['WARNING: Socket client is not connected. Reconnecting & emitting.'],
      );
      _socket?.connect();
    }

    final Map<String, dynamic> payload = {
      'receiverId': receiverId,
      'targetUserId': receiverId,
      'recipientId': receiverId,
      'message': message,
      'text': message,
      'content': message,
      if (roomId != null && roomId.isNotEmpty) 'chatId': roomId,
      if (roomId != null && roomId.isNotEmpty) 'roomId': roomId,
    };

    _socket?.emitWithAck(
      'sendMessage',
      payload,
      ack: (response) {
        PrettyLogger.printJson(
          tag: 'SOCKET',
          title: 'Socket Ack ║ sendMessage response',
          data: response,
        );
        if (response != null && response is Map && response['success'] == true) {
          debugPrint("[Socket] Message sent successfully: ${response['data']}");
        } else {
          debugPrint("[Socket] Send message response/error: $response");
        }
        if (onAck != null) onAck(response);
      },
    );
  }

  // 2. Get Chat Inbox List ("getChats")
  void getChats(Function(List<dynamic> chats) callback) {
    PrettyLogger.printBox(
      tag: 'SOCKET',
      title: 'Socket Emit ║ getChats',
      lines: ['Requesting user chat list.'],
    );

    if (_socket == null) {
      callback([]);
      return;
    } else if (!_socket!.connected) {
      _socket?.connect();
    }

    bool callbackFired = false;

    // Ack handler
    _socket?.emitWithAck(
      'getChats',
      null,
      ack: (response) {
        PrettyLogger.printJson(
          tag: 'SOCKET',
          title: 'Socket Ack ║ getChats response',
          data: response,
        );
        List<dynamic> chatsList = [];
        if (response is Map && response.containsKey('chats') && response['chats'] is List) {
          chatsList = response['chats'];
        } else if (response is Map && response.containsKey('data') && response['data'] is List) {
          chatsList = response['data'];
        } else if (response is List) {
          chatsList = response;
        }
        if (!callbackFired) {
          callbackFired = true;
          callback(chatsList);
        }
      },
    );

    // Fallback: If server replies via event instead of ack
    _socket?.once('chats', (response) {
      if (!callbackFired) {
        callbackFired = true;
        List<dynamic> chatsList = [];
        if (response is List) {
          chatsList = response;
        } else if (response is Map && response.containsKey('chats')) {
          chatsList = response['chats'] ?? [];
        } else if (response is Map && response.containsKey('data') && response['data'] is List) {
          chatsList = response['data'];
        }
        callback(chatsList);
      }
    });
  }

  // 3. Get Messages for a Chat Room ("getMessages")
  void getMessages({
    required String chatId,
    required Function(List<dynamic> messages) callback,
  }) {
    PrettyLogger.printBox(
      tag: 'SOCKET',
      title: 'Socket Emit ║ getMessages & joinChat',
      lines: ['ChatId: $chatId'],
    );

    if (_socket == null) {
      callback([]);
      return;
    } else if (!_socket!.connected) {
      _socket?.connect();
    }

    // Join room
    _socket?.emit('joinChat', chatId);
    _socket?.emit('join', chatId);

    bool callbackFired = false;

    // Messages fetch via emitWithAck
    _socket?.emitWithAck(
      'getMessages',
      {
        'chatId': chatId,
        'roomId': chatId,
        'targetUserId': chatId,
        'receiverId': chatId,
      },
      ack: (response) {
        PrettyLogger.printJson(
          tag: 'SOCKET',
          title: 'Socket Ack ║ getMessages response for chatId "$chatId"',
          data: response,
        );
        List<dynamic> msgList = [];
        if (response is Map) {
          if (response['messages'] is List) {
            msgList = response['messages'];
          } else if (response['data'] is List) {
            msgList = response['data'];
          } else if (response['history'] is List) {
            msgList = response['history'];
          }
        } else if (response is List) {
          msgList = response;
        }
        if (!callbackFired) {
          callbackFired = true;
          callback(msgList);
        }
      },
    );

    // Fallback event listener
    _socket?.once('messages', (response) {
      if (!callbackFired) {
        callbackFired = true;
        List<dynamic> msgList = [];
        if (response is List) {
          msgList = response;
        } else if (response is Map && response['messages'] is List) {
          msgList = response['messages'];
        }
        callback(msgList);
      }
    });
  }

  // 5. Get New Matches to start chat ("getNewMatches")
  void getNewMatches(Function(List<dynamic> matches) callback) {
    PrettyLogger.printBox(
      tag: 'SOCKET',
      title: 'Socket Emit ║ getNewMatches',
      lines: ['Requesting new matches list.'],
    );

    if (_socket == null) {
      callback([]);
      return;
    } else if (!_socket!.connected) {
      _socket?.connect();
    }

    bool callbackFired = false;

    _socket?.emitWithAck(
      'getNewMatches',
      null,
      ack: (response) {
        PrettyLogger.printJson(
          tag: 'SOCKET',
          title: 'Socket Ack ║ getNewMatches response',
          data: response,
        );
        List<dynamic> matchesList = [];
        if (response is Map && response.containsKey('matches') && response['matches'] is List) {
          matchesList = response['matches'];
        } else if (response is Map && response.containsKey('data') && response['data'] is List) {
          matchesList = response['data'];
        } else if (response is List) {
          matchesList = response;
        }
        if (!callbackFired) {
          callbackFired = true;
          callback(matchesList);
        }
      },
    );

    _socket?.once('matches', (response) {
      if (!callbackFired) {
        callbackFired = true;
        List<dynamic> matchesList = [];
        if (response is List) {
          matchesList = response;
        } else if (response is Map && response.containsKey('matches')) {
          matchesList = response['matches'] ?? [];
        }
        callback(matchesList);
      }
    });
  }

  // 6. Check Status of a User ("getUserStatus")
  void getUserStatus({
    required String targetUserId,
    required Function(bool isOnline, String? lastSeen) callback,
  }) {
    PrettyLogger.printBox(
      tag: 'SOCKET',
      title: 'Socket Emit ║ getUserStatus',
      lines: ['TargetUserId: $targetUserId'],
    );

    if (_socket == null) {
      callback(false, null);
      return;
    } else if (!_socket!.connected) {
      _socket?.connect();
    }

    _socket?.emitWithAck(
      'getUserStatus',
      {
        'targetUserId': targetUserId,
        'userId': targetUserId,
      },
      ack: (res) {
        PrettyLogger.printJson(
          tag: 'SOCKET',
          title: 'Socket Ack ║ getUserStatus response for targetUserId "$targetUserId"',
          data: res,
        );
        bool isOnline = false;
        String? lastSeen;
        if (res is Map) {
          isOnline = res['isOnline'] == true || res['online'] == true;
          lastSeen = res['lastSeen']?.toString();
        }
        callback(isOnline, lastSeen);
      },
    );
  }

  void disconnect() {
    PrettyLogger.printBox(
      tag: 'SOCKET',
      title: 'Socket Connection ║ Disconnect Requested',
      lines: ['Current Connection Status: ${isConnected.value}'],
    );
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    isConnected.value = false;
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
