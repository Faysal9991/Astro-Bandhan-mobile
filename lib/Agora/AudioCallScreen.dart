import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../Home/SocketService.dart';
import '../dio/Constant.dart';

class AudioCallScreen extends StatefulWidget {

  final String userId;
  final String astrologerId;
  final String channleid;
  final String token;
  final int uid;

  const AudioCallScreen({
    required this.userId,
    required this.astrologerId,
    required this.channleid,
    required this.token,
    required this.uid,
    Key? key,
  }) : super(key: key);

  @override
  State<AudioCallScreen> createState() => _AudeoCallScreenState();

}

class _AudeoCallScreenState extends State<AudioCallScreen> {

  late RtcEngine _engine;
  String? CallId;
  int? _remoteUid;
  bool _localUserJoined = false;

  /// Tracks if the user has tapped "Accept"
  bool _callAccepted = false;

  /// Audio controls
  bool _isMuted = false;
  bool _isSpeakerOn = false;

  /// Call timer variables
  Timer? _callTimer;
  int _callDuration = 0; // in seconds

  @override
  void initState() {
    super.initState();
  }

  /// Format the duration as "mm:ss"
  String get _formattedCallDuration {
    final minutes = _callDuration ~/ 60;
    final seconds = _callDuration % 60;
    final mm = minutes.toString().padLeft(2, '0');
    final ss = seconds.toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  /// Start the timer (when the remote user joins)
  void _startCallTimer() {

    _stopCallTimer();
    _callDuration = 0;

    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _callDuration++;
      });
    });

  }

  /// Stop the timer
  void _stopCallTimer() {
    _callTimer?.cancel();
    _callTimer = null;
  }

  Future<void> initAgora(String channel) async {

    final socketService = Provider.of<SocketService>(context, listen: false);

    debugPrint('Initializing Agora with channel: $channel');

    // Listen for 'startaudiocall' from the server to get token/uid
    socketService.socket.on('startaudiocall', (data) {
      debugPrint('Received startaudiocall event: ${data['token']}');
    });

    // Listen for callId
    socketService.socket.on('callid_audiocall', (data) {
      debugPrint('Received callid_audiocall event: ${data['callId']}');
      CallId = data['callId'];
    });

    // Request permissions
    final permissions = await [
      Permission.microphone,
      Permission.camera,
    ].request();

    if (permissions[Permission.camera]!.isGranted &&
        permissions[Permission.microphone]!.isGranted) {
      debugPrint('Permissions granted.');

      _engine = createAgoraRtcEngine();

      try {
        await _engine.initialize(
          RtcEngineContext(appId: AGORA_APP_ID),
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
              'Local user joined channel with UID: ${connection.localUid}',
            );
            setState(() {
              // We're in the channel, but we wait for remote user to join
              _localUserJoined = false;
            });
          },
          onUserJoined: (connection, remoteUid, elapsed) {
            debugPrint('Remote user joined with UID: $remoteUid');
            setState(() {
              _remoteUid = remoteUid;
              _localUserJoined = true; // Switch to showing timer
            });
            _startCallTimer(); // start the timer when remote user joins
          },

          onUserOffline: (connection, remoteUid, reason) {
            debugPrint(
              'Remote user offline: $remoteUid, reason: $reason',
            );
            setState(() => _remoteUid = null);
            _endCall(); // or handle differently if you prefer
          },
          onError: (errorType, errorMessage) {
            debugPrint('Agora error: $errorType, $errorMessage');
          },
        ),
      );

      // Audio only
      await _engine.enableAudio();

      try {
        await _engine.joinChannel(
          token: widget.token,
          channelId: channel,
          uid: widget.uid,
          options: const ChannelMediaOptions(
            clientRoleType: ClientRoleType.clientRoleBroadcaster,
          ),
        );
        debugPrint('Joined the Agora channel successfully.');
      } catch (e) {
        debugPrint('Error joining channel: $e');
      }
    } else {
      debugPrint('Microphone or camera permission denied.');
    }
  }

  /// End the call
  void _endCall() {

    final socketService = Provider.of<SocketService>(context, listen: false);

    debugPrint('Ending call...');
    _stopCallTimer();

    if(_remoteUid != null) {
      socketService.socket.emit('endaudiocall', {
        'callId': CallId,
        'astrologerId': widget.astrologerId,
        'userId': widget.userId,
      });
      _engine.leaveChannel();
      Navigator.pop(context);
    }else{
      Navigator.pop(context);
    }
    _engine.release();

  }

  /// Toggle mute
  void _toggleMute() async {
    setState(() => _isMuted = !_isMuted);
    await _engine.muteLocalAudioStream(_isMuted);
  }

  /// Toggle speaker
  void _toggleSpeaker() async {
    setState(() => _isSpeakerOn = !_isSpeakerOn);
    await _engine.setEnableSpeakerphone(_isSpeakerOn);
  }

  @override
  void dispose() {
    super.dispose();
    if(_remoteUid != null) {
      _stopCallTimer();
      _engine.leaveChannel();
    }
    _engine.release();
  }

  /// If you truly want audio only, remove the video UI entirely
  Widget _renderLocalPreview() {
    if (_localUserJoined) {
      debugPrint('Local side joined, showing local preview.');
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: widget.uid),
        ),
      );
    } else {
      debugPrint('Not joined yet or remote user not joined.');
      return const Center(child: CircularProgressIndicator());
    }
  }

  Widget _renderRemoteVideo() {
    if (_remoteUid != null) {
      debugPrint('Showing remote video for UID: $_remoteUid');
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: widget.channleid),
        ),
      );
    } else {
      return Container(
        color: Colors.blue,
        child: const Center(
          child: Text(
            'Waiting for remote user to join',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  /// Background image helper
  Widget _buildBackgroundImage() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/img/background_home.png'),
          fit: BoxFit.cover,
        ),
      ),
      // Semi-transparent overlay
      child: Opacity(
        opacity: 0.7,
        child: Container(color: Color(0xFF1a237e)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    _buildBackgroundImage(),
                    Center(child: _renderRemoteVideo()),
                    // Local preview top-left
                    Align(
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: 100,
                        height: 150,
                        child: _renderLocalPreview(),
                      ),
                    ),
                    // Center top: Icon + call status or timer
                    Align(
                      alignment: Alignment.topCenter,
                      child: SafeArea(
                        child: SizedBox(
                          width: 140,
                          height: 140,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircleAvatar(
                                radius: 32,
                                backgroundColor: Colors.grey,
                                child: Icon(
                                  Icons.person,
                                  size: 32,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _localUserJoined
                                    ? _formattedCallDuration
                                    : 'Incoming Call...',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: _callAccepted
            // If call accepted, show Mute/Speaker/End
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton(
                      heroTag: 'muteFab',
                      backgroundColor: _isMuted ? Colors.red : Colors.grey,
                      onPressed: _toggleMute,
                      child: Icon(
                        _isMuted ? Icons.mic_off : Icons.mic,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 15),

                    FloatingActionButton(
                      heroTag: 'speakerFab',
                      backgroundColor:
                      _isSpeakerOn ? Colors.blue : Colors.grey,
                      onPressed: _toggleSpeaker,
                      child: Icon(
                        _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 15),

                    FloatingActionButton(
                      heroTag: 'endCallFab',
                      backgroundColor: Colors.red,
                      onPressed: _endCall,
                      child: const Icon(Icons.call_end, color: Colors.white),
                    ),
              ],
            )
            // If not accepted, show Accept & Decline
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Accept Call
                FloatingActionButton(
                  heroTag: 'acceptFab',
                  backgroundColor: Colors.green,
                  onPressed: () {
                    setState(() => _callAccepted = true);
                    // Trigger Agora join logic if not already
                    initAgora(widget.channleid);
                  },
                  child: const Icon(Icons.call, color: Colors.white),
                ),
                const SizedBox(width: 30),
                // Decline Call
                FloatingActionButton(
                  heroTag: 'declineFab',
                  backgroundColor: Colors.red,
                  onPressed: _endCall,
                  child: const Icon(Icons.call_end, color: Colors.white),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}
