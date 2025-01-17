import 'package:flutter/material.dart';

class CustomButtons {
  // Constants
  static const double _buttonHeight = 50.0; // Adjust this value as needed
  static const double _borderRadius = 25.0;
  static const Color textColor = Color(0xFF2D2D6C);

  static Widget saveButton({
    required VoidCallback onPressed,
    double? width,
    String text = 'SAVE',
    Color? textColor,
    double? height,
    double? borderRadius,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? _borderRadius),
        ),
        minimumSize: Size(
          width ?? double.infinity,
          height ?? _buttonHeight,
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: textColor,
        ),
      ),
    );
  }
}
