import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../../core/constants/api_constants.dart';
import '../models/message_model.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;

  WebSocketChannel? _channel;
  String? _authToken;
  bool _isConnected = false;
  Timer? _reconnectTimer;
  final int _maxReconnectAttempts = 5;
  int _reconnectAttempts = 0;

  // Stream controllers for different events
  final StreamController<MessageModel> _messageController = StreamController<MessageModel>.broadcast();
  final StreamController<String> _typingController = StreamController<String>.broadcast();
  final StreamController<String> _onlineStatusController = StreamController<String>.broadcast();
  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();

  WebSocketService._internal();

  // ===========================================================================
  // CONNECTION MANAGEMENT
  // ===========================================================================

  Future<void> connect(String token) async {
    _authToken = token;

    if (_isConnected) {
      disconnect();
    }

    try {
      final wsUrl = '${ApiConstants.wsUrl}/chat/?token=$token';
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      await _channel!.ready;
      _isConnected = true;
      _reconnectAttempts = 0;
      _connectionController.add(true);

      if (kDebugMode) {
        print('🔌 WebSocket connected to: $wsUrl');
      }

      // Listen for incoming messages
      _channel!.stream.listen(
        _onMessageReceived,
        onError: _onError,
        onDone: _onDisconnected,
      );

      // Send initial presence
      _sendMessage({
        'type': 'presence',
        'status': 'online',
      });

    } catch (e) {
      if (kDebugMode) {
        print('❌ WebSocket connection failed: $e');
      }
      _scheduleReconnect();
    }
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _channel?.sink.close(status.goingAway);
    _channel = null;
    _isConnected = false;
    _connectionController.add(false);

    if (kDebugMode) {
      print('🔌 WebSocket disconnected');
    }
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      if (kDebugMode) {
        print('❌ Max reconnection attempts reached');
      }
      return;
    }

    _reconnectAttempts++;
    final delay = Duration(seconds: _reconnectAttempts * 2); // Exponential backoff

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      if (_authToken != null) {
        if (kDebugMode) {
          print('🔄 Attempting to reconnect... (${_reconnectAttempts}/${_maxReconnectAttempts})');
        }
        connect(_authToken!);
      }
    });
  }

  // ===========================================================================
  // MESSAGE HANDLING
  // ===========================================================================

  void _onMessageReceived(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      final messageType = data['type'] as String?;

      switch (messageType) {
        case 'message':
          _handleIncomingMessage(data);
          break;
        case 'typing':
          _handleTypingIndicator(data);
          break;
        case 'presence':
          _handlePresenceUpdate(data);
          break;
        case 'read_receipt':
          _handleReadReceipt(data);
          break;
        case 'error':
          _handleError(data);
          break;
        default:
          if (kDebugMode) {
            print('📨 Unknown message type: $messageType');
          }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error parsing WebSocket message: $e');
      }
    }
  }

  void _onError(dynamic error) {
    if (kDebugMode) {
      print('❌ WebSocket error: $error');
    }
    _scheduleReconnect();
  }

  void _onDisconnected() {
    _isConnected = false;
    _connectionController.add(false);

    if (kDebugMode) {
      print('🔌 WebSocket connection lost');
    }

    _scheduleReconnect();
  }

  // ===========================================================================
  // MESSAGE HANDLERS
  // ===========================================================================

  void _handleIncomingMessage(Map<String, dynamic> data) {
    try {
      final message = MessageModel.fromJson(data['message'] as Map<String, dynamic>);
      _messageController.add(message);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error parsing incoming message: $e');
      }
    }
  }

  void _handleTypingIndicator(Map<String, dynamic> data) {
    final conversationId = data['conversation_id'] as String?;
    final userId = data['user_id'] as String?;
    final isTyping = data['is_typing'] as bool? ?? false;

    if (conversationId != null && userId != null) {
      _typingController.add('$conversationId:$userId:$isTyping');
    }
  }

  void _handlePresenceUpdate(Map<String, dynamic> data) {
    final userId = data['user_id'] as String?;
    final status = data['status'] as String?;

    if (userId != null && status != null) {
      _onlineStatusController.add('$userId:$status');
    }
  }

  void _handleReadReceipt(Map<String, dynamic> data) {
    // Handle read receipts if needed
    if (kDebugMode) {
      print('📖 Read receipt: ${data['message_id']}');
    }
  }

  void _handleError(Map<String, dynamic> data) {
    final errorMessage = data['message'] as String? ?? 'Unknown error';
    if (kDebugMode) {
      print('❌ WebSocket error: $errorMessage');
    }
  }

  // ===========================================================================
  // OUTGOING MESSAGES
  // ===========================================================================

  void sendMessage({
    required String conversationId,
    required String messageType,
    String? content,
    String? mediaUrl,
    String? replyToId,
  }) {
    if (!_isConnected) {
      if (kDebugMode) {
        print('❌ Cannot send message: WebSocket not connected');
      }
      return;
    }

    final message = {
      'type': 'message',
      'conversation_id': conversationId,
      'message_type': messageType,
      if (content != null) 'content': content,
      if (mediaUrl != null) 'media_url': mediaUrl,
      if (replyToId != null) 'reply_to': replyToId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _sendMessage(message);
  }

  void sendTypingIndicator(String conversationId, bool isTyping) {
    if (!_isConnected) return;

    _sendMessage({
      'type': 'typing',
      'conversation_id': conversationId,
      'is_typing': isTyping,
    });
  }

  void markMessageAsRead(String messageId, String conversationId) {
    if (!_isConnected) return;

    _sendMessage({
      'type': 'read_receipt',
      'message_id': messageId,
      'conversation_id': conversationId,
    });
  }

  void updatePresence(String status) {
    if (!_isConnected) return;

    _sendMessage({
      'type': 'presence',
      'status': status,
    });
  }

  void _sendMessage(Map<String, dynamic> message) {
    if (_channel != null && _isConnected) {
      final jsonMessage = jsonEncode(message);
      _channel!.sink.add(jsonMessage);

      if (kDebugMode) {
        print('📤 Sent WebSocket message: ${message['type']}');
      }
    }
  }

  // ===========================================================================
  // STREAMS
  // ===========================================================================

  Stream<MessageModel> get messageStream => _messageController.stream;
  Stream<String> get typingStream => _typingController.stream;
  Stream<String> get onlineStatusStream => _onlineStatusController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;

  // ===========================================================================
  // UTILITY METHODS
  // ===========================================================================

  bool get isConnected => _isConnected;

  void dispose() {
    disconnect();
    _messageController.close();
    _typingController.close();
    _onlineStatusController.close();
    _connectionController.close();
  }
}
