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
      final String socketUrl = AppConstants.baseUrl.replaceAll('/api/', '');

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
            .setTransports(['websocket'])
            .setAuth({'token': token})
            .enableAutoConnect()
            .build(),
      );

      _socket?.connect();

      _socket?.onAny((event, data) {
        debugPrint("");
        debugPrint("===========================================");
        debugPrint("EVENT RECEIVED");
        debugPrint("Event : $event");
        debugPrint("Data  : $data");
        debugPrint("===========================================");
      });

      _socket?.onError((err) {
        debugPrint("SOCKET ERROR");
        debugPrint(err.toString());
      });

      _socket?.onConnectError((err) {
        debugPrint("CONNECT ERROR");
        debugPrint(err.toString());
      });

      _socket?.onDisconnect((reason) {
        debugPrint("DISCONNECTED : $reason");
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



      _socket?.on('connect_timeout', (data) {
        PrettyLogger.printBox(
          tag: 'SOCKET',
          title: 'Socket Connection ║ Timeout',
          lines: [
            'Data: $data',
          ],
        );
      });

      _socket?.onError((data) {
        PrettyLogger.printBox(
          tag: 'SOCKET',
          title: 'Socket Connection ║ Error Event',
          lines: [
            'Data: $data',
          ],
        );
      });

      _socket?.onReconnect((data) {
        PrettyLogger.printBox(
          tag: 'SOCKET',
          title: 'Socket Connection ║ Reconnected',
          lines: [
            'Data: $data',
          ],
        );
      });

      _socket?.onReconnectAttempt((data) {
        PrettyLogger.printBox(
          tag: 'SOCKET',
          title: 'Socket Connection ║ Reconnect Attempt',
          lines: [
            'Attempt Number: $data',
          ],
        );
      });

      _socket?.on('reconnecting', (data) {
        PrettyLogger.printBox(
          tag: 'SOCKET',
          title: 'Socket Connection ║ Reconnecting',
          lines: [
            'Data: $data',
          ],
        );
      });

      _socket?.onReconnectError((data) {
        PrettyLogger.printBox(
          tag: 'SOCKET',
          title: 'Socket Connection ║ Reconnect Error',
          lines: [
            'Error: $data',
          ],
        );
      });

      _socket?.onReconnectFailed((data) {
        PrettyLogger.printBox(
          tag: 'SOCKET',
          title: 'Socket Connection ║ Reconnect Failed',
          lines: [
            'Data: $data',
          ],
        );
      });

      // 4. Listen for Incoming Live Messages ("receiveMessage")
      _socket?.on('receiveMessage', (data) {
        PrettyLogger.printJson(
          tag: 'SOCKET',
          title: 'Socket Event ║ receiveMessage',
          data: data,
        );
        if (data != null && data is Map) {
          latestIncomingMessage.value = Map<String, dynamic>.from(data);
        }
      });

      // 7. Listen for Status Changes in Real-Time ("userStatusChanged")
      _socket?.on('userStatusChanged', (data) {
        PrettyLogger.printJson(
          tag: 'SOCKET',
          title: 'Socket Event ║ userStatusChanged',
          data: data,
        );
        if (data != null && data is Map) {
          latestUserStatus.value = Map<String, dynamic>.from(data);
        }
      });

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
    Function(dynamic response)? onAck,
  }) {
    PrettyLogger.printBox(
      tag: 'SOCKET',
      title: 'Socket Emit ║ sendMessage',
      lines: [
        'ReceiverId: $receiverId',
        'Message: $message',
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
        lines: ['WARNING: Socket client is not connected. Emitting anyway.'],
      );
    }

    _socket?.emitWithAck(
      'sendMessage',
      {
        'receiverId': receiverId,
        'message': message,
      },
      ack: (response) {
        PrettyLogger.printJson(
          tag: 'SOCKET',
          title: 'Socket Ack ║ sendMessage response',
          data: response,
        );
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
      PrettyLogger.printBox(
        tag: 'SOCKET',
        title: 'Socket Emit Error ║ getChats',
        lines: ['ERROR: Socket client is null.'],
      );
      callback([]);
      return;
    } else if (!_socket!.connected) {
      PrettyLogger.printBox(
        tag: 'SOCKET',
        title: 'Socket Emit Warning ║ getChats',
        lines: ['WARNING: Socket client is not connected.'],
      );
      callback([]);
      return;
    }

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
        if (response is Map && response.containsKey('chats')) {
          chatsList = response['chats'] ?? [];
        } else if (response is List) {
          chatsList = response;
        }
        callback(chatsList);
      },
    );
  }

  // 3. Get Messages for a Chat Room ("getMessages")
  void getMessages({
    required String chatId,
    required Function(List<dynamic> messages) callback,
  }) {
    PrettyLogger.printBox(
      tag: 'SOCKET',
      title: 'Socket Emit ║ getMessages',
      lines: ['ChatId: $chatId'],
    );

    if (_socket == null) {
      PrettyLogger.printBox(
        tag: 'SOCKET',
        title: 'Socket Emit Error ║ getMessages',
        lines: ['ERROR: Socket client is null.'],
      );
      callback([]);
      return;
    } else if (!_socket!.connected) {
      PrettyLogger.printBox(
        tag: 'SOCKET',
        title: 'Socket Emit Warning ║ getMessages',
        lines: ['WARNING: Socket client is not connected.'],
      );
      callback([]);
      return;
    }

    _socket?.emitWithAck(
      'getMessages',
      {'chatId': chatId},
      ack: (response) {
        PrettyLogger.printJson(
          tag: 'SOCKET',
          title: 'Socket Ack ║ getMessages response for chatId "$chatId"',
          data: response,
        );
        List<dynamic> msgList = [];
        if (response is Map && response.containsKey('messages')) {
          msgList = response['messages'] ?? [];
        } else if (response is List) {
          msgList = response;
        }
        callback(msgList);
      },
    );
  }

  // 5. Get New Matches to start chat ("getNewMatches")
  void getNewMatches(Function(List<dynamic> matches) callback) {
    PrettyLogger.printBox(
      tag: 'SOCKET',
      title: 'Socket Emit ║ getNewMatches',
      lines: ['Requesting new matches list.'],
    );

    if (_socket == null) {
      PrettyLogger.printBox(
        tag: 'SOCKET',
        title: 'Socket Emit Error ║ getNewMatches',
        lines: ['ERROR: Socket client is null.'],
      );
      callback([]);
      return;
    } else if (!_socket!.connected) {
      PrettyLogger.printBox(
        tag: 'SOCKET',
        title: 'Socket Emit Warning ║ getNewMatches',
        lines: ['WARNING: Socket client is not connected.'],
      );
      callback([]);
      return;
    }

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
        if (response is Map && response.containsKey('matches')) {
          matchesList = response['matches'] ?? [];
        } else if (response is List) {
          matchesList = response;
        }
        callback(matchesList);
      },
    );
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
      PrettyLogger.printBox(
        tag: 'SOCKET',
        title: 'Socket Emit Error ║ getUserStatus',
        lines: ['ERROR: Socket client is null.'],
      );
      callback(false, null);
      return;
    } else if (!_socket!.connected) {
      PrettyLogger.printBox(
        tag: 'SOCKET',
        title: 'Socket Emit Warning ║ getUserStatus',
        lines: ['WARNING: Socket client is not connected.'],
      );
      callback(false, null);
      return;
    }

    _socket?.emitWithAck(
      'getUserStatus',
      {'targetUserId': targetUserId},
      ack: (res) {
        PrettyLogger.printJson(
          tag: 'SOCKET',
          title: 'Socket Ack ║ getUserStatus response for targetUserId "$targetUserId"',
          data: res,
        );
        bool isOnline = false;
        String? lastSeen;
        if (res is Map) {
          isOnline = res['isOnline'] == true;
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
    PrettyLogger.printBox(
      tag: 'SOCKET',
      title: 'Socket Connection ║ Disconnected Successfully',
      lines: ['All socket references destroyed.'],
    );
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
