import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:makaiapp/utils/constants.dart';

class LoadingData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 50,
        child: LoadingIndicator(
          indicatorType: Indicator.lineScalePulseOut,
          colors: [primaryColor, secondaryColor],
          strokeWidth: 2,
          backgroundColor: Colors.transparent,
          pathBackgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}
