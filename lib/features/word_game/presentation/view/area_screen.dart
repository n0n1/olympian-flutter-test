import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../../../../core/presentation/base_scaffold.dart';
import '../../../../core/presentation/illustrations/bottom_decoration_gradient.dart';
import '../../../../core/utils/physics.dart';
import '../../../../shared.dart';
import '../area_kit/area_page_controls.dart';
import '../controls/score_bar.dart';
import '../help/help_button.dart';
import '../viewmodels/game_viewmodel.dart';
import '../word/word_item.dart';

/// Поле игры
class AreaScreen extends StatelessWidget {
  const AreaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GameViewModel>();
    return BaseScaffold(
      showLeaf: true,
      withPadding: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            HelpButton(
              helpText: vm.isLastWord()
                  ? 'Открыть случайное слово. Нельзя открыть последнее слово'
                  : 'Открыть случайное слово. Уберите курсор из ячейки',
            ),
            HelpButton(
              word: true,
              helpText: vm.isLastWord()
                  ? 'Открыть выбранное слово. Нельзя открыть последнее слово'
                  : 'Открыть выбранное слово. Выберете ячейку',
            ),
            const SizedBox(
              height: 66,
            ),
          ],
        ),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          toolbarHeight: 76.0,
          flexibleSpace: const ScoreBar(
            withPadding: true,
            showLevel: true,
            prevScreen: 'Level',
          ),
          backgroundColor: Colors.transparent,
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
            vm.clearActiveWord();
          },
          child: const NestedScroll(),
        ),
      ),
    );
  }
}

class NestedScroll extends StatefulWidget {
  const NestedScroll({Key? key}) : super(key: key);

  @override
  NestedScrollState createState() => NestedScrollState();
}

class NestedScrollState extends State<NestedScroll> {
  final dataKey = GlobalKey();
  late final ScrollController _scrollCtrl;
  double widthOffset = 0.0;
  double wordWidth = 160.0;
  double itemHeight = 66.0;

  @override
  void initState() {
    _scrollCtrl = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      $notification.init(context: context);
    });
    super.initState();
  }

  _ensureScroll(BuildContext ctx) async {
    await Future.delayed(const Duration(milliseconds: 500));
    ctx.read<GameViewModel>().scrollToWidget();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GameViewModel>();
    final groups = vm.groups;

    _ensureScroll(context);
    final advContainerWidth = MediaQuery.of(context).size.width - wordWidth;

    return NotificationListener<ScrollEndNotification>(
      onNotification: (end) {
        setState(() {
          widthOffset = _scrollCtrl.offset;
        });
        return true;
      },
      child: Stack(
        children: [
          SingleChildScrollView(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: CustomScrollPhysics(itemDimension: wordWidth),
              controller: _scrollCtrl,
              child: Row(
                children: [
                  ...groups.map((group) {
                    final index = vm.groups.indexOf(group);
                    final page = (widthOffset / wordWidth).floor();
                    if (kDebugMode) {
                      print('index:$index page:$page');
                    }

                    var itemCounts = vm.groups[page > 0 ? page : 0].length;
                    return Container(
                      height: (itemCounts + 1) * itemHeight,
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height - 70,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ...group.map((word) {
                            final key =
                                word == vm.scrollableWord ? dataKey : null;
                            if (key != null) {
                              vm.scrollKey = key;
                            }
                            final showEndLeaf =
                                (widthOffset / wordWidth).floor() <= index;
                            final showStartLeaf =
                                (widthOffset / wordWidth).floor() == index;

                            return AnimatedBuilder(
                              animation: _scrollCtrl,
                              builder: (context, child) {
                                final page =
                                    max((widthOffset / wordWidth).floor(), 0);
                                final position = _recalculateOffset(
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
                          Container(
                            height: 66,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  Container(width: advContainerWidth),
                ],
              ),
            ),
          ),
          const BottomGradient(),
          const AreaPageControls(),
        ],
      ),
    );
  }

  double _recalculateOffset({required int maxItems, required int depth}) {
    final totalItemsHeight = maxItems * itemHeight;
    final totalDepthHeight = totalItemsHeight - (depth * itemHeight);
    final offsetValue = max<double>((totalDepthHeight / depth) / 2, 0.0);

    return offsetValue;
  }
}
