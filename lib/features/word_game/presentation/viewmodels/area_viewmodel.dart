// ignore_for_file: prefer_relative_imports

import 'package:olympian/shared.dart';

class AreaViewModel {
  final widthOffset = ValueNotifier<double>(0.0);
  final itemHeight = ValueNotifier<double>(66.0);
  final wordWidth = ValueNotifier<double>(160.0);

  double recalculateOffset({required int maxItems, required int depth}) {
    final totalItemsHeight = maxItems * itemHeight.value;
    final totalDepthHeight = totalItemsHeight - (depth * itemHeight.value);
    final offsetValue = max<double>((totalDepthHeight / depth) / 2, 0.0);

    return offsetValue;
  }

  ensureScroll() {
    Future.delayed(const Duration(milliseconds: 500), () {
      $gameVm.scrollToWidget();
    });
  }
}
