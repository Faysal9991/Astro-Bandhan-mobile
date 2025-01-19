import 'package:astrologerapp/Home/SocketService.dart';
import 'package:astrologerapp/Home/TabScreen.dart';
import 'package:astrologerapp/Home/audiocall/call_bloc.dart';
import 'package:astrologerapp/Home/tab_bloc.dart';
import 'package:astrologerapp/NotificationService.dart';
import 'package:astrologerapp/Wallet/walate%20state/walate_state.dart';
import 'package:astrologerapp/Wallet/walate%20state/withdraw_state.dart';
import 'package:astrologerapp/Welcome/splash.dart';
import 'package:astrologerapp/chat_provider.dart';
import 'package:astrologerapp/chatting/ChatListBloc.dart';
import 'package:astrologerapp/chatting/NotificationHandler.dart';
import 'package:astrologerapp/chatting/chat_repository.dart';
import 'package:astrologerapp/dio/dio_client.dart';
import 'package:astrologerapp/helper/navigator_helper.dart';
import 'package:astrologerapp/userState/user_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ... other imports remain the same

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
    
    final callBloc = CallBloc();

    return MultiBlocProvider(
      providers: [
        BlocProvider<TabBloc>(
          create: (context) => TabBloc(),
        ),
        BlocProvider<CallBloc>(
          create: (_) => callBloc,
        ),
        BlocProvider<ChatListBloc>(
          create: (context) =>
              ChatListBloc(ChatRepository(Dio()))..add(FetchChatList()),
        ),
        // Add UserCubit as BlocProvider instead of ChangeNotifierProvider
        BlocProvider<UserCubit>(
          create: (context) => UserCubit(),
        ),
         BlocProvider<WalateCubit>(
          create: (context) => WalateCubit(),
        ),
           BlocProvider<WithdrawCubit>(
          create: (context) => WithdrawCubit(),
        ),
      ],
      child: MultiProvider(
        providers: [
          // Regular providers for non-bloc state management
          Provider<NotificationService>(
            create: (_) => NotificationService(),
          ),
          ChangeNotifierProvider<ChatProvider>(
            create: (_) => ChatProvider(),
          ),
          ChangeNotifierProvider<NotificationHandler>(
            create: (_) => NotificationHandler(),
          ),
          // Socket service with dependencies
          ProxyProvider<NotificationService, SocketService>(
            update: (_, notificationService, previousSocketService) {
              final socketService = previousSocketService ??
                  SocketService(userId ?? "", notificationService, callBloc);
              if (!socketService.socket.connected) {
                socketService.connect(userId ?? "", context);
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
          home: isLoggedIn ? const TabScreen() : const SplashScreen(),
        ),
      ),
    );
  }
}
