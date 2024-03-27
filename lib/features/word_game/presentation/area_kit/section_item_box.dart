import 'package:lottie/lottie.dart';

import '../../../../shared.dart';
import '../../data/models/word_model.dart';
import '../viewmodels/area_viewmodel.dart';
import '../word/word_item.dart';

/// Интерфейс секций со списком слов
class SectionItemBox extends StatefulWidget {
  const SectionItemBox({
    super.key,
    this.height = 100,
    required this.items,
    required this.sectionIndex,
  });

  final double height;
  final List<WordModel> items;
  final int sectionIndex;
  @override
  State<SectionItemBox> createState() => _SectionItemBoxState();
}

class _SectionItemBoxState extends State<SectionItemBox> {
  OverlayEntry? entry;
  final dataKey = GlobalKey();

  ///
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // buildOverlayPosition();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<List<WordModel>> groups = $gameVm.groups;

    double widthOffset = $areaVm.widthOffset.value;
    double wordWidth = $areaVm.wordWidth.value;
    double itemHeight = $areaVm.itemHeight.value;

    return Container(
      height: widget.height,
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height - 70,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...widget.items.map((word) {
            final key = word == $gameVm.scrollableWord ? dataKey : null;
            if (key != null) {
              $gameVm.scrollKey = key;
            }
            final showEndLeaf =
                (widthOffset / wordWidth).floor() <= widget.sectionIndex;
            final showStartLeaf =
                (widthOffset / wordWidth).floor() == widget.sectionIndex;

            return AnimatedBuilder(
              animation: $areaScroller,
              builder: (context, child) {
                final page = max((widthOffset / wordWidth).floor(), 0);
                final position = GetIt.I.get<AreaViewModel>().recalculateOffset(
                      maxItems: groups[page].length,
                      depth: word.depth,
                    );

                return AnimatedContainer(
                  width: wordWidth,
                  height: itemHeight,
                  duration: const Duration(milliseconds: 150),
                  margin: EdgeInsets.only(
                    right: 0,
                    top: position,
                    bottom: position,
                  ),
                  child: child,
                );
              },
              child: WordItem(
                key: key,
                word: word,
                showEndLeaf: showEndLeaf,
                showStartLeaf: showStartLeaf,
              ),
            );
          }).toList(),
        ],
      ),
    );
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
