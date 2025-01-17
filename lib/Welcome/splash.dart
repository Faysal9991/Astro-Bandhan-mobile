

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';

import '../AccountState/CreateAccountState.dart';
import '../Auth/LoginScreen.dart';
import '../Auth/create_account.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  Column(
                    children: [
                      const SizedBox(height: 150),
                      Text(
                        'ASTRO',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontSize: 96,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w900,
                          height:
                              50 / 96, // line-height divided by font-size
                          leadingDistribution: TextLeadingDistribution.even,
                        ),
                      ),
                      Text(
                        'BANDHAN',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontSize: 66,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w500,
                          leadingDistribution: TextLeadingDistribution.even,
                        ),
                      ),
                      Container(
                     
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(
                              0.1), // background: rgba(255, 255, 255, 0.10)
                          borderRadius: BorderRadius.circular(
                              20), // border-radius: 20px
                          border: Border.all(
                            color: Colors.white.withOpacity(
                                0.50), // border: 1px solid rgba(255, 255, 255, 0.50)
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF232324).withOpacity(
                                  0.2), // Optional, for subtle shadow effect
                              blurRadius:
                                  9, // For the blur effect similar to backdrop-filter
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child:
                            // backdrop-filter: blur(9.2px)
                            Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                'Welcome',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                  fontSize: 32,
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.w500,
                                  height: 50 /
                                      32, // line-height divided by font-size
                                  leadingDistribution: TextLeadingDistribution
                                      .even, // approximate for leading-trim: both
                                ),
                              ),
                              Text(
                                textAlign: TextAlign.center,
                                'Bibendum congue pellentesque ac habitant sociosqu cursus sit taciti morbi tincidunt',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(
                                      0.8), // rgba(255, 255, 255, 0.80)
                                  fontFamily:
                                      'Inter', // Font family set to Inter
                                  fontSize: 15, // Font size of 16px
                                  fontStyle:
                                      FontStyle.normal, // Normal font style
                                  fontWeight:
                                      FontWeight.w300, // Font weight of 400
                                  height: 24 /
                                      16, // Line height (24px) divided by font size (16px)
                                  // Center aligned text
                                  leadingDistribution: TextLeadingDistribution
                                      .even, // Approximate for leading-trim: both
                                ),
                                
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              InkWell(
                                onTap:() {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => LoginScreen()),
                                  );
                                },
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'LOGIN',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        color: Color(0xFF1a237e),
                                        fontWeight: FontWeight.normal,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            
                          
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
