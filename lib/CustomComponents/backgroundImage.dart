import 'package:flutter/material.dart';

class BackgroundImage extends StatelessWidget {
  const BackgroundImage({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildBackgroundImage(context);
  }

  Widget _buildBackgroundImage(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/img/background_home.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        color: const Color(0xFF1a237e).withOpacity(0.9),
      ),
    );
  }
}
