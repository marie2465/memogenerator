import 'package:flutter/material.dart';
import 'package:memogenerator/resources/app_colors.dart';

class MemeTextOnCanvas extends StatelessWidget {
  const MemeTextOnCanvas({
    Key? key,
    required this.padding,
    required this.selected,
    required this.parentConstraints,
    required this.text,
    required this.fontSize,
    required this.color,
  }) : super(key: key);

  final double padding;
  final bool selected;
  final BoxConstraints parentConstraints;
  final String text;
  final double fontSize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: parentConstraints.maxWidth,
        maxHeight: parentConstraints.maxHeight,
      ),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: selected ? AppColors.darkGrey16 : null,
        border: Border.all(
          color: selected ? AppColors.fuchsia : Colors.transparent,
          width: 1,
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: color, fontSize: fontSize),
      ),
    );
  }
}
