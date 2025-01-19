import 'dart:ui';

import 'package:astrologerapp/Agora/AudioCallScreen.dart';
import 'package:astrologerapp/ChatScreen.dart';
import 'package:astrologerapp/Home/audiocall/widget/custom_container.dart';
import 'package:astrologerapp/Home/tab_bloc.dart';
import 'package:astrologerapp/Home/tab_event.dart';
import 'package:astrologerapp/Home/tab_state.dart';
import 'package:astrologerapp/Wallet/wallet_screen.dart';
import 'package:astrologerapp/chatting/ChatListScreen.dart';
import 'package:astrologerapp/helper/navigator_helper.dart';
import 'package:astrologerapp/userState/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class TabScreen extends StatefulWidget {
  const TabScreen({super.key});

  @override
  State<TabScreen> createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userCubit = context.read<UserCubit>();

      userCubit.userinfo();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Map icons = {
      "Chat Request": "assets/SVG/chat.svg",
      "Call Request": "assets/SVG/call.svg",
      "Video Call Request": "assets/SVG/video_call.svg",
      "Gift Received": "assets/SVG/gift.svg"
    };

    return Scaffold(
      key: _scaffoldKey, // Add this line to connect the GlobalKey
      backgroundColor: Color(0xff0F0F55),
      drawer: BlocBuilder<UserCubit, UserState>(builder: (context, state) {
        return CustomDrawer(
          userState: state,
        );
      }),

      body: BlocBuilder<UserCubit, UserState>(builder: (context, state) {
     
        if (state.isLoading) {
          return Column(
            children: [
              Center(child: CircularProgressIndicator()),
            ],
          );
        }
        if (state.isSuccess) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 15,
                children: [
                 Row(
                      children: [
                        glassContainer(
                            isBorder: false,
                            height: 30,
                            width: 88,
                            context,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Row(
                                children: [
                                  Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                        color:      userInfoModel.isOffline!?Colors.white:Colors.green,
                                        shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 5),
                                   Text(
                                   userInfoModel.isOffline!? "Offline":"online",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Inter',
                                      fontSize: 16,
                                      fontStyle: FontStyle.normal,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        Spacer(),
                        IconButton(
                          icon: SvgPicture.asset(
                            "assets/SVG/Bell.svg",
                            height: 22,
                          ),
                          onPressed: () {
                            // Handle bell icon press
                          },
                        ),
                        IconButton(
                          icon: SvgPicture.asset(
                            "assets/SVG/Menu.svg",
                            height: 22,
                          ),
                          onPressed: () {
                            _scaffoldKey.currentState?.openDrawer();
                          },
                        ),
                      ],
                    ),
                 
                  InkWell(
                    onTap: () {
                      Helper.toScreen(WalletScreen(presentblance: userInfoModel.walletBalance.toString(),));
                    },
                    child: glassContainer(context,
                        height: 122,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                "assets/SVG/doller.svg",
                                height: 64,
                                width: 51,
                              ),
                              Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Available Balance",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Inter',
                                      fontSize: 16,
                                      fontStyle: FontStyle.normal,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    "₹${userInfoModel.walletBalance}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Poppins',
                                      fontSize: 32,
                                      fontStyle: FontStyle.normal,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        )),
                  ),
                  SizedBox(
                    height: 130,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: icons.length,
                        itemBuilder: (context, index) {
                          // Convert map to list for indexed access
                          final iconEntry = icons.entries.elementAt(index);

                          return Padding(
                            padding: EdgeInsets.only(left: index == 0 ? 0 : 15),
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    switch (index) {
                                      // Use lowercase 'switch'
                                      case 0:
                                        Helper.toScreen(ChatListScreen());
                                        break;
                                      case 1:
                                        //  Helper.toScreen(AudioCallScreen());
                                        break;
                                      case 2:
                                        break;
                                      case 3:
                                        break;
                                      default:
                                        // Handle other cases or do nothing
                                        break; // Optionally include a break in the default case
                                    }
                                  },
                                  child: glassContainer(context,
                                      height: 70,
                                      width: 70,
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: SvgPicture.asset(
                                          iconEntry
                                              .value, // Access the value (path)
                                        ),
                                      )),
                                ),
                                const SizedBox(
                                    height:
                                        10), // Replace 'spacing' with proper spacing widget
                                SizedBox(
                                  width: 70,
                                  child: Text(
                                    textAlign: TextAlign.center,
                                    iconEntry.key, // Access the key (label)
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          );
                        }),
                  ),
                  Text(
                    textAlign: TextAlign.center,
                    "Recent Activity:", // Access the key (label)
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  glassContainer(
                      height: 110,
                      context,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          spacing: 10,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  "assets/SVG/Bell.svg",
                                  height: 15,
                                  width: 15,
                                ),
                                const SizedBox(width: 10),
                                Text("Placerat interdum netus",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      fontFamily: "Poppins",
                                      color: Colors.white,
                                    ))
                              ],
                            ),
                            Text(
                                textAlign: TextAlign.center,
                                "Curabitur ridiculus dis massa eu arcu interdum posuere condimentum! Praesent maecenas.",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  fontFamily: "Inter",
                                  color: Colors.white,
                                ))
                          ],
                        ),
                      ))
                ],
              ),
            ),
          );
        } else {
          return Container(
            color: Colors.white,
            child: Center(
              child: Text("Loading..."),
            ),
          );
        }
      }),
    );
  }
}

class CustomDrawer extends StatelessWidget {
  final UserState userState;
  const CustomDrawer({super.key, required this.userState});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white.withOpacity(0.2),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(top: 60, left: 20, right: 20),
            child: Column(
              spacing: 20,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 12,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey[300],
                        child: Image.network("${userInfoModel.avatar}"),
                      ),
                    ),
                     Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${userInfoModel.name}',
                            style: TextStyle(
                              fontFamily: "Poppins",
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${userInfoModel.phone}',
                            style: TextStyle(
                              fontFamily: "Inter",
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SvgPicture.asset("assets/SVG/back.svg")
                  ],
                ),
                Divider(
                  color: Colors.white,
                  thickness: 1,
                ),
                DrawerListTile(
                  icon: "assets/SVG/home.svg",
                  title: 'Home',
                  onTap: () {
                    // Handle home tap
                  },
                ),
                DrawerListTile(
                  icon: "assets/SVG/update.svg",
                  title: 'Update Your App',
                  onTap: () {
                    // Handle update tap
                  },
                ),
                DrawerListTile(
                  icon: "assets/SVG/shere.svg",
                  title: 'Share Your App',
                  onTap: () {
                    // Handle share tap
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onTap;

  const DrawerListTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          SvgPicture.asset(
            icon,
            height: 18,
            width: 18,
          ),
          SizedBox(
            width: 20,
          ),
          Text(
            title,
            style: TextStyle(
              fontFamily: "Inter",
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          )
        ],
      ),
    );
  }
}


// class TabScreen extends StatefulWidget {
//   const TabScreen({super.key});

//   @override
//   State<TabScreen> createState() => _TabScreenState();
// }

// class _TabScreenState extends State<TabScreen> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xff0F0F55),
//       appBar: AppBar(

//         bottom: PreferredSize(
//           preferredSize: Size.fromHeight(0), // Adjust height of navigation bar
//           child: BlocBuilder<TabBloc, TabState>(
//             builder: (context, state) {
//               return Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   _buildTopNavigationItem(
//                     context,
//                     tab: TabItem.home,
//                     icon: Icons.chat,
//                     label: 'Chat',
//                     isSelected: state.selectedTab == TabItem.home,
//                   ),
//                   _buildTopNavigationItem(
//                     context,
//                     tab: TabItem.search,
//                     icon: Icons.call,
//                     label: 'Call',
//                     isSelected: state.selectedTab == TabItem.search,
//                   ),
//                   _buildTopNavigationItem(
//                     context,
//                     tab: TabItem.profile,
//                     icon: Icons.video_call,
//                     label: 'Video',
//                     isSelected: state.selectedTab == TabItem.profile,
//                   ),
//                 ],
//               );
//             },
//           ),
//         ),
//       ),
//       body: BlocBuilder<TabBloc, TabState>(
        
//         builder: (context, state) {
//           switch (state.selectedTab) {
//             case TabItem.home:
//               return ChatListScreen();
//             case TabItem.search:
//               return AudioCallScreen();
//             case TabItem.profile:
//               return Center(child: Text('Profile Screen'));
//           }
//         },
//       ),
      
//     );
//   }

//   Widget _buildTopNavigationItem(
//     BuildContext context, {
//     required TabItem tab,
//     required IconData icon,
//     required String label,
//     required bool isSelected,
//   }) {
//     return GestureDetector(
//       onTap: () {
//         context.read<TabBloc>().add(TabChanged(tab));
//       },
//       child: Container(
//         width: 80, // Adjust width for consistent spacing
//         alignment: Alignment.center, // Center content
//         child: Column(
//           mainAxisSize: MainAxisSize.min, // Minimize space vertically
//           mainAxisAlignment:
//               MainAxisAlignment.center, // Center content vertically
//           children: [
//             Icon(
//               icon,
//               size: 24, // Adjust icon size if needed
//               color: isSelected ? Colors.blue : Colors.grey,
//             ),
//             SizedBox(height: 4), // Optional space between icon and label
//             Text(
//               label,
//               style: TextStyle(
//                 color: isSelected ? Colors.blue : Colors.grey,
//                 fontSize: 12,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
