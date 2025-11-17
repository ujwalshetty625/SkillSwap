import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import 'dart:io';

/// Socket.IO service for real-time communication
class SocketService {
  static SocketService? _instance;
  IO.Socket? _socket;
  String? _currentUserId;
  bool _isWeb = kIsWeb;

  SocketService._();

  static SocketService get instance {
    _instance ??= SocketService._();
    return _instance!;
  }

  // Auto-detect platform and use correct URL
  static String get socketUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    } else if (Platform.isAndroid) {
      // Android emulator uses 10.0.2.2 to access host machine's localhost
      return 'http://10.0.2.2:3000';
    } else if (Platform.isIOS) {
      // iOS simulator can use localhost
      return 'http://localhost:3000';
    } else {
      // Desktop or other - use localhost
      return 'http://localhost:3000';
    }
  }
  
  // For physical device, manually change to: http://YOUR_COMPUTER_IP:3000

  /// Connect to Socket.IO server
  void connect(String userId) {
    // Skip Socket.IO on web for now (has compatibility issues)
    if (_isWeb) {
      print('⚠️ Socket.IO skipped on web platform');
      _currentUserId = userId;
      return;
    }

    if (_socket?.connected == true && _currentUserId == userId) {
      return; // Already connected
    }

    disconnect(); // Disconnect previous connection

    _currentUserId = userId;

    try {
      _socket = IO.io(
        socketUrl, // Now uses getter that auto-detects platform
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling']) // Add polling as fallback
            .enableAutoConnect()
            .build(),
      );

      _socket!.connect();

      _socket!.onConnect((_) {
        print('✅ Socket.IO connected');
        join(userId);
      });

      _socket!.onDisconnect((_) {
        print('❌ Socket.IO disconnected');
      });

      _socket!.onError((error) {
        print('❌ Socket.IO error: $error');
      });
    } catch (e) {
      print('❌ Failed to initialize Socket.IO: $e');
      _socket = null;
    }
  }

  /// Join user's personal room
  void join(String userId) {
    if (_isWeb) return; // Skip on web
    _socket?.emit('join', userId);
  }

  /// Disconnect from Socket.IO server
  void disconnect() {
    if (_isWeb) {
      _currentUserId = null;
      return;
    }
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _currentUserId = null;
  }

  /// Get socket instance
  IO.Socket? get socket => _socket;

  /// Check if connected
  bool get isConnected {
    if (_isWeb) return false; // Not connected on web
    return _socket?.connected ?? false;
  }

  /// Listen to incoming messages
  void onMessage(Function(Map<String, dynamic>) callback) {
    _socket?.on('receive_message', (data) {
      callback(Map<String, dynamic>.from(data));
    });
  }

  /// Send message via Socket.IO
  void sendMessage({
    required String senderId,
    required String receiverId,
    required String message,
  }) {
    if (_isWeb) return; // Skip on web
    _socket?.emit('send_message', {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
    });
  }

  /// Initiate a video call
  void initiateCall({
    required String callerId,
    required String receiverId,
    required String roomName,
    String? callerName,
  }) {
    if (_isWeb) {
      print('⚠️ Video calls not supported on web yet');
      return;
    }
    _socket?.emit('initiate_call', {
      'callerId': callerId,
      'receiverId': receiverId,
      'roomName': roomName,
      'callerName': callerName,
    });
  }

  /// Accept a call
  void acceptCall(String callId) {
    if (_isWeb) return;
    _socket?.emit('accept_call', {'callId': callId});
  }

  /// Reject a call
  void rejectCall(String callId) {
    if (_isWeb) return;
    _socket?.emit('reject_call', {'callId': callId});
  }

  /// End a call
  void endCall(String callId) {
    if (_isWeb) return;
    _socket?.emit('end_call', {'callId': callId});
  }

  /// Listen to incoming calls
  void onIncomingCall(Function(Map<String, dynamic>) callback) {
    if (_isWeb) {
      print('⚠️ Incoming call listener not available on web');
      return;
    }
    print('🎧 Setting up incoming call listener');
    try {
      _socket?.on('incoming_call', (data) {
        print('📞 Incoming call event received: $data');
        callback(Map<String, dynamic>.from(data));
      });
    } catch (e) {
      print('❌ Error setting up incoming call listener: $e');
    }
  }

  /// Listen to call accepted
  void onCallAccepted(Function(Map<String, dynamic>) callback) {
    if (_isWeb) return;
    print('🎧 Setting up call_accepted listener');
    try {
      _socket?.on('call_accepted', (data) {
        print('✅ Call accepted event received: $data');
        callback(Map<String, dynamic>.from(data));
      });
    } catch (e) {
      print('❌ Error setting up call_accepted listener: $e');
    }
  }

  /// Listen to call rejected
  void onCallRejected(Function(Map<String, dynamic>) callback) {
    if (_isWeb) return;
    try {
      _socket?.on('call_rejected', (data) {
        callback(Map<String, dynamic>.from(data));
      });
    } catch (e) {
      print('❌ Error setting up call_rejected listener: $e');
    }
  }

  /// Listen to call ended
  void onCallEnded(Function(Map<String, dynamic>) callback) {
    if (_isWeb) return;
    try {
      _socket?.on('call_ended', (data) {
        callback(Map<String, dynamic>.from(data));
      });
    } catch (e) {
      print('❌ Error setting up call_ended listener: $e');
    }
  }

  /// Listen to call initiated (confirmation for caller)
  void onCallInitiated(Function(Map<String, dynamic>) callback) {
    if (_isWeb) return;
    try {
      _socket?.on('call_initiated', (data) {
        callback(Map<String, dynamic>.from(data));
      });
    } catch (e) {
      print('❌ Error setting up call_initiated listener: $e');
    }
  }

  /// Listen to join call (for receiver after accepting)
  void onJoinCall(Function(Map<String, dynamic>) callback) {
    if (_isWeb) return;
    try {
      _socket?.on('join_call', (data) {
        callback(Map<String, dynamic>.from(data));
      });
    } catch (e) {
      print('❌ Error setting up join_call listener: $e');
    }
  }

  /// Remove all listeners
  void removeAllListeners() {
    if (_isWeb) return;
    _socket?.clearListeners();
  }

  /// Remove specific listener
  void removeListener(String event) {
    if (_isWeb) return;
    _socket?.off(event);
  }
}

