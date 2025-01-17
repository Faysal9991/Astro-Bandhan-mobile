import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Agora/VideoCallScreen.dart';
import '../Auth/LoginScreen.dart';
import '../chatting/ChatListBloc.dart';
import '../chatting/ChatListScreen.dart';
import '../Home/home.dart';
import '../NotificationService.dart';
import 'SocketService.dart';
import 'TabScreen.dart';
import 'audiocall/call_bloc.dart';

class BottomBar extends StatefulWidget {

  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();

}

class _BottomBarState extends State<BottomBar> {

  late SocketService socketService;

  int _selectedIndex = 0;
  late final NotificationService notificationService;
  String user_id="";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Initialize NotificationService

    notificationService = NotificationService();
    notificationService.initialize(); // Ensure this is called to set up notifications
    requestNotificationPermission();

    getuserid();

  }

  final List<Widget> _screens = [
    TabScreen(),
    HomeScreen(),
    const HomeScreen(),
    const HomeScreen(),
    const HomeScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildAppBar(context),
        backgroundColor: Colors.indigo, // Adjust app bar color if needed
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: Colors.white),// Disable default leading icon
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.indigo,
              ),
              child: const Text(
                'Astrologer',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                // Navigate to Home
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                // Navigate to Settings
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                // Handle logout

                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isLoggedIn', false);

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                      (route) => false, // This removes all the routes below the new route.
                );

                // Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        Text(""),
        Row(
          children: [
            const SizedBox(width: 15),
            _buildAppBarIcon('assets/SVG/Search.svg', onPressed: () {

              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => SearchScreen()),
              // );

            }),
            const SizedBox(width: 5),
            _buildAppBarIcon('assets/SVG/wallet.svg', onPressed: () {
              //
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => WalletScreen()),
              // );

            }),
            const SizedBox(width: 5),
            _buildAppBarIcon('assets/SVG/Bell.svg', onPressed: () {
              //
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => NotificationScreen()),
              // );


            }),
          ],
        ),
      ],
    );
  }

  Widget _buildAppBarIcon(String iconPath, {VoidCallback? onPressed}) {
    return IconButton(
      icon: SvgPicture.asset(
        iconPath,
        color: Colors.white,
        width: 22,
        height: 22,
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color.fromRGBO(170, 255, 0, 0.32),
            Color.fromRGBO(60, 0, 255, 0.4),
          ],
        ),
      ),
      height: 93,
      child: BottomNavigationBar(
        backgroundColor: Colors
            .transparent, // Set transparent to let the gradient show through
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[400],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            _onItemTapped(index);
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/SVG/home.svg',
              width: 28,
              height: 28,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/SVG/Ai.svg',
              width: 28,
              height: 28,
            ),
            label: 'AI Astro',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/SVG/live.svg',
              width: 28,
              height: 28,
            ),
            label: 'Live',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/SVG/ask.svg',
              width: 28,
              height: 28,
            ),
            label: 'Ask',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/SVG/history.svg',
              width: 28,
              height: 28,
            ),
            label: 'History',
          ),
        ],
      ),
    );
  }
  Future<void> requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
    getuserid();
  }

  Future<void> getuserid() async {

    final prefs = await SharedPreferences.getInstance();

    final userId = prefs.getString('astrologer_id');
    final notificationService = NotificationService();

    final callBloc = CallBloc();

    // Initialize SocketService
    socketService = SocketService(userId ?? '', notificationService,callBloc);

    // Connect to socket server
    WidgetsBinding.instance.addPostFrameCallback((_) {
      socketService.connect(userId ?? '', context);
    });

    print("object");
    notificationService.showNotification(
      'Welcome',
      'You have successfully logged in!',
    );

  }
}
