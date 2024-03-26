import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';

/// Интерфейс секций со списком слов
class SectionLevelBox extends StatefulWidget {
  const SectionLevelBox({super.key});

  @override
  State<SectionLevelBox> createState() => _SectionLevelBoxState();
}

class _SectionLevelBoxState extends State<SectionLevelBox> {
  OverlayEntry? entry;

  ///
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      buildOverlayPosition();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Widget buildOverlay() {
    return Lottie.asset(
      'assets/animations/Animation.json',
    );
  }

  void buildOverlayPosition() {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final position = renderBox.globalToLocal(Offset.zero);

    entry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width * .5,
        left: position.dx,
        top: position.dy + size.height * .5,
        child: buildOverlay(),
      ),
    );
    overlay.insert(entry!);
  }
}
