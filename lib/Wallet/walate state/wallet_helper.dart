import 'package:astrologerapp/Wallet/model/bank_details.dart';
import 'package:astrologerapp/Wallet/walate%20state/withdraw_state.dart';
import 'package:astrologerapp/helper/navigator_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WithdrawalDialog extends StatefulWidget {
  final TextEditingController accountNumber;
  final TextEditingController name;
  final TextEditingController code;
  final TextEditingController ammount;
  const WithdrawalDialog({
    super.key,
    required this.accountNumber,
    required this.name,
    required this.code,
    required this.ammount,
  });

  @override
  State<WithdrawalDialog> createState() => _WithdrawalDialogState();
}

class _WithdrawalDialogState extends State<WithdrawalDialog> {
  String? selectedDropdownValue;
  final List<String> dropdownItems = ['Bank', 'Upi'];

  @override
  Widget build(BuildContext context) {
    return BlocListener<WithdrawCubit, WithdrawState>(
      listener: (context, state) {
        if (state.isSuccess) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage ?? 'Withdrawal request created successfully'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
           Navigator.of(context).pop({
              'type': selectedDropdownValue,
              'accountNumber': widget.accountNumber.text,
              'name': widget.name.text,
              'code': widget.code.text,
            });
        }
      }, child:  AlertDialog(
          title: Text('Withdrawal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedDropdownValue,
                  items: dropdownItems.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedDropdownValue = value;
                    });
                  },
                ),
                SizedBox(height: 16),
                if (selectedDropdownValue == 'Bank') ...[
                  TextField(
                    controller: widget.accountNumber,
                    decoration: InputDecoration(
                      labelText: 'Account Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: widget.name,
                    decoration: InputDecoration(
                      labelText: 'Account holder name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: widget.ammount,
                    decoration: InputDecoration(
                      labelText: 'Ammount',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: widget.code,
                    decoration: InputDecoration(
                      labelText: 'IFSC Code',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ] else if (selectedDropdownValue == 'Upi') ...[
                  TextField(
                    controller: widget.accountNumber,
                    decoration: InputDecoration(
                      labelText: 'UPI ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: widget.ammount,
                    decoration: InputDecoration(
                      labelText: 'Ammount',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (selectedDropdownValue == null ||
                    selectedDropdownValue!.isEmpty) {
                  Helper.showSnack(context, "Please select withdrawal option");
                  return;
                }
        
                if (widget.ammount.text.isEmpty) {
                  Helper.showSnack(context, "Amount is required");
                  return;
                }
        
                if (selectedDropdownValue == "Bank") {
                  if (widget.name.text.isEmpty) {
                    Helper.showSnack(context, "Account name is required");
                    return;
                  }
                  if (widget.accountNumber.text.isEmpty) {
                    Helper.showSnack(context, "Account number is required");
                    return;
                  }
        
                  context.read<WithdrawCubit>().withdrawRequest(
                      ammount: int.parse(widget.ammount.text.trim()),
                      withdrawType: selectedDropdownValue!,
                      bankDetails: BankDetails(
                          accountNumber: widget.accountNumber.text.trim(),
                          accountHolderName: widget.name.text.trim(),
                          ifscCode: widget.code.text.trim()),
                      upi: null, context: context);
                } else {
                  // UPI flow
                  if (widget.accountNumber.text.isEmpty) {
                    Helper.showSnack(context, "UPI ID is required");
                    return;
                  }
        
                  context.read<WithdrawCubit>().withdrawRequest(
                      ammount: int.parse(widget.ammount.text.trim()),
                      withdrawType: selectedDropdownValue!,
                      bankDetails: null,
                      upi: widget.accountNumber.text.trim(), context: context);
                }
        
               
               
              },
              child: Text('Submit'),
            ),
          ],
        
    ));
  }
}
