import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../forgot_pass/forget_password_bloc.dart';
import '../forgot_pass/forget_password_event.dart';
import '../forgot_pass/forget_password_state.dart';

import 'package:flutter_svg/flutter_svg.dart';

import 'otp_verify.dart';

class ForgetPasswordStyles {
  // Text Styles
  static const TextStyle headerStyle = TextStyle(
    fontFamily: 'Poppins',
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle titleStyle = TextStyle(
    fontFamily: 'Poppins',
    color: Colors.white,
    fontSize: 22,
  );

  static const TextStyle inputStyle = TextStyle(
    fontFamily: 'Poppins',
    color: Colors.white,
  );

  static const TextStyle buttonStyle = TextStyle(
    fontFamily: 'Poppins',
    color: Color(0xFF1a237e),
    fontWeight: FontWeight.normal,
    fontSize: 16,
  );

  static const TextStyle resendTextStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
  );

  static const TextStyle hintStyle = TextStyle(
    fontFamily: 'Poppins',
    color: Colors.white54,
  );

  // Layout
  static const EdgeInsetsGeometry contentPadding =
  EdgeInsets.symmetric(horizontal: 20);

  // Decorations
  static BoxDecoration getPasswordFieldDecoration() => BoxDecoration(
    color: Colors.white.withOpacity(0.1),
    borderRadius: BorderRadius.circular(25),
    border: Border.all(
      color: Colors.white,
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        spreadRadius: 1,
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
      BoxShadow(
        color: Colors.white.withOpacity(0.1),
        spreadRadius: 1,
        blurRadius: 4,
        offset: const Offset(0, -1),
      ),
    ],
  );

  static InputDecoration getPasswordInputDecoration(String hintText) =>
      InputDecoration(
        contentPadding: contentPadding,
        border: InputBorder.none,
        hintText: hintText,
        hintStyle: hintStyle,
      );

  // Constants
  static const double fieldHeight = 50.0;
  static const double borderRadius = 25.0;
  static const double borderWidth = 1.0;
}
class ChangePasswordBackgroundImage extends StatelessWidget {
  const ChangePasswordBackgroundImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Image.asset(
        'assets/img/ScreenBG.png',
        fit: BoxFit.cover,
      ),
    );
  }
}

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ForgetPasswordBloc(),
      child: Scaffold(
        body: Stack(
          children: [
            const ChangePasswordBackgroundImage(),
            SafeArea(
              child: BlocListener<ForgetPasswordBloc, ForgetPasswordState>(
                listener: (context, state) {
                  if (state is ForgetPasswordSuccess) {
                    final verificationId = state.verificationId;
                    final mobileNumber = state.mobileNumber;

                    print("Verification ID: $verificationId");
                    print("mobileNumber ID: $mobileNumber");
                    // Navigate to next screen

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OtpVerification(
                            verificationId: verificationId,
                            mobileNumber: mobileNumber),
                      ),
                    );

                    //
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   const SnackBar(content: Text("Password reset successful")),
                    // );
                    //

                  } else if (state is ForgetPasswordFailure) {

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.error)),
                    );
                  }
                },
                child: const ForgetPasswordContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class ForgetPasswordIllustration extends StatelessWidget {
  const ForgetPasswordIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SvgPicture.asset(
        'assets/SVG/changePasswordIllustration.svg',
        fit: BoxFit.contain,
      ),
    );
  }
}

class ForgetPasswordContent extends StatelessWidget {
  const ForgetPasswordContent({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController phoneController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const ForgetPasswordIllustration(),
          const SizedBox(height: 20),
          const Text(
            'Forgot Password?',
            style: ForgetPasswordStyles.titleStyle,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            style: ForgetPasswordStyles.inputStyle,
            decoration: ForgetPasswordStyles.getPasswordInputDecoration(
              'Enter Your Phone Number',
            ),
          ),
          const SizedBox(height: 20),

          BlocBuilder<ForgetPasswordBloc, ForgetPasswordState>(

            builder: (context, state) {

              if (state is ForgetPasswordLoading) {

                return const CircularProgressIndicator();

              }

              return ForgetPasswordContinueButton(

                onTap: () {

                  final phoneNumber = phoneController.text;

                  if (phoneNumber.isNotEmpty) {

                    context.read<ForgetPasswordBloc>().add(SubmitPhoneNumber(phoneNumber));

                  } else {

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please enter a valid phone number.")),
                    );

                  }
                },
              );
            },

          ),
        ],
      ),
    );
  }
}

class ForgetPasswordContinueButton extends StatelessWidget {
  final VoidCallback onTap;

  const ForgetPasswordContinueButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 4,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'CONTINUE',
              style: ForgetPasswordStyles.buttonStyle,
            ),
          ),
        ),
      ),
    );
  }
}
