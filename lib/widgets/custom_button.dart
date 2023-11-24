import 'package:flutter/material.dart';
import 'package:makaiapp/utils/constants.dart';

class CustomButton extends StatelessWidget {
  final String? text;
  final Color? color;
  final Function? function;
  final bool? showShadow;
  final Widget? icon;
  final Color? textColor;

  CustomButton({this.text, this.function, this.color, this.showShadow, this.icon, this.textColor});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      
      child: Container(
        alignment: Alignment.center,
        height: 40,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: color != null ? color : primaryColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0, left: 8.0),
              child: icon,
            ),
            Center(
              child: Text(
                text!,
                style: TextStyle(color: textColor != null ? textColor : Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                textScaleFactor: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
