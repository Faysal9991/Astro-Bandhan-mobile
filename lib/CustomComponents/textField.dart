import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField {
  static Widget textField({
    required String hintText,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white,
          width: 1,
        ),
      ),
      child: Center(
        child: SizedBox(
          width: double.infinity,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: isPassword,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
            inputFormatters: inputFormatters,
            maxLength: maxLength,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Colors.white54,
                fontFamily: 'Poppins',
              ),
              // Remove counter text for maxLength
              counterText: '',
            ),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  // Preset configurations for common use cases
  static Widget phoneTextField({
    String hintText = 'Phone Number',
    void Function(String)? onChanged, required TextEditingController controller,
  }) {
    return textField(
      hintText: hintText,
      keyboardType: TextInputType.phone,
      controller: controller,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      onChanged: onChanged,
    );
  }

  static Widget passwordTextField({
    String hintText = 'Enter Password',
    void Function(String)? onChanged, required TextEditingController controller,
  }) {
    return textField(
      controller: controller,
      hintText: hintText,
      isPassword: true,
      onChanged: onChanged,
    );
  }

  static Widget emailTextField({
    String hintText = 'Enter Email',
    void Function(String)? onChanged,
  }) {
    return textField(
      hintText: hintText,
      keyboardType: TextInputType.emailAddress,
      onChanged: onChanged,
    );
  }
}
