import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../services/notification_service.dart';
import '../utils/physics.dart';
import '../viewmodels/game_viewmodel.dart';
import '../widgets/base_scaffold.dart';
import '../widgets/help_button.dart';
import '../widgets/score_bar.dart';
import '../widgets/word_item.dart';

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
          child: const _NestedScroll(),
        ),
      ),
    );
  }
}

class _NestedScroll extends StatefulWidget {
  const _NestedScroll({Key? key}) : super(key: key);

  @override
  __NestedScrollState createState() => __NestedScrollState();
}

class __NestedScrollState extends State<_NestedScroll> {
  final dataKey = GlobalKey();
  late final ScrollController _scrollCtrl;
  double widthOffset = 0.0;
  double wordWidth = 160.0;
  double itemHeight = 66.0;
  OverlayEntry? entry;

  @override
  void initState() {
    _scrollCtrl = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final notifications = NotificationService();
      notifications.init(context: context);
      _buildOverlaySquare();
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
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 40,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87]),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 10,
            right: 10,
            child: Center(
              child: AnimatedSmoothIndicator(
                activeIndex: max(
                    ((_scrollCtrl.hasClients ? _scrollCtrl.offset : 0) /
                            wordWidth)
                        .floor(),
                    0),
                count: groups.length,
                effect: const ExpandingDotsEffect(
                  dotWidth: 12,
                  dotHeight: 8,
                  expansionFactor: 2,
                  dotColor: Color.fromRGBO(169, 126, 74, 1),
                  activeDotColor: Color.fromRGBO(255, 244, 205, 1),
                ),
              ),
            ),
          )
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

  Widget buildOverlay() {
    return Lottie.asset(
      'assets/animations/Animation.json',
    );
  }

  void findSectionPosition() {}

  void _buildOverlaySquare() {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final position = renderBox.globalToLocal(Offset.zero);

    // final renderBoxWord =
    //     dataKey.currentContext!.findRenderObject() as RenderBox;
    // final sizeWord = renderBoxWord.size;
    // final positionWord = renderBoxWord.globalToLocal(Offset.zero);

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
