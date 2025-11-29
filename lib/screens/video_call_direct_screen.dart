import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_model.dart';
import '../services/db_service.dart';

/// Direct video call screen - opens Jitsi immediately with deterministic room name
/// Both users can join the same room by using this screen
class VideoCallDirectScreen extends StatefulWidget {
  final UserModel currentUser;
  final UserModel otherUser;

  const VideoCallDirectScreen({
    super.key,
    required this.currentUser,
    required this.otherUser,
  });

  @override
  State<VideoCallDirectScreen> createState() => _VideoCallDirectScreenState();
}

class _VideoCallDirectScreenState extends State<VideoCallDirectScreen> {
  String? _roomName;
  bool _isOpening = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initiateCall();
  }

  Future<void> _initiateCall() async {
    try {
      // Generate deterministic room name
      _roomName = DatabaseService.generateRoomName(
        widget.currentUser.uid,
        widget.otherUser.uid,
      );

      if (mounted) {
        setState(() {
          _isOpening = true;
          _hasError = false;
        });
      }

      // Open Jitsi Meet room immediately
      await _openJitsiRoom(_roomName!);

      if (mounted) {
        setState(() {
          _isOpening = false;
        });
      }
    } catch (e) {
      print('❌ Error initiating call: $e');
      if (mounted) {
        setState(() {
          _isOpening = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _openJitsiRoom(String roomName) async {
    print('🚀 Opening Jitsi room: $roomName');
    
    // Construct Jitsi Meet URL
    final jitsiUrl = 'https://meet.jit.si/$roomName';
    final uri = Uri.parse(jitsiUrl);
    
    try {
      bool launched = false;
      
      if (kIsWeb) {
        // Web: open in new tab
        launched = await launchUrl(uri, webOnlyWindowName: '_blank');
      } else {
        // Mobile: try external browser first (better for Jitsi)
        launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        
        if (!launched) {
          // Fallback to in-app browser
          launched = await launchUrl(
            uri,
            mode: LaunchMode.inAppWebView,
          );
        }
      }
      
      if (launched) {
        print('✅ Jitsi opened successfully: $jitsiUrl');
        
        // Close this screen after a short delay to let Jitsi open
        if (mounted) {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.of(context).pop();
            }
          });
        }
      } else {
        throw Exception('Could not open Jitsi Meet. Please check your internet connection.');
      }
    } catch (e) {
      print('❌ Error opening Jitsi: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _retry() async {
    setState(() {
      _isOpening = true;
      _hasError = false;
      _errorMessage = null;
    });
    await _openJitsiRoom(_roomName!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                        style: TextStyle(
                          fontSize: 48,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 32),
              
              // Status text
              Text(
                _isOpening
                    ? 'Opening video call with ${widget.otherUser.name}...'
                    : _hasError
                        ? 'Error opening call'
                        : 'Call opened!',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Room name display
              if (_roomName != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Room Name:',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          _roomName!,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Share this room name with ${widget.otherUser.name} so they can join',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              
              const SizedBox(height: 32),
              
              // Loading or error indicator
              if (_isOpening)
                const CircularProgressIndicator()
              else if (_hasError) ...[
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ?? 'Unknown error',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _retry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ] else
                Icon(
                  Icons.check_circle,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
              
              const SizedBox(height: 32),
              
              // Close button
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

