import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../forgot_pass/otp_bloc.dart';
import '../forgot_pass/otp_event.dart';
import '../forgot_pass/otp_state.dart';
import 'LoginScreen.dart';

class OtpVerificationStyles {
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
}

class OtpVerification extends StatelessWidget {
  final String verificationId;
  final String mobileNumber;

  const OtpVerification({
    super.key,
    required this.verificationId,
    required this.mobileNumber
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OtpBloc(),
      child: OtpScreen(
        verificationId: verificationId, // Pass the verificationId
        mobileNumber: mobileNumber, // Pass the mobileNumber
      ),
    );
  }
}

class OtpScreen extends StatelessWidget {

  final String verificationId;
  final String mobileNumber;

  // Constructor to accept the parameters
  const OtpScreen({
    super.key,
    required this.verificationId, // Accept verificationId
    required this.mobileNumber,   // Accept mobileNumber
  });



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const OtpBackgroundImage(),
          SafeArea(
            child: BlocListener<OtpBloc, OtpState>(
              listener: (context, state) {
                if (state is OtpSuccess) {

                  BlocProvider.of<OtpBloc>(context).add(OtpShowPasswordFieldsEvent());
                  // Navigator.pushReplacement(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => LoginScreen(),
                  // ));

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('OTP Verified!')),
                  );

                } else if (state is OtpFailure) {

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.error)),
                  );
                }

                if (state is PasswordResetSuccess) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),
                  ));
                }
              },
              child: OtpContentContainer(verificationId: verificationId,mobileNumber: mobileNumber),
            ),
          ),
        ],
      ),
    );
  }

}


// Background Image
class OtpBackgroundImage extends StatelessWidget {
  const OtpBackgroundImage({super.key});

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
class OtpContentContainer extends StatefulWidget {
  final String verificationId;
  final String mobileNumber;

  const OtpContentContainer({
    super.key,
    required this.verificationId,
    required this.mobileNumber,
  });

  @override
  State<OtpContentContainer> createState() => _OtpContentContainerState();
}

class _OtpContentContainerState extends State<OtpContentContainer> {
  final TextEditingController otpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OtpBloc, OtpState>(
      builder: (context, state) {

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const OtpIllustration(),
              const SizedBox(height: 30),
              const OtpTitle(),
              const SizedBox(height: 24),
              if (state is! OtpShowPasswordFields) ...[
                OtpInputFields(controller: otpController),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    final otp = otpController.text;
                      context.read<OtpBloc>().add(OtpEntered(otp, widget.verificationId, widget.mobileNumber),
                    );
                  },
                  child: const OtpContinueButton(),
                ),
              ],
              if (state is OtpShowPasswordFields) ...[
                PasswordInputField(
                  controller: passwordController,
                  hintText: 'Enter Password',
                ),
                const SizedBox(height: 16),
                PasswordInputField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    final password = passwordController.text;
                    final confirmPassword = confirmPasswordController.text;

                    if (password.isEmpty || confirmPassword.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All fields are required.'),
                        ),
                      );
                      return;
                    }

                    if (password != confirmPassword) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Passwords do not match!'),
                        ),
                      );
                      return;
                    }

                    // Call API with password and confirm password
                    context.read<OtpBloc>().add(
                      PasswordSubmitEvent(widget.mobileNumber,password,confirmPassword),
                    );
                  },
                  child: const Text('Submit'),
                ),
              ],
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () =>
                    context.read<OtpBloc>().add(OtpResendRequested()),
                child: const OtpResendSection(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class PasswordInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const PasswordInputField({
    super.key,
    required this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class OtpInputFields extends StatelessWidget {
  final TextEditingController controller;

  const OtpInputFields({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: 4,
      style: OtpVerificationStyles.inputStyle,
      textAlign: TextAlign.center,
      decoration: const InputDecoration(
        counterText: '',
        hintText: 'Enter OTP',
        border: OutlineInputBorder(),
      ),
    );
  }
}


// Screen Header
class OtpHeader extends StatelessWidget {
  const OtpHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        const Expanded(
          child: Text(
            'OTP VERIFICATION',
            style: OtpVerificationStyles.headerStyle,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}

// Graphic Image
class OtpIllustration extends StatelessWidget {
  const OtpIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SvgPicture.asset(
        'assets/SVG/IllustrationOTP.svg',
        fit: BoxFit.contain,
      ),
    );
  }
}

// Title Text
class OtpTitle extends StatelessWidget {
  const OtpTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Otp Verification',
      style: OtpVerificationStyles.titleStyle,
      textAlign: TextAlign.start,
    );
  }
}

// OTP Text Fields


class OtpInputField extends StatelessWidget {
  const OtpInputField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      width: 78,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white,
          width: 1,
        ),
      ),
      child: const TextField(
        keyboardType: TextInputType.phone,
        style: OtpVerificationStyles.inputStyle,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

//Continue Button
class OtpContinueButton extends StatelessWidget {
  const OtpContinueButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: const Center(
        child: Text(
          'CONTINUE',
          style: OtpVerificationStyles.buttonStyle,
        ),
      ),
    );
  }
}

// OTP Resend Section
class OtpResendSection extends StatelessWidget {
  const OtpResendSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'If you do not receive the code!',
            style: OtpVerificationStyles.resendTextStyle.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(width: 5),
          RichText(
            text: TextSpan(
              text: 'Resend',
              style: OtpVerificationStyles.resendTextStyle.copyWith(
                color: Colors.white,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
