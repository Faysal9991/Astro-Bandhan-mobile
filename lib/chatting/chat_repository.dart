import 'package:astrologerapp/chatting/ChatListBloc.dart';
import 'package:astrologerapp/dio/Constant.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatRepository {
  final Dio dio;

  ChatRepository(this.dio);

  Future<List<dynamic>> fetchChatRooms() async {

    final prefs = await SharedPreferences.getInstance();

    final userId = prefs.getString('astrologer_id');

    print(userId);

    try {

      Map<String, dynamic> data = {
        'astrologerId': userId,
      };

      final response = await dio.post('${base_upi1}/activechatroom',data: data);

      if (response.statusCode == 200) {
        print("response_data");
        print(response.data);

        return response.data['data'];

      } else {

        throw Exception('Failed to load chat rooms');

      }
    } catch (e) {

      throw Exception('Error fetching chat rooms: $e');

    }
  }
}


