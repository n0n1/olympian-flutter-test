// ignore_for_file: prefer_relative_imports

import 'package:olympian/core/presentation/image_button.dart';
import 'package:olympian/shared.dart';

class CBackButton extends StatelessWidget {
  const CBackButton({
    super.key,
    this.onBackTap,
  });

  final Function? onBackTap;

  @override
  Widget build(BuildContext context) {
    return ImageButton(
      onTap:
          onBackTap != null ? onBackTap!() : () => Navigator.of(context).pop(),
      type: ImageButtonType.back,
      width: 36.0,
      height: 36.0,
    );
  }
}
