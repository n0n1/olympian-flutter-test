import '../../../../core/presentation/image_button.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/styles/styles.dart';
import '../../../../shared.dart';
import '../../../payments/presentation/view/shop_dialog.dart';
import '../viewmodels/game_viewmodel.dart';

class ScoreBar extends WatchingWidget {
  final bool withPadding;
  final bool showBack;
  final bool showLevel;
  final Function? onBackTap;
  final String? prevScreen;

  const ScoreBar({
    Key? key,
    this.withPadding = false,
    this.showBack = true,
    this.showLevel = false,
    this.onBackTap,
    this.prevScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final padding = withPadding
        ? const EdgeInsets.only(left: 16, right: 16, top: 12)
        : const EdgeInsets.only(top: 12);
    $gameVm.fetchLevelIndex();
    final coins = watchPropertyValue<GameViewModel, int>((p0) => p0.coins);
    final levelID = watchValue<GameViewModel, int>((p0) => p0.levelIndex);

    return Container(
      padding: padding,
      width: showLevel ? MediaQuery.of(context).size.width : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showBack)
            ImageButton(
              onTap: onBackTap != null
                  ? onBackTap!()
                  : () => Navigator.of(context).pop(),
              type: ImageButtonType.back,
              width: 36.0,
              height: 36.0,
            ),
          Row(
            children: [
              if (showLevel)
                Container(
                  padding: const EdgeInsets.only(bottom: 8, right: 6),
                  child: Text(
                    'Уровень  $levelID',
                    style: ThemeText.levelName,
                  ),
                ),
              Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      $gameVm.playTapAudio();
                      $analytics.fireEventWithMap(
                          AnalyticsEvents.onMonetizationWindowShow, {
                        'level_id': $gameVm.activeLevel.id,
                        'level': $gameVm.fetchLevelIndex(),
                        'screen': prevScreen ?? '',
                      });
                      showDialog(
                        context: context,
                        barrierColor: Colors.black38,
                        builder: (ctx) => const ShopDialog(),
                      ).then((value) {
                        $analytics.fireEventWithMap(
                            AnalyticsEvents.onMonetizationWindowClose, {
                          'level_id': $gameVm.activeLevel.id,
                          'level': $gameVm.fetchLevelIndex(),
                          'screen': prevScreen ?? '',
                        });
                      });
                    },
                    child: Image.asset('assets/images/score.png', width: 160),
                  ),
                  // Coins
                  Positioned(
                    top: 12,
                    right: 70,
                    left: 30,
                    child: Text(
                      coins.toString(),
                      textAlign: TextAlign.center,
                      style: ThemeText.pointsText,
                    ),
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
