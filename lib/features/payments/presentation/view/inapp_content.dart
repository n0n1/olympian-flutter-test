import '../../../../core/presentation/dialog_wrapper.dart';
import '../../../../core/presentation/loading_dialog.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/styles/styles.dart';
import '../../../../shared.dart';
import '../../../word_game/presentation/viewmodels/game_viewmodel.dart';
import '../../data/models/products_model.dart';

/// Внутренние покупки
class InAppContent extends StatelessWidget with WatchItMixin {
  final String title;
  const InAppContent({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await $paymentVM.loadProducts();
    });

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
          height: !advSettings ? 300 : 220,
          child: Column(
            children: [
              Text(
                title,
                style: ThemeText.shopTitle,
              ),
              const SizedBox(
                height: 20,
              ),
              if ($paymentVM.productsLoading)
                const Column(
                  children: [
                    SizedBox(
                      height: 60,
                    ),
                    CircularProgressIndicator(),
                  ],
                ),
              if (!$paymentVM.productsLoading)
                Wrap(
                  children: [
                    ...$paymentVM.products
                        .where((e) => e.id != 'adv_off')
                        .map((product) {
                      return GestureDetector(
                        onTap: () {
                          final closeDialog =
                              showLoadingScreen(context: context);
                          $paymentVM.buyProduct(
                            product: product,
                            onComplete: (int coins) {
                              closeDialog();
                              $gameVm.buyPointsComplete(coins);
                              $gameVm.firePaymentComplete();
                            },
                            onError: () {
                              closeDialog();
                            },
                            context: context,
                          );

                          final params = {
                            'level_id': $gameVm.activeLevel.id,
                            'level': levelIndex,
                            'word': $gameVm.focusedWord?.word ?? '',
                          };

                          switch (product.id) {
                            case 'product_100':
                              $analytics.fireEventWithMap(
                                  AnalyticsEvents.onBuy100, params);
                              break;
                            case 'product_1000':
                              $analytics.fireEventWithMap(
                                  AnalyticsEvents.onBuy1000, params);
                              break;
                          }
                        },
                        child: Stack(
                          children: [
                            Image.asset(
                              'assets/images/shop_${product.id}.png',
                              width: 140,
                            ),
                            Positioned(
                              bottom: 50,
                              left: 0,
                              right: 0,
                              child: Text(
                                '+${availableInAppProducts[product.id]}',
                                textAlign: TextAlign.center,
                                style: ThemeText.priceCoinsTitleFill,
                              ),
                            ),
                            Positioned(
                              bottom: 22,
                              left: 0,
                              right: 0,
                              child: Text(
                                product.price,
                                textAlign: TextAlign.center,
                                style: ThemeText.priceTitle,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    if (!advSettings)
                      GestureDetector(
                        onTap: () {
                          final product = $paymentVM.productAdvOff;
                          final closeDialog =
                              showLoadingScreen(context: context);
                          $paymentVM.buyProduct(
                            product: product!,
                            onComplete: (int coins) {
                              closeDialog();
                              $gameVm.turnOffAdv();
                            },
                            onError: () {
                              closeDialog();
                            },
                            context: context,
                          );

                          final ctrl = $gameVm;

                          final params = {
                            'level_id': ctrl.activeLevel.id,
                            'level': levelIndex,
                            'word': ctrl.focusedWord?.word ?? '',
                          };
                          $analytics.fireEventWithMap(
                              AnalyticsEvents.advOff, params);
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
                                $paymentVM.productAdvOff?.price ?? '',
                                textAlign: TextAlign.center,
                                style: ThemeText.priceTitle,
                              ),
                            ),
                          ],
                        ),
                      )
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
