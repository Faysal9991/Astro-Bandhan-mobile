import 'package:astrologerapp/Home/BottomBar.dart';
import 'package:astrologerapp/Home/TabScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../AccountState/LoginCubit.dart';
import '../CustomComponents/appbar.dart';
import '../CustomComponents/custom_button.dart';
import '../CustomComponents/textField.dart';
import '../Home/home.dart';
import 'create_account.dart';
import 'forget_password.dart';
import 'otp_verify.dart';
class LoginScreen extends StatelessWidget {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(),
      child: Scaffold(
        backgroundColor: Color(0xff0F0F55),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                10.0,
                0,
                10.0,
                MediaQuery.of(context).viewInsets.bottom + 24.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top content
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        AppBarWidget(title: 'LOGIN'),
                        const SizedBox(height: 60),
                        CustomTextField.phoneTextField(
                          hintText: 'Your Mobile',
                          controller: phoneController,
                        ),
                        const SizedBox(height: 10),
                        CustomTextField.passwordTextField(
                          hintText: 'Your Password',
                          controller: passwordController,
                        ),
                        const SizedBox(height: 24),
                        BlocConsumer<LoginCubit, LoginState>(
                          listener: (context, state) async {
                            if (state.isSuccess) {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setBool('isLoggedIn', true);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TabScreen()),
                              );
                            } else if (state.errorMessage != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('${state.errorMessage}')),
                              );
                            }
                          },
                          builder: (context, state) {
                            if (state.isLoading) {
                              return Center(child: CircularProgressIndicator());
                            }
                            return CustomButtons.saveButton(
                              onPressed: () {
                                context.read<LoginCubit>().login(
                                    phoneController.text,
                                    passwordController.text.trim());
                              },
                              text: 'LOGIN',
                            );
                          },
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: _buildOutlinedButton(
                            'Forgot Password?',
                            () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ForgetPasswordScreen()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            Expanded(
                                child: Divider(
                                    color: Colors.white.withOpacity(0.5))),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Or',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ),
                            Expanded(
                                child: Divider(
                                    color: Colors.white.withOpacity(0.5))),
                          ],
                        ),
                        const SizedBox(height: 30),
                        CustomButtons.saveButton(
                            onPressed: () {}, text: 'LOGIN WITH OTP'),
                      ],
                    ),
                    // Bottom content
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          _buildOutlinedButton(
                            'Sign Up',
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateAccount(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        resizeToAvoidBottomInset: true,
      ),
    );
  }

  Widget _buildOutlinedButton(String text, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide.none,
        foregroundColor: Colors.white,
        padding: EdgeInsets.zero,
        textStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontFamily: 'Poppins',
          decoration: TextDecoration.underline,
        ),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }
}
