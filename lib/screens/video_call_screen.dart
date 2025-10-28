import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import '../models/user_model.dart';

/// Video call screen using Jitsi Meet
/// Enables face-to-face skill exchange sessions
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
  final JitsiMeet _jitsiMeet = JitsiMeet();
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _joinMeeting();
  }

  /// Join Jitsi video call
  Future<void> _joinMeeting() async {
    setState(() => _isJoining = true);

    try {
      // Create a unique room name based on both user IDs
      String roomName = _createRoomName(
        widget.currentUser.uid,
        widget.otherUser.uid,
      );

      // Configure Jitsi meeting options
      var options = JitsiMeetConferenceOptions(
        room: roomName,
        configOverrides: {
          "startWithAudioMuted": false,
          "startWithVideoMuted": false,
          "subject": "Skillocity Session",
        },
        featureFlags: {
          "unsaferoomwarning.enabled": false,
          "prejoinpage.enabled": false,
        },
        userInfo: JitsiMeetUserInfo(
          displayName: widget.currentUser.name,
          email: widget.currentUser.email,
          avatar: widget.currentUser.photoUrl,
        ),
      );

      // Add event listeners for call lifecycle
      _jitsiMeet.addListener(JitsiMeetEventListener(
        conferenceJoined: (url) {
          debugPrint("Conference joined: $url");
          setState(() => _isJoining = false);
        },
        conferenceTerminated: (url, error) {
          debugPrint("Conference terminated: $url, error: $error");
          if (mounted) {
            Navigator.of(context).pop();
          }
        },
        conferenceWillJoin: (url) {
          debugPrint("Conference will join: $url");
        },
        participantJoined: (email, name, role, participantId) {
          debugPrint("Participant joined: $name");
        },
        participantLeft: (participantId) {
          debugPrint("Participant left");
        },
        audioMutedChanged: (muted) {
          debugPrint("Audio muted: $muted");
        },
        videoMutedChanged: (muted) {
          debugPrint("Video muted: $muted");
        },
        readyToClose: () {
          debugPrint("Ready to close");
          if (mounted) {
            Navigator.of(context).pop();
          }
        },
      ));

      // Join the meeting
      await _jitsiMeet.join(options);
    } catch (e) {
      if (mounted) {
        setState(() => _isJoining = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join call: $e')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  /// Create a consistent room name for two users
  String _createRoomName(String uid1, String uid2) {
    // Sort UIDs to ensure same room regardless of who initiates
    List<String> ids = [uid1, uid2]..sort();
    return 'skillocity_${ids[0]}_${ids[1]}'.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
  }

  @override
  void dispose() {
    _jitsiMeet.removeAllListeners();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isJoining
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 24),
                  Text(
                    'Starting video call with ${widget.otherUser.name}...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
