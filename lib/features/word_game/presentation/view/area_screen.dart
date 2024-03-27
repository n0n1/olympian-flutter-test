import '../../../../core/presentation/base_scaffold.dart';
import '../../../../core/presentation/illustrations/bottom_decoration_gradient.dart';
import '../../../../core/utils/physics.dart';
import '../../../../shared.dart';
import '../area_kit/area_page_controls.dart';
import '../area_kit/base_area_box.dart';
import '../area_kit/section_list_box.dart';
import '../controls/score_bar.dart';
import '../help/help_button.dart';

/// Поле игры
class AreaScreen extends StatelessWidget {
  const AreaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      showLeaf: true,
      withPadding: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            HelpButton(
              helpText: $gameVm.isLastWord()
                  ? 'Открыть случайное слово. Нельзя открыть последнее слово'
                  : 'Открыть случайное слово. Уберите курсор из ячейки',
            ),
            HelpButton(
              word: true,
              helpText: $gameVm.isLastWord()
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
            $gameVm.clearActiveWord();
          },
          child: const BaseAreaBox(
            // scroller: ScrollController(),
            child: SectionList(),
          ),
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
      // TODO: Можно вызывать из любого места
      $notification.init();
    });
    super.initState();
  }

  // _ensureScroll(BuildContext ctx) async {
  //   await Future.delayed(const Duration(milliseconds: 500));
  //   ctx.read<GameViewModel>().scrollToWidget();
  // }

  @override
  Widget build(BuildContext context) {
    // final vm = context.watch<GameViewModel>();
    // final groups = vm.groups;

    // _ensureScroll(context);
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
}
