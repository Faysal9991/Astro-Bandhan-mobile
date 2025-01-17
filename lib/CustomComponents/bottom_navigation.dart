import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNavigator {
  static Widget bottomNavigationBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color.fromRGBO(170, 255, 0, 0.8),
            Color.fromRGBO(60, 0, 255, 0.8),
          ],
        ),
      ),
      height: 83,
      child: BottomNavigationBar(
        backgroundColor: const Color(0xFF1a237e).withOpacity(0.4),
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
