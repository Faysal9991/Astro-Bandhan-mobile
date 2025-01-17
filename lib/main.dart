import 'package:astrologerapp/Home/TabScreen.dart';
import 'package:astrologerapp/Home/home.dart';
import 'package:astrologerapp/helper/navigator_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Home/BottomBar.dart';
import 'Home/SocketService.dart';
import 'Home/audiocall/call_bloc.dart';
import 'Home/tab_bloc.dart';
import 'NotificationService.dart';
import 'Welcome/splash.dart';
import 'chat_provider.dart';
import 'chatting/ChatListBloc.dart';
import 'chatting/NotificationHandler.dart';
import 'chatting/chat_repository.dart';
import 'dio/dio_client.dart'; // Import the DioClient singleton class

Future<void> main() async {


  WidgetsFlutterBinding.ensureInitialized();

  // Initialize DioClient
  DioClient.instance.init();

  // Load shared preferences
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final String? userId = prefs.getString('astrologer_id');

  runApp(MyApp(isLoggedIn: isLoggedIn, userId: userId));
}

class MyApp extends StatelessWidget {

  final bool isLoggedIn;
  final String? userId;

  const MyApp({required this.isLoggedIn, required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
    final callBloc = CallBloc();

    return MultiProvider(
      providers: [
        BlocProvider<TabBloc>(
          create: (context) => TabBloc(),
        ),
        BlocProvider(create: (_) => callBloc),
        BlocProvider<ChatListBloc>(
          create: (context) => ChatListBloc(ChatRepository(Dio()))..add(FetchChatList()),
        ),
        // Provide NotificationService
        Provider<NotificationService>(
          create: (_) => NotificationService(),
        ),

        // Provide ChatProvider
        ChangeNotifierProvider<ChatProvider>(
          create: (_) => ChatProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => NotificationHandler(),
        ),


        // Provide SocketService with dependencies
        ProxyProvider<NotificationService, SocketService>(
          update: (_, notificationService, previousSocketService) {
            final callBloc = CallBloc();
            final socketService = previousSocketService ?? SocketService(userId ?? "", notificationService,callBloc);
            if (!socketService.socket.connected) {
              socketService.connect(userId ?? "",context); // Connect the socket
            }
            return socketService;
          },
          dispose: (_, socketService) => socketService.disconnect(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: Helper.navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.transparent,
        ),
        home: isLoggedIn ?  TabScreen() : const SplashScreen(),
      ),
    );
  }

}
