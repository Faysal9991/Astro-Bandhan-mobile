import 'package:astrologerapp/CustomComponents/appbar.dart';
import 'package:astrologerapp/Home/audiocall/widget/custom_container.dart';
import 'package:astrologerapp/Wallet/model/walet_history.dart';
import 'package:astrologerapp/Wallet/walate%20state/walate_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class WalletScreen extends StatefulWidget {
  final String presentblance;
  const WalletScreen({super.key, required this.presentblance});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userCubit = context.read<WalateCubit>();

      userCubit.getWalateHistory();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xff0F0F55),
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.white, // Change the back button color here
          ),
          backgroundColor: Color(0xff0F0F55),
          centerTitle: true,
          title: Text(
            'Wallet',
            style: TextStyle(
              fontFamily: "Poppins",
              fontWeight: FontWeight.w500,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              glassContainer(context,
                  height: 122,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Available Balance",
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              "₹${widget.presentblance}",
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Poppins',
                                fontSize: 32,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {},
                          child: Text(
                            "withdrawal",
                            style: TextStyle(
                              color: Color(0xff0F0F55),
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      ],
                    ),
                  )),
              Text(
                textAlign: TextAlign.center,
                "Recent Activity:", // Access the key (label)
                style: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              BlocBuilder<WalateCubit, WalateState>(builder: (context, state) {
                return Row(
                  spacing: 10,
                  children: [
                    InkWell(
                      onTap: () {
                        context.read<WalateCubit>().toggleBoolean();
                        print("--------state vale  ->${state.toggleValue}");
                      },
                      child: Container(
                        height: 40,
                        width: 85,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: state.toggleValue
                                ? null
                                : Border.all(width: 0.3, color: Colors.white),
                            color: state.toggleValue
                                ? Colors.white
                                : Color(0xff0F0F55)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              textAlign: TextAlign.center,
                              "Credit", // Access the key (label)
                              style: TextStyle(
                                fontFamily: "Inter",
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: state.toggleValue
                                    ? Color(0xff0F0F55)
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => context.read<WalateCubit>().toggleBoolean(),
                      child: Container(
                        height: 40,
                        width: 85,
                        decoration: BoxDecoration(
                            border: state.toggleValue
                                ? Border.all(width: 0.3, color: Colors.white)
                                : null,
                            borderRadius: BorderRadius.circular(20),
                            color: state.toggleValue
                                ? Colors.transparent
                                : Colors.white),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              textAlign: TextAlign.center,
                              "Debit", // Access the key (label)
                              style: TextStyle(
                                fontFamily: "Inter",
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: state.toggleValue
                                    ? Colors.white
                                    : Color(0xff0F0F55),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                );
              }),
              BlocBuilder<WalateCubit, WalateState>(builder: (context, state) {

                return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: waletHistory.length,
                    itemBuilder: (context, index) {
                      if (state.toggleValue) {
                        return waletHistory[index].transactionType ==
                                TransactionType.CREDIT
                            ? Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: glassContainer(
                                  height: 110,
                                  context,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          "assets/SVG/money_icon.svg",
                                          height: 50,
                                          width: 50,
                                        ),
                                        const SizedBox(width: 10),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 20),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            spacing: 2,
                                            children: [
                                              Text("Placerat netus",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16,
                                                    fontFamily: "Poppins",
                                                    color: Colors.white,
                                                  )),
                                              Text(
                                                  formatDate(waletHistory[index]
                                                      .createdAt
                                                      .toString()),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 12,
                                                    fontFamily: "Inter",
                                                    color: Colors.white,
                                                  )),
                                            ],
                                          ),
                                        ),
                                        Spacer(),
                                        Text("+₹${waletHistory[index].amount}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 20,
                                              fontFamily: "Poppins",
                                              color: Colors.white,
                                            )),
                                      ],
                                    ),
                                  )),
                            )
                            : Text("Not founds",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                  fontFamily: "Poppins",
                                  color: Colors.white,
                                ));
                      }
                      if (state.toggleValue == false) {
                        return waletHistory[index].transactionType ==
                                TransactionType.DEBIT
                            ? Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: glassContainer(
                                  height: 110,
                                  context,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          "assets/SVG/money_icon.svg",
                                          height: 50,
                                          width: 50,
                                        ),
                                        const SizedBox(width: 10),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 20),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            spacing: 2,
                                            children: [
                                              Text("Placerat netus",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16,
                                                    fontFamily: "Poppins",
                                                    color: Colors.white,
                                                  )),
                                              Text(
                                                  formatDate(waletHistory[index]
                                                      .createdAt
                                                      .toString()),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 12,
                                                    fontFamily: "Inter",
                                                    color: Colors.white,
                                                  )),
                                            ],
                                          ),
                                        ),
                                        Spacer(),
                                        Text("+₹${waletHistory[index].amount}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 20,
                                              fontFamily: "Poppins",
                                              color: Colors.white,
                                            )),
                                      ],
                                    ),
                                  )),
                            )
                            : SizedBox.shrink();
                      }
                    });
              })
            ],
          ),
        ));
  }
}

String formatDate(String dateString) {
  // Parse the input date string
  DateTime parsedDate = DateTime.parse(dateString);

  // Format the date into the desired format
  String formattedDate = DateFormat('d MMM yyyy').format(parsedDate);

  return formattedDate;
}
