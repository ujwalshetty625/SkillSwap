import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_model.dart';
import '../services/socket_service.dart';
import '../services/db_service.dart';

/// Screen shown when receiving an incoming video call
class IncomingCallScreen extends StatefulWidget {
  final String callId;
  final String callerId;
  final String callerName;
  final String roomName;

  const IncomingCallScreen({
    super.key,
    required this.callId,
    required this.callerId,
    required this.callerName,
    required this.roomName,
  });

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  final SocketService _socketService = SocketService.instance;
  bool _isJoining = false;
  UserModel? _caller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _setupSocketListeners();
    _loadCallerDetails();
  }

  Future<void> _loadCallerDetails() async {
    try {
      final dbService = Provider.of<DatabaseService>(context, listen: false);
      final caller = await dbService.getUserProfile(widget.callerId);
      if (mounted) {
        setState(() {
          _caller = caller;
          _isLoading = false;
        });
      }
    } catch (e) {
      // If loading fails, use basic info
      if (mounted) {
        setState(() {
          _caller = UserModel(
            uid: widget.callerId,
            email: '',
            name: widget.callerName,
          );
          _isLoading = false;
        });
      }
    }
  }

  void _setupSocketListeners() {
    _socketService.onCallEnded((data) {
      if (mounted && data['callId'] == widget.callId) {
        Navigator.of(context).pop();
      }
    });

    // Also listen for call_accepted (in case we need it)
    _socketService.onCallAccepted((data) {
      if (mounted && data['callId'] == widget.callId && !_isJoining) {
        // If we haven't opened Jitsi yet, open it now
        _openJitsiRoom(data['roomName'] ?? widget.roomName);
      }
    });
  }

  Future<void> _acceptCall() async {
    setState(() => _isJoining = true);

    // Accept the call via Socket.IO
    _socketService.acceptCall(widget.callId);

    // Wait a bit for backend to notify caller, then both open Jitsi
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Open Jitsi - both users will join the same room
    _openJitsiRoom(widget.roomName);
  }

  void _rejectCall() {
    _socketService.rejectCall(widget.callId);
    Navigator.of(context).pop();
  }

  Future<void> _openJitsiRoom(String roomName) async {
    print('🚀 Opening Jitsi room: $roomName');
    final uri = Uri.parse('https://meet.jit.si/$roomName');
    
    try {
      // Try external browser first (works better for Jitsi)
      bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched) {
        // Fallback to in-app browser
        await launchUrl(uri, mode: LaunchMode.inAppWebView);
      }
      
      print('✅ Jitsi opened successfully');
    } catch (e) {
      print('❌ Error opening Jitsi: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open meeting: $e'),
            action: SnackBarAction(
              label: 'Copy Link',
              onPressed: () {
                // Copy room link to clipboard
                // You can add clipboard package if needed
              },
            ),
          ),
        );
      }
    }

    // Close the incoming call screen after opening Jitsi
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black87,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final caller = _caller ?? UserModel(
      uid: widget.callerId,
      email: '',
      name: widget.callerName,
    );

    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Caller avatar
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white24,
                backgroundImage: caller.photoUrl != null
                    ? NetworkImage(caller.photoUrl!)
                    : null,
                child: caller.photoUrl == null
                    ? Text(
                        caller.name[0].toUpperCase(),
                        style: const TextStyle(fontSize: 48, color: Colors.white),
                      )
                    : null,
              ),
              const SizedBox(height: 32),
              
              // Caller name
              Text(
                caller.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              
              // Call status
              Text(
                _isJoining ? 'Connecting...' : 'Incoming Video Call',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 64),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Reject button
                  FloatingActionButton(
                    key: const ValueKey('reject_button'),
                    onPressed: _rejectCall,
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.call_end, color: Colors.white),
                  ),
                  const SizedBox(width: 32),
                  
                  // Accept button
                  FloatingActionButton(
                    key: const ValueKey('accept_button'),
                    onPressed: _isJoining ? null : _acceptCall,
                    backgroundColor: Colors.green,
                    child: _isJoining
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Icon(Icons.videocam, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

