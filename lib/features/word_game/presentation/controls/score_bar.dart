import '../../../../core/services/analytics_service.dart';
import '../../../../core/styles/styles.dart';
import '../../../../shared.dart';
import '../../../payments/presentation/view/shop_dialog.dart';
import '../viewmodels/game_viewmodel.dart';

class ScoreView extends WatchingWidget {
  final bool withPadding;

  const ScoreView({
    Key? key,
    this.withPadding = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final padding = withPadding
        ? const EdgeInsets.only(left: 16, right: 16, top: 12)
        : const EdgeInsets.only(top: 12);
    final coins = watchValue<GameViewModel, int>((p0) => p0.coins);
    final levelIndex = watchValue<GameViewModel, int>((p0) => p0.levelIndex);

    return Container(
      padding: padding,
      child: Row(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  $gameVm.playTapAudio();
                  $analytics.fireEventWithMap(
                      AnalyticsEvents.onMonetizationWindowShow, {
                    'level_id': $gameVm.activeLevel.id,
                    'level': levelIndex,
                    // 'screen': prevScreen ?? '',
                  });
                  showDialog(
                    context: context,
                    barrierColor: Colors.black38,
                    builder: (ctx) => const ShopDialog(),
                  ).then((value) {
                    $analytics.fireEventWithMap(
                        AnalyticsEvents.onMonetizationWindowClose, {
                      'level_id': $gameVm.activeLevel.id,
                      'level': levelIndex,
                      // 'screen': prevScreen ?? '',
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
    );
  }
}
