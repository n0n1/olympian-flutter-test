import '../../../../shared.dart';
import '../viewmodels/area_viewmodel.dart';
import 'section_item_box.dart';

class SectionList extends StatelessWidget with WatchItMixin {
  const SectionList({super.key});

  @override
  Widget build(BuildContext context) {
    double widthOffset = watchValue((AreaViewModel x) => x.widthOffset);
    double wordWidth = watchValue((AreaViewModel x) => x.wordWidth);
    double itemHeight = watchValue((AreaViewModel x) => x.itemHeight);

    // make section items
    final items = $gameVm.groups.map((itemGroup) {
      final int page = (widthOffset / wordWidth).floor();
      final int itemCounts = $gameVm.groups[page > 0 ? page : 0].length;

      return SectionItemBox(
        height: (itemCounts + 1) * itemHeight,
        items: itemGroup,
        sectionIndex: $gameVm.groups.indexOf(itemGroup),
      );
    });

    return Row(
      children: [...items],
    );
  }
}
