import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/config_service.dart';
import '../../../../core/styles/styles.dart';
import '../../../../shared.dart';
import '../../../word_game/presentation/viewmodels/game_viewmodel.dart';
import '../viewmodels/promocode_viewmodel.dart';
import 'inapp_content.dart';
import 'promocodes.dart';
import 'youkassa_content.dart';

class ShopDialog extends WatchingWidget {
  const ShopDialog({Key? key, this.title = 'Магазин'}) : super(key: key);
  final String title;
  @override
  Widget build(BuildContext context) {
    $conf.fetchUseOnlyApplePay();
    final showPromoCode =
        watchValue<PromoCodeViewModel, bool>((p0) => p0.showPromoCode);
    final advSettings = watchValue<GameViewModel, bool>((p0) => p0.advSettings);
    final bool useOnlyApplePay =
        watchValue<ConfigService, bool>((p0) => p0.useOnlyApplePay);
    return Stack(
      children: [
        Dialog(
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 10.0,
            vertical: 12.0,
          ),
          clipBehavior: Clip.none,
          backgroundColor: Colors.transparent,
          child: SizedBox(
            height: advSettings ? 420 : 520,
            child: Stack(
              alignment: AlignmentDirectional.topCenter,
              children: [
                showPromoCode
                    ? const PromoCode()
                    : useOnlyApplePay
                        ? InAppContent(
                            title: title,
                          )
                        : YouKassaContent(
                            title: title,
                          ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      $promoVM.toogleShowPromoCode();
                    },
                    child: Center(
                      child: Text(
                        showPromoCode
                            ? 'У меня нет промокода'
                            : 'У меня есть промокод',
                        style: ThemeText.subTitle.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                if (!showPromoCode)
                  FutureBuilder(
                    future: $gameVm.canShowAd(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data == false) {
                          return const SizedBox.shrink();
                        }
                        return Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: GestureDetector(
                              onTap: () async {
                                $analytics
                                    .fireEvent(AnalyticsEvents.onShowAdvTap);
                                $gameVm.showAd(() {
                                  Navigator.of(context).pop();
                                });
                              },
                              child: Image.asset(
                                'assets/images/watch_ad.png',
                                width: 286,
                                // height: 58,
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
