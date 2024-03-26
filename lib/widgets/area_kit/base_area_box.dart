import 'package:flutter/cupertino.dart';

class BaseAreaBox extends StatefulWidget {
  const BaseAreaBox({super.key});

  @override
  State<BaseAreaBox> createState() => _BaseAreaBoxState();
}

class _BaseAreaBoxState extends State<BaseAreaBox> {
  late final ScrollController scroller;

  @override
  void initState() {
    scroller = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
