import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_model.dart';
import '../services/socket_service.dart';
import '../services/db_service.dart';

/// Video call screen - initiates call and waits for acceptance
class VideoCallScreen extends StatefulWidget {
  final UserModel currentUser;
  final UserModel otherUser;

  const VideoCallScreen({
    super.key,
    required this.currentUser,
    required this.otherUser,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final SocketService _socketService = SocketService.instance;
  bool _isCalling = true;
  bool _isCallAccepted = false;
  String? _roomName;
  String? _callId;

  @override
  void initState() {
    super.initState();
    _setupSocketListeners();
    _initiateCall();
  }

  void _setupSocketListeners() {
    // Listen for call acceptance
    _socketService.onCallAccepted((data) {
      print('✅ Call accepted! Opening Jitsi...');
      if (mounted && data['callId'] == _callId) {
        setState(() {
          _isCallAccepted = true;
          _isCalling = false;
        });
        // Open Jitsi immediately when call is accepted
        // Use the roomName we created (same as receiver will use)
        _openJitsiRoom(data['roomName'] ?? _roomName!);
      }
    });

    // Listen for call rejection
    _socketService.onCallRejected((data) {
      if (mounted && data['callId'] == _callId) {
        setState(() {
          _isCalling = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Call was rejected'),
            backgroundColor: Colors.red,
          ),
        );
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.of(context).pop();
        });
      }
    });

    // Listen for call ended
    _socketService.onCallEnded((data) {
      if (mounted && data['callId'] == _callId) {
        Navigator.of(context).pop();
      }
    });
  }

  void _initiateCall() {
    // Create room name
    _roomName = _createRoomName(widget.currentUser.uid, widget.otherUser.uid);

    // Initiate call via Socket.IO
    _socketService.initiateCall(
      callerId: widget.currentUser.uid,
      receiverId: widget.otherUser.uid,
      roomName: _roomName!,
      callerName: widget.currentUser.name,
    );

    // Listen for call initiated confirmation
    _socketService.onCallInitiated((data) {
      if (mounted) {
        setState(() {
          _callId = data['callId'];
        });
      }
    });
  }

  String _createRoomName(String uid1, String uid2) {
    // Use deterministic room name from db_service
    return DatabaseService.generateRoomName(uid1, uid2);
  }

  Future<void> _openJitsiRoom(String roomName) async {
    print('🚀 Opening Jitsi room: $roomName');
    final uri = Uri.parse('https://meet.jit.si/$roomName');
    
    try {
      bool launched = false;
      
      if (kIsWeb) {
        launched = await launchUrl(uri, webOnlyWindowName: '_blank');
      } else {
        // Try external browser first (works better for Jitsi)
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        
        if (!launched) {
          // Fallback to in-app browser
          launched = await launchUrl(uri, mode: LaunchMode.inAppWebView);
        }
      }
      
      if (launched) {
        print('✅ Jitsi opened successfully');
      } else {
        throw 'Could not open $uri';
      }
      
      // Close the call screen after opening Jitsi
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    } catch (e) {
      print('❌ Error opening Jitsi: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open meeting: $e'),
            action: SnackBarAction(
              label: 'Try Again',
              onPressed: () => _openJitsiRoom(roomName),
            ),
          ),
        );
      }
    }
  }

  void _endCall() {
    if (_callId != null) {
      _socketService.endCall(_callId!);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skillocity — Video Call'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Other user avatar
              CircleAvatar(
                radius: 60,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                backgroundImage: widget.otherUser.photoUrl != null
                    ? NetworkImage(widget.otherUser.photoUrl!)
                    : null,
                child: widget.otherUser.photoUrl == null
                    ? Text(
                        widget.otherUser.name[0].toUpperCase(),
                        style: const TextStyle(fontSize: 48),
                      )
                    : null,
              ),
              const SizedBox(height: 32),
              
              // Status text
              Text(
                _isCalling
                    ? 'Calling ${widget.otherUser.name}...'
                    : _isCallAccepted
                        ? 'Call connected!'
                        : 'Call ended',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              if (_roomName != null)
                SelectableText(
                  'Room: $_roomName',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              const SizedBox(height: 32),
              
              // Call animation or status
              if (_isCalling)
                const CircularProgressIndicator()
              else if (_isCallAccepted)
                const Icon(Icons.check_circle, color: Colors.green, size: 48)
              else
                const Icon(Icons.call_end, color: Colors.red, size: 48),
              
              const SizedBox(height: 32),
              
              // End call button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.call_end, color: Colors.white),
                label: const Text('End Call', style: TextStyle(color: Colors.white)),
                onPressed: _endCall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

