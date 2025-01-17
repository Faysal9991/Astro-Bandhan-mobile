import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'SocketService.dart';

class AudioCallScreen extends StatefulWidget {
  const AudioCallScreen({super.key});

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.socket.on('chatEnded', (data) {
      print('Chat Endedxxxx: ${data['chatRoomId']}');

    });

    return const Placeholder();
  }
}
