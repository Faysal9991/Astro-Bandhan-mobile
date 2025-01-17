import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  _LanguageSelectionScreenState createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? selectedLanguage;

  // Define available languages
  final List<Map<String, String>> languages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'es', 'name': 'Spanish'},
    {'code': 'fr', 'name': 'French'},
    {'code': 'de', 'name': 'German'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/img/ScreenBG.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back,
                                    color: Colors.white),
                                onPressed: () {},
                              ),
                              const Expanded(
                                child: Text(
                                  'CHOOSE LANGUAGE',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(width: 30),
                            ],
                          ),
                          const SizedBox(height: 40),
                          Center(
                            child: SvgPicture.asset(
                              'assets/SVG/IllustrationLang.svg',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            'Choose Your Language',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Added Dropdown here
                          Container(
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
                              value: selectedLanguage,
                              hint: Text(
                                'Choose Language',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.5)),
                              ),
                              isExpanded: true,
                              underline: const SizedBox(),
                              dropdownColor: const Color(0xFF1a237e),
                              icon: Icon(Icons.arrow_drop_down,
                                  color: Colors.white.withOpacity(0.5)),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Poppins',
                              ),
                              items: languages.map((language) {
                                return DropdownMenuItem<String>(
                                  value: language['code'],
                                  child: Text(language['name']!),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedLanguage = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Login Button
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Center(
                              child: Text(
                                'CONTINUE',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Color(0xFF1a237e),
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
