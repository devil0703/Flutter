import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makaiapp/services/validator_service.dart';
import 'package:makaiapp/utils/constants.dart';

class CustomTextField extends StatelessWidget {
  final String? hint;
  final String? label;
  final TextEditingController? controller;
  final TextInputType? textInputType;
  final Color? labelColor;
  final int? maxLines;
  final bool? validate;
  final bool? isPassword;
  final bool? isEmail;
  final bool? enabled;
  final Widget? dropdown;
  final int? maxLength;
  final Widget? prefix;
  final String? autofillHints;

  CustomTextField({this.hint, this.isEmail, this.label, this.controller, this.textInputType, this.labelColor, this.maxLines, this.validate, this.isPassword, this.enabled, this.dropdown, this.maxLength, this.prefix, this.autofillHints});

  final validatorService = Get.find<ValidatorService>();

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != '')
          Padding(
            padding: const EdgeInsets.only(top: 30, bottom: 15),
            child: Text(label!, style: TextStyle(color: labelColor ?? primaryColor)),
          ),
        dropdown == null 
            ? TextFormField(
                autofillHints: autofillHints != null ? [autofillHints!] : null,
                maxLength: maxLength ?? 250,
                enabled: enabled ?? true,
                obscureText: isPassword ?? false,
                maxLines: maxLines ?? 1,
                keyboardType: textInputType,
                textInputAction: (maxLines ?? 1) > 1 ? TextInputAction.newline : TextInputAction.next,
                onEditingComplete: () => node.nextFocus(),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => validate ?? false
                    ? isEmail ?? false
                        ? validatorService.validateEmail(value!)
                        : validatorService.validateText(value!)
                    : null,
                controller: controller,
                textAlignVertical: TextAlignVertical.center,
                decoration: maxLength == null
                    ? InputDecoration(
                        hintText: hint,
                        prefix: prefix ?? Container(width: 0),
                        counterText: '',
                        contentPadding: (maxLines ?? 1) == 1 ? EdgeInsets.symmetric(horizontal: 15) : EdgeInsets.all(15),
                      )
                    : InputDecoration(
                        hintText: hint,
                        prefix: prefix ?? Container(width: 0),
                        contentPadding: (maxLines ?? 1) == 1 ? EdgeInsets.symmetric(horizontal: 15) : EdgeInsets.all(15),
                      ),
              )
            : dropdown ?? Container(),
      ],
    );
  }
}
