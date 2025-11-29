import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_model.dart';
import '../services/db_service.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

/// Simple video call screen - just creates room and sends link via chat
class VideoCallSimpleScreen extends StatefulWidget {
  final UserModel currentUser;
  final UserModel otherUser;

  const VideoCallSimpleScreen({
    super.key,
    required this.currentUser,
    required this.otherUser,
  });

  @override
  State<VideoCallSimpleScreen> createState() => _VideoCallSimpleScreenState();
}

class _VideoCallSimpleScreenState extends State<VideoCallSimpleScreen> {
  String? _roomName;
  bool _isCreating = true;
  bool _linkSent = false;

  @override
  void initState() {
    super.initState();
    _createRoomAndSendLink();
  }

  Future<void> _createRoomAndSendLink() async {
    // Create room name
    _roomName = _createRoomName(widget.currentUser.uid, widget.otherUser.uid);
    final jitsiUrl = 'https://meet.jit.si/$_roomName';

    try {
      // Send Jitsi link via chat message
      final dbService = Provider.of<DatabaseService>(context, listen: false);
      final message = MessageModel(
        id: const Uuid().v4(),
        senderId: widget.currentUser.uid,
        receiverId: widget.otherUser.uid,
        message: '📹 Video Call: $jitsiUrl\n\nClick the link to join!',
      );

      await dbService.sendMessage(message);
      _linkSent = true;

      // Open Jitsi for caller
      await _openJitsi(jitsiUrl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Call link sent! Opening meeting...'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Close screen after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.of(context).pop();
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isCreating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  String _createRoomName(String uid1, String uid2) {
    // Use deterministic room name from db_service
    return DatabaseService.generateRoomName(uid1, uid2);
  }

  Future<void> _openJitsi(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      print('Error opening Jitsi: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Starting Video Call'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isCreating)
                const CircularProgressIndicator()
              else
                const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 24),
              Text(
                _isCreating
                    ? 'Creating call and sending link...'
                    : _linkSent
                        ? 'Call link sent!\nOpening meeting...'
                        : 'Error creating call',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (_roomName != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Room: $_roomName',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


