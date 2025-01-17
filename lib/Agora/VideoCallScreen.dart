import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../dio/Constant.dart';

class VideoCallScreen extends StatefulWidget {
  final String userId;
  final String astrologerId;
  final String channleid;
  final String token;
  final int uid;

  const VideoCallScreen({
    required this.userId,
    required this.astrologerId,
    required this.channleid,
    required this.token,
    required this.uid,
    Key? key,
  }) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();

}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late RtcEngine _engine;

  int? _remoteUid;
  bool _localUserJoined = false;

  /// Whether the user has tapped "Accept"
  bool _callAccepted = false;

  /// Audio/Video control booleans
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  bool _isCameraOn = true; // whether local video is on
  bool _isFrontCamera = true; // track front/back camera

  @override
  void initState() {
    super.initState();

  }

  Future<void> initAgora(String channel) async {

    debugPrint('Initializing Agora with channel: $channel');

    // Request camera & mic permissions
    final permissions = await [
      Permission.microphone,
      Permission.camera,
    ].request();

    if (permissions[Permission.camera]!.isGranted &&
        permissions[Permission.microphone]!.isGranted) {
        debugPrint('Permissions granted.');

      // Create the engine
      _engine = createAgoraRtcEngine();
      try {
        await _engine.initialize(
          RtcEngineContext(
            appId: AGORA_APP_ID, // from your Constant.dart
          ),
        );
        debugPrint('Agora Engine initialized successfully');
      } catch (e) {
        debugPrint('Error initializing Agora Engine: $e');
        return;
      }

      // Register event handlers
      _engine.registerEventHandler(

        RtcEngineEventHandler(
          onJoinChannelSuccess: (connection, elapsed) {
            debugPrint(
              'Local user joined channel successfully with UID: ${connection.localUid}',
            );
            setState(() {
              _localUserJoined = true;
            });
          },

          onUserJoined: (connection, remoteUid, elapsed) {
            debugPrint('Remote user joined with UID: $remoteUid');
            setState(() {
              _remoteUid = remoteUid;
            });
          },

          onUserOffline: (connection, remoteUid, reason) {
            _endCall();
            debugPrint(
              'Remote user went offline with UID: $remoteUid, reason: $reason',
            );
            setState(() => _remoteUid = null);
          },

          onError: (errorType, errorMessage) {
            debugPrint('Agora error occurred: $errorType, $errorMessage');
          },
        ),
      );

      // Enable Video & Audio
      await _engine.enableVideo();
      await _engine.enableAudio();

      debugPrint('Video and audio enabled. Joining channel...');

      try {
        await _engine.joinChannel(
          token: widget.token,
          channelId: channel,
          uid: widget.uid,
          options: ChannelMediaOptions(
            clientRoleType: ClientRoleType.clientRoleBroadcaster,
          ),
        );
        debugPrint('Joined the Agora channel successfully.');
      } catch (e) {
        debugPrint('Error joining Agora channel: $e');
      }
    } else {
      debugPrint('Camera or Microphone permission not granted.');
    }
  }

  /// Leave the channel and pop the screen
  void _endCall() {
    debugPrint('Ending call and returning to the previous screen.');
    Navigator.pop(context);
    if(_remoteUid != null) {
      _engine.leaveChannel();
    }
    _engine.release(); ///LateInitializationError: Field '_engine@57427641' has not been initialized.
  }

  /// Toggle local audio mute
  void _toggleMute() async {
    setState(() => _isMuted = !_isMuted);
    await _engine.muteLocalAudioStream(_isMuted);
  }

  /// Toggle speakerphone
  void _toggleSpeaker() async {
    setState(() => _isSpeakerOn = !_isSpeakerOn);
    await _engine.setEnableSpeakerphone(_isSpeakerOn);
  }

  /// Toggle camera on/off
  void _toggleCamera() async {
    setState(() => _isCameraOn = !_isCameraOn);
    await _engine.enableLocalVideo(_isCameraOn);
  }

  /// Switch front/back camera
  void _switchCamera() async {
    setState(() => _isFrontCamera = !_isFrontCamera);
    await _engine.switchCamera();
  }

  /// Local video preview
  Widget _renderLocalPreview() {
    if (_localUserJoined && _isCameraOn) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: widget.uid),
        ),
      );
    } else if (_localUserJoined && !_isCameraOn) {
      // If joined but camera is off, show placeholder
      return Container(
        color: Colors.black54,
        child: const Center(
          child: Icon(
            Icons.videocam_off,
            color: Colors.white,
            size: 40,
          ),
        ),
      );
    } else {
      // Not joined or still loading
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  /// Remote video
  Widget _renderRemoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: widget.channleid),
        ),
      );
    } else {
      return Container(
        color: Colors.blueGrey,
        child: const Center(
          child: Text(
            'Waiting for remote user to join...',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }
  }

  /// Main build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // MAIN UI
          Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    // Remote video in the center
                    Center(child: _renderRemoteVideo()),

                    // Local video top-left
                    Align(
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: 120,
                        height: 160,
                        child: _renderLocalPreview(),
                      ),
                    ),

                    // OPTIONAL: Some decorative top-center icon or text
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.blueGrey,
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // BOTTOM CONTROLS (Moved outside Column, directly under Stack)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: _buildBottomControls(),
          ),
        ],
      ),
    );
  }


  /// Condition-based bottom controls
  Widget _buildBottomControls() {
    if (!_callAccepted) {
      // Before call is accepted, show accept & decline
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Accept
            FloatingActionButton(
              heroTag: 'acceptCall',
              backgroundColor: Colors.green,
              onPressed: () {
                setState(() => _callAccepted = true);
                initAgora(widget.channleid);
              },
              child: const Icon(Icons.call, color: Colors.white),
            ),
            // Decline
            FloatingActionButton(
              heroTag: 'declineCall',
              backgroundColor: Colors.red,
              onPressed: _endCall,
              child: const Icon(Icons.call_end, color: Colors.white),
            ),
          ],
        ),
      );
    } else {
      // Call accepted: show in-call controls
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Mute
            FloatingActionButton(
              heroTag: 'muteFab',
              backgroundColor: _isMuted ? Colors.red : Colors.grey,
              onPressed: _toggleMute,
              child: Icon(
                _isMuted ? Icons.mic_off : Icons.mic,
                color: Colors.white,
              ),
            ),
            // Camera On/Off
            FloatingActionButton(
              heroTag: 'cameraFab',
              backgroundColor: _isCameraOn ? Colors.grey : Colors.red,
              onPressed: _toggleCamera,
              child: Icon(
                _isCameraOn ? Icons.videocam : Icons.videocam_off,
                color: Colors.white,
              ),
            ),
            // Switch Camera
            FloatingActionButton(
              heroTag: 'switchCameraFab',
              backgroundColor: Colors.grey,
              onPressed: _switchCamera,
              child: const Icon(Icons.cameraswitch, color: Colors.white),
            ),
            // Speaker
            FloatingActionButton(
              heroTag: 'speakerFab',
              backgroundColor: _isSpeakerOn ? Colors.blue : Colors.grey,
              onPressed: _toggleSpeaker,
              child: Icon(
                _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                color: Colors.white,
              ),
            ),
            // End Call
            FloatingActionButton(
              heroTag: 'endCallFab',
              backgroundColor: Colors.red,
              onPressed: _endCall,
              child: const Icon(Icons.call_end, color: Colors.white),
            ),
          ],
        ),
      );
    }
  }
}
