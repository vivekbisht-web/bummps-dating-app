import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../storage/secure_storage_service.dart';
import '../../constants/app_constants.dart';

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

      _socket = io.io(
        socketUrl,
        io.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .enableAutoConnect()
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .setAuth({'token': token, 'userId': userId})
            .build(),
      );

      _socket?.onConnect((_) {
        debugPrint('[SocketService] Connected to socket server: $socketUrl');
        isConnected.value = true;
      });

      _socket?.onDisconnect((_) {
        debugPrint('[SocketService] Disconnected from socket server');
        isConnected.value = false;
      });

      _socket?.onConnectError((data) {
        debugPrint('[SocketService] Connection error: $data');
        isConnected.value = false;
      });

      // 4. Listen for Incoming Live Messages ("receiveMessage")
      _socket?.on('receiveMessage', (data) {
        debugPrint('[SocketService] receiveMessage event: $data');
        if (data != null && data is Map) {
          latestIncomingMessage.value = Map<String, dynamic>.from(data);
        }
      });

      // 7. Listen for Status Changes in Real-Time ("userStatusChanged")
      _socket?.on('userStatusChanged', (data) {
        debugPrint('[SocketService] userStatusChanged event: $data');
        if (data != null && data is Map) {
          latestUserStatus.value = Map<String, dynamic>.from(data);
        }
      });

    } catch (e) {
      debugPrint('[SocketService] Socket initialization error: $e');
    }
  }

  // 1. Send Message ("sendMessage")
  void sendMessage({
    required String receiverId,
    required String message,
    Function(dynamic response)? onAck,
  }) {
    if (_socket == null || !_socket!.connected) {
      debugPrint('[SocketService] Socket not connected when sending message');
    }
    _socket?.emitWithAck(
      'sendMessage',
      {
        'receiverId': receiverId,
        'message': message,
      },
      ack: (response) {
        debugPrint('[SocketService] sendMessage response: $response');
        if (onAck != null) onAck(response);
      },
    );
  }

  // 2. Get Chat Inbox List ("getChats")
  void getChats(Function(List<dynamic> chats) callback) {
    if (_socket == null || !_socket!.connected) {
      callback([]);
    }
    _socket?.emitWithAck(
      'getChats',
      null,
      ack: (response) {
        debugPrint('[SocketService] getChats response: $response');
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
    if (_socket == null || !_socket!.connected) {
      callback([]);
    }
    _socket?.emitWithAck(
      'getMessages',
      {'chatId': chatId},
      ack: (response) {
        debugPrint('[SocketService] getMessages response: $response');
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
    if (_socket == null || !_socket!.connected) {
      callback([]);
    }
    _socket?.emitWithAck(
      'getNewMatches',
      null,
      ack: (response) {
        debugPrint('[SocketService] getNewMatches response: $response');
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
    if (_socket == null || !_socket!.connected) {
      callback(false, null);
    }
    _socket?.emitWithAck(
      'getUserStatus',
      {'targetUserId': targetUserId},
      ack: (res) {
        debugPrint('[SocketService] getUserStatus response: $res');
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
