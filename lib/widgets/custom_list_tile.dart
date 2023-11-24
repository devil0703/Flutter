import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? trailing;
  final Function? onTap;
  final Color? backgroundColor;
  final double? marginBottom;

  const CustomListTile({this.leading, this.title, this.trailing, this.onTap, this.backgroundColor, this.marginBottom});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: EdgeInsets.only(bottom: marginBottom ?? 15),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: InkWell(
        // onTap: onTap ?? null,
        child: Row(
          children: [
            Expanded(flex: 10, child: leading ?? Container()),
            Expanded(flex: 30, child: title ?? Container()),
            Flexible(flex: 15, child: Container(padding: const EdgeInsets.only(right: 15), alignment: Alignment.centerRight, child: trailing ?? Container())),
          ],
        ),
      ),
    );
  }
}
