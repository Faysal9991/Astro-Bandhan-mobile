import 'package:astrologerapp/Home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../AccountState/CreateAccountState.dart';
import '../CustomComponents/appbar.dart';
import '../CustomComponents/custom_button.dart';
import '../CustomComponents/textField.dart';
import 'package:intl/intl.dart';
import '../Home/BottomBar.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emalController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController placeOfBirthController = TextEditingController();
  final TextEditingController timeOfBirthController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String selectedGender = 'Male';
  DateTime? _selectedDate;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateAccountCubit(),
      child: BlocConsumer<CreateAccountCubit, CreateAccountState>(
        listener: (context, state) async {
          if (state.accountCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Account created successfully!')),
            );
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isLoggedIn', true);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          } else if (state.isError!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.isError}')),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
           backgroundColor:Color(0xff0F0F55),
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
                        const SizedBox(height: 20),
                        const AppBarWidget(title: 'CREATE ACCOUNT'),
                        const SizedBox(height: 30),
                      _buildForm(context,
                            cubit: context.read<CreateAccountCubit>()),
                        const SizedBox(height: 30),
                        if (state.isLoading)
                          const Center(child: CircularProgressIndicator())
                        else
                          CustomButtons.saveButton(
                            onPressed: () {
                              if (_selectedDate != null) {
                                context.read<CreateAccountCubit>().createAccount(
                                  nameController.text,
                                  emalController.text,
                                  phoneController.text,
                                  _dateFormat.format(_selectedDate!),
                                  selectedGender,
                                  placeOfBirthController.text,
                                  timeOfBirthController.text,
                                  passwordController.text,
                                );
                              }
                            },
                            text: 'CREATE NOW',
                          ),
                        const SizedBox(height: 40),
                        _buildLoginLink(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }



    Widget _buildForm(BuildContext context, {required CreateAccountCubit cubit}) {
    final cubit = context.read<CreateAccountCubit>();
    return BlocBuilder<CreateAccountCubit, CreateAccountState>(
      builder: (context, state) {
        print('Cubit instance: $cubit');
        return Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLabel('Name'),
              CustomTextField.textField(
                hintText: 'Your Name',
                controller: nameController,
              ),
              const SizedBox(height: 16),
              _buildLabel('Email'),
              CustomTextField.textField(
                hintText: 'Your Email',
                controller: emalController,
              ),
              const SizedBox(height: 16),
              _buildLabel('Phone Number'),
              CustomTextField.phoneTextField(
                hintText: 'Your Phone Number',
                controller: phoneController,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('D.O.B'),

                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: Container(
                              height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  _selectedDate != null
                                      ? _dateFormat.format(_selectedDate!)
                                      : "Select Date",
                                  style: TextStyle(
                                      fontSize: 16.0, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                        //
                        // _buildDropdownField(
                        //   hint: 'D.O.B',
                        //   value: dobController.text,
                        //   onChanged: (value) => dobController.text = value!,
                        // ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Gender'),
                        _buildDropdownField(
                          hint: 'Gender',
                          items: ['Male', 'Female', 'Other'],
                          value: selectedGender,
                          onChanged: (value) {
                            setState(() {
                              selectedGender = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildLabel('Place of Birth'),
              CustomTextField.textField(
                hintText: 'Place of Birth',
                controller: placeOfBirthController,
              ),
              const SizedBox(height: 4),
              _buildTimeOfBirthCheckbox(context),
              _buildTimeOfBirth(state, context),
              const SizedBox(height: 16),
              _buildLabel('Password'),
              CustomTextField.passwordTextField(
                  hintText: 'Password', controller: passwordController),
            ],
          ),
        );
      },
    );
  }

  // Widget _buildForm(BuildContext context) {
  //
  //   return BlocBuilder<CreateAccountCubit, CreateAccountState>(
  //     builder: (context, state) {
  //       return Form(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.stretch,
  //           children: [
  //             _buildLabel('Name'),
  //             CustomTextField.textField(
  //               hintText: 'Your Name',
  //               controller: nameController,
  //             ),
  //             const SizedBox(height: 16),
  //             _buildLabel('Phone Number'),
  //             CustomTextField.phoneTextField(
  //               hintText: 'Your Phone Number',
  //               controller: phoneController,
  //             ),
  //             const SizedBox(height: 16),
  //             Row(
  //               children: [
  //                 Expanded(
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       _buildLabel('D.O.B'),
  //                       _buildDropdownField(
  //                         hint: 'D.O.B',
  //                         value: dobController.text,
  //                         onChanged: (value) => dobController.text = value,
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 const SizedBox(width: 15),
  //                 Expanded(
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       _buildLabel('Gender'),
  //                       _buildDropdownField(
  //                         hint: 'Gender',
  //                         items: ['Male', 'Female', 'Other'],
  //                         value: selectedGender,
  //                         onChanged: (value) {
  //                           setState(() {
  //                             selectedGender = value;
  //                           });
  //                         },
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(height: 16),
  //             _buildLabel('Place of Birth'),
  //             CustomTextField.textField(
  //               hintText: 'Place of Birth',
  //               controller: placeOfBirthController,
  //             ),
  //             const SizedBox(height: 4),
  //             _buildTimeOfBirthCheckbox(context),
  //             _buildTimeOfBirth(state,context),
  //             const SizedBox(height: 16),
  //             _buildLabel('Password'),
  //             CustomTextField.passwordTextField(hintText: 'Password'),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
  //

    Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900), // Minimum date
      lastDate: DateTime.now(), // Maximum date
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.orange, // Header background color
            hintColor: Colors.orange, // Active control color
            colorScheme: ColorScheme.light(primary: Colors.orange),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }
  Widget _buildTimeOfBirthCheckbox(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: context.watch<CreateAccountCubit>().state.isTimeOfBirthEnabled,
          onChanged: (bool? value) {
            context
                .read<CreateAccountCubit>()
                .toggleTimeOfBirth(value ?? false);
          },
          side: const BorderSide(color: Colors.white, width: 1),
        ),
        const Text(
          'Time of Birth (Optional)',
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'Poppins',
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeOfBirth(CreateAccountState state, BuildContext context) {
    final List<String> hours =
        List.generate(12, (i) => (i + 1).toString().padLeft(2, '0'));
    final List<String> minutes =
        List.generate(60, (i) => i.toString().padLeft(2, '0'));
    final List<String> periods = ['AM', 'PM'];

    return Visibility(
      visible: state.isTimeOfBirthEnabled,
      child: Row(
        children: [
          Expanded(
            child: _buildDropdownField(
              hint: 'Hour',
              items: hours,
              value: state.selectedHour ?? '01',
              // Provide a default value
              onChanged: (value) =>
                  context.read<CreateAccountCubit>().updateTimeOfBirth(
                        value,
                        state.selectedMinute ?? '00',
                        state.selectedPeriod ?? 'AM',
                      ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildDropdownField(
              hint: 'Minute',
              items: minutes,
              value: state.selectedMinute ?? '00', // Provide a default value
              onChanged: (value) =>
                  context.read<CreateAccountCubit>().updateTimeOfBirth(
                        state.selectedHour ?? '01',
                        value,
                        state.selectedPeriod ?? 'AM',
                      ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildDropdownField(
                hint: 'Period',
                items: periods,
                value: state.selectedPeriod ?? 'AM',
                onChanged: (value) =>
                    context.read<CreateAccountCubit>().updateTimeOfBirth(
                          state.selectedHour ?? '01',
                          state.selectedMinute ?? '00',
                          value,
                        )),
          ),
        ],
      ),
    );
  }

  // Helper Methods (e.g., _buildLabel, _buildDropdownField, etc.)
  Widget _buildLabel(String label) {
    return Text(
      label,
      style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  Widget _buildDropdownField({
    required String hint,
    List<String>? items,
    String? value,
    ValueChanged<String?>? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white,
          width: 1,
        ),
      ),
      child: DropdownButton<String>(
        value: value,
        hint: Text(
          hint,
          style: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: const Color(0xFF1a237e),
        icon: Icon(Icons.arrow_drop_down, color: Colors.white.withOpacity(0.5)),
        items: (items ?? []).map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  // A method to handle the "Create Account" button click.
  Widget _buildLoginLink() {
    return GestureDetector(
      onTap: () {
        // Navigate to login screen
      },
      child: Text(
        'Already have an account? Login',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Colors.blue),
      ),
    );
  }
}
