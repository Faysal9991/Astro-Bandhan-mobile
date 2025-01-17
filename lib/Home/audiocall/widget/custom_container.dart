import 'package:flutter/material.dart';

Widget glassContainer(BuildContext context,{double? height,double? width,required Widget child, bool? isBorder = true} ) {
  return Container(
    height: height ?? MediaQuery.of(context).size.height,
    width:  width ?? MediaQuery.of(context).size.width,
    decoration: BoxDecoration(
      color: Colors.white
          .withOpacity(0.1), // background: rgba(255, 255, 255, 0.10)
      borderRadius: BorderRadius.circular(20), // border-radius: 20px
      border:isBorder!? Border.all(
        color: Colors.white
            .withOpacity(0.50), // border: 1px solid rgba(255, 255, 255, 0.50)
        width: 1,
      ):null,
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF232324)
              .withOpacity(0.2), // Optional, for subtle shadow effect
          blurRadius: 9, // For the blur effect similar to backdrop-filter
          spreadRadius: 1,
        ),
      ],
    ),
    child: child
       );
}
