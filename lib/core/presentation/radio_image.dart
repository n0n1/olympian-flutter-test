import 'package:flutter/material.dart';

class RadioImage extends StatelessWidget {
  final Function onTap;
  final bool value;

  const RadioImage({
    Key? key,
    required this.onTap,
    this.value = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imagePath = value == true
        ? 'assets/images/on_checkbox.png'
        : 'assets/images/off_checkbox.png';
    return Row(
      children: <Widget>[
        GestureDetector(
          onTap: () => onTap(value == false ? true : false),
          child: SizedBox(
            height: 60,
            width: 180,
            child: Image.asset(imagePath),
          ),
        ),
      ],
    );
  }
}
