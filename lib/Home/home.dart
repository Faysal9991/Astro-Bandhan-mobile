
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Agora/VideoCallScreen.dart';
import '../Auth/LoginScreen.dart';
import '../dio/Constant.dart';
import '../dio/dio_client.dart';
import 'AstrologerModel.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Dio dio = DioClient.instance.getDio();
  List<Astrologer> astrologers = [];
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Background image
                _buildBackgroundImage(),
                // App content
                _buildAppContent(context),
              ],
            ),
          ),
        ],
      ),

    );
  }

  Widget _buildBackgroundImage() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/img/background_home.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Opacity(
        opacity: 0.7, // Adjust opacity between 0.0 (transparent) to 1.0 (opaque)
        child: Container(color: const Color(0xFF1a237e)), // Adds a semi-transparent overlay
      ),
    );
  }

  Widget _buildAppContent(BuildContext context) {

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // const SizedBox(height: 20),
              // _buildAppBar(context),

              InkWell(
                onTap: () {

                },
              child: Text("Connect Video",style: TextStyle(color: Colors.white,fontSize: 22),)),
              const SizedBox(height: 15),
              // _buildFeatureGrid(),
              const SizedBox(height: 5),
              // _buildSection('Top Astrologer', isViewAll: true),
              const SizedBox(height: 3),
              // _buildAstrologerList(astrologers),
              const SizedBox(height: 10),
              // _buildAstroBandhanButton(),
              const SizedBox(height: 10),
              // _buildSection('Live Now'),
              const SizedBox(height: 10),
              // _buildLiveAstrologerList(),
              const SizedBox(height: 10),
              // _buildAutoSuggestCard(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
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
                _buildAppBarIcon('assets/SVG/Search.svg', onPressed: () {}),
                const SizedBox(width: 5),
                _buildAppBarIcon('assets/SVG/wallet.svg', onPressed: () {}),
                const SizedBox(width: 5),
                _buildAppBarIcon('assets/SVG/Bell.svg', onPressed: () {}),
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

  Widget _buildFeatureGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildFeatureItem('assets/SVG/Kundli.svg', 'Kundli'),
        _buildFeatureItem('assets/SVG/Matching.svg', 'Matching'),
        _buildFeatureItem('assets/SVG/Horoscope.svg', 'Horoscope'),
        _buildFeatureItem('assets/SVG/AstroMall.svg', 'AstroMall'),
      ],
    );
  }

  Widget _buildFeatureItem(String iconPath, String label) {
    return Column(
      children: [
        _buildFeatureItemContainer(iconPath),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildFeatureItemContainer(String iconPath) {
    return Container(
      height: 75.522,
      width: 75.522,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color.fromRGBO(170, 255, 0, 0.32),
            Color.fromRGBO(60, 0, 255, 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Opacity(
        opacity: 1,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1a237e),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: SvgPicture.asset(iconPath),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, {bool isViewAll = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (isViewAll)
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Icon(Icons.chevron_right, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAstrologerList(List<Astrologer> astrologers) {

      return SizedBox(
        height: 90,
        width: double.infinity,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: astrologers.length,
          itemBuilder: (context, index) {
            return _buildAstrologerItem(astrologers[index]);
          },
        ),
      );

    // return SizedBox(
    //   height: 90,
    //   width: double.infinity,
    //   child: ListView.builder(
    //     scrollDirection: Axis.horizontal,
    //     itemCount: 4,
    //     itemBuilder: (context, index) {
    //       return _buildAstrologerItem();
    //     },
    //   ),
    // );
  }

  Widget _buildAstrologerItem(Astrologer astrologer) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0, top: 0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[300],
            child: Image.network("${astrologer.avatar}"),
          ),
          SizedBox(height: 8),
          Text(
            "${astrologer.name}",
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildAstroBandhanButton() {
    return Container(
      width: double.infinity,
      height: 150,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6A800),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Image.asset(
        'assets/img/astroBandhan.png',
        fit: BoxFit.scaleDown,
      ),
    );
  }

  Widget _buildLiveAstrologerList() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        itemBuilder: (context, index) {
          return _buildLiveAstrologerItem();
        },
      ),
    );
  }

  Widget _buildLiveAstrologerItem() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          Stack(
            children: [
              const CircleAvatar(
                radius: 35,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 40),
              ),
              Positioned(
                left: 18,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Live',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Your Name',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoSuggestCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color.fromRGBO(170, 255, 0, 0.32),
            Color.fromRGBO(60, 0, 255, 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildAutoSuggestImage(),
          const SizedBox(width: 16),
          Expanded(
            child: _buildAutoSuggestContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoSuggestImage() {
    return Image.asset(
      'assets/img/OBJECTS.png',
      width: 97,
      height: 86,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 60,
          height: 60,
          color: Colors.blue[800],
          child: const Icon(
            Icons.question_mark,
            color: Colors.white,
            size: 40,
          ),
        );
      },
    );
  }

  Widget _buildAutoSuggestContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Not sure Whom To Connect?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
          child: const Text('AUTO SUGGEST'),
        ),
      ],
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
}



