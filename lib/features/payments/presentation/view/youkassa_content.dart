import '../../../../core/presentation/dialog_wrapper.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/styles/styles.dart';
import '../../../../shared.dart';
import '../../../word_game/presentation/viewmodels/game_viewmodel.dart';
import '../../data/models/products_model.dart';
import 'youkassa_payment.dart';

class YouKassaContent extends StatelessWidget with WatchItMixin {
  final String title;

  const YouKassaContent({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    $gameVm.fetchAdvSettings();
    final advSettings = watchValue<GameViewModel, bool>((p0) => p0.advSettings);
    final levelIndex = watchValue<GameViewModel, int>((p0) => p0.levelIndex);

    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: DialogWrapper(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: 28.0,
        ),
        child: SizedBox(
          width: 280,
          height: advSettings ? 210 : 300,
          child: Column(
            children: [
              Text(
                title,
                style: ThemeText.shopTitle,
              ),
              const SizedBox(
                height: 20,
              ),
              Wrap(
                children: [
                  ...availableProducts
                      .where((e) => e.id != 'adv_off')
                      .map(
                        (e) => GestureDetector(
                          onTap: () {
                            final params = {
                              'level_id': $gameVm.activeLevel.id,
                              'level': levelIndex,
                              'word': $gameVm.focusedWord?.word ?? '',
                            };

                            switch (e.coins) {
                              case 100:
                                $analytics.fireEventWithMap(
                                    AnalyticsEvents.onBuy100, params);
                                break;
                              case 1000:
                                $analytics.fireEventWithMap(
                                    AnalyticsEvents.onBuy1000, params);
                                break;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                fullscreenDialog: true,
                                builder: (context) =>
                                    YouKassaPayment(product: e),
                              ),
                            );
                          },
                          child: Stack(
                            children: [
                              Image.asset(
                                'assets/images/shop_product_${e.coins}.png',
                                width: 140,
                              ),
                              Positioned(
                                bottom: 50,
                                left: 0,
                                right: 0,
                                child: Text(
                                  '+${availableInAppProducts[e.id]}',
                                  textAlign: TextAlign.center,
                                  style: ThemeText.priceCoinsTitleFill,
                                ),
                              ),
                              Positioned(
                                bottom: 22,
                                left: 0,
                                right: 0,
                                child: Text(
                                  '₽${e.price}',
                                  textAlign: TextAlign.center,
                                  style: ThemeText.priceTitle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  if (!advSettings)
                    GestureDetector(
                      onTap: () {
                        final params = {
                          'level_id': $gameVm.activeLevel.id,
                          'level': levelIndex,
                          'word': $gameVm.focusedWord?.word ?? '',
                        };

                        $analytics.fireEventWithMap(
                            AnalyticsEvents.advOff, params);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (context) => YouKassaPayment(
                                product: availableProducts
                                    .firstWhere((e) => e.id == 'adv_off')),
                          ),
                        );
                      },
                      child: Stack(
                        children: [
                          Image.asset(
                            'assets/images/turn_off_add.png',
                          ),
                          Positioned(
                            bottom: 32,
                            left: 0,
                            right: 0,
                            child: Text(
                              '₽${availableProducts.firstWhere((e) => e.id == 'adv_off').price}',
                              textAlign: TextAlign.center,
                              style: ThemeText.priceTitle,
                            ),
                          ),
                        ],
                      ),
                    )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
