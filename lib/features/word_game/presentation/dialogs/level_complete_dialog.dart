import '../../../../core/presentation/dialog_wrapper.dart';
import '../../../../core/presentation/loading_dialog.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/styles/styles.dart';
import '../../../../core/utils/ext.dart';
import '../../../../shared.dart';
import '../../../payments/data/models/products_model.dart';
import '../../../payments/presentation/view/youkassa_payment.dart';
import '../viewmodels/game_viewmodel.dart';

class LevelCompleteDialog extends StatelessWidget {
  const LevelCompleteDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await $paymentVM.loadProducts();
      $analytics.fireEventWithMap(
        AnalyticsEvents.onLevelComplete,
        {
          'level_id': $gameVm.activeLevel.id,
          'level': $gameVm.fetchLevelIndex(),
        },
      );
      await $settingsVM.reviewAppOnLevelComplete();
    });

    $gameVm.fetchAdvSettings();
    final advSettings = watchValue<GameViewModel, bool>((p0) => p0.advSettings);

    return Dialog(
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 12.0,
      ),
      clipBehavior: Clip.none,
      backgroundColor: Colors.transparent,
      child: DialogWrapper(
        padding: const EdgeInsets.all(12.0),
        showClose: false,
        child: SizedBox(
          width: 246,
          height: advSettings ? 396 : 500,
          child: Column(
            children: [
              const Text(
                'Поздравляем!',
                style: ThemeText.mainTitle,
              ),
              Text(
                'Уровень ${$gameVm.fetchLevelIndex().toString()} пройден',
                style: ThemeText.subTitle,
              ),
              const SizedBox(
                height: 10,
              ),
              Stack(
                children: [
                  Image.asset(
                    'assets/images/word_done.png',
                    width: 180,
                  ),
                  Positioned(
                    top: 25,
                    left: 0,
                    right: 0,
                    child: Text(
                      $gameVm.lastGuessedWord.capitalize(),
                      textAlign: TextAlign.center,
                      style: ThemeText.wordItemCorrect.merge(
                        const TextStyle(
                          fontSize: 22,
                          color: Color(0xFF404040),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Stack(
                children: [
                  Image.asset(
                    'assets/images/complete_tree.png',
                    width: 150,
                  ),
                  Positioned(
                    top: 20,
                    left: 70,
                    right: 10,
                    child: AnimatedCounter(
                      suffix: '/${$gameVm.activeLevel.data.length}',
                      count: $gameVm.getAllDoneWords(),
                    ),
                  ),
                ],
              ),
              Stack(
                children: [
                  Image.asset(
                    'assets/images/complete_leaf.png',
                    width: 150,
                  ),
                  Positioned(
                    top: 20,
                    left: 70,
                    right: 10,
                    child: AnimatedCounter(
                      prefix: '+',
                      count: $gameVm.getCoinsByRound(),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      $gameVm.showBanner(context: context);
                      $gameVm.getNextLevel(context);
                      $analytics.fireEventWithMap(
                          AnalyticsEvents.onCompleteNextAction, {
                        'button': 'next_level',
                        'level_id': $gameVm.activeLevel.id,
                        'level': $gameVm.fetchLevelIndex(),
                      });
                    },
                    child: Image.asset(
                      'assets/images/next_level.png',
                      width: 176.0,
                    ),
                  ),
                ],
              ),
              if (!advSettings)
                GestureDetector(
                  onTap: () {
                    final params = {
                      'level_id': $gameVm.activeLevel.id,
                      'level': $gameVm.fetchLevelIndex(),
                      'word': $gameVm.focusedWord?.word ?? '',
                    };

                    final bool useOnlyApplePay = $conf.fetchUseOnlyApplePay();
                    if (useOnlyApplePay) {
                      final closeDialog = showLoadingScreen(context: context);
                      $paymentVM.buyProduct(
                        product: $paymentVM.productAdvOff!,
                        onComplete: (int coins) {
                          closeDialog();
                          $gameVm.buyPointsComplete(coins);
                          $gameVm.firePaymentComplete();
                          Navigator.of(context, rootNavigator: true).pop();
                          $gameVm.getNextLevel(context);
                        },
                        onError: () {
                          closeDialog();
                        },
                        context: context,
                      );
                      $analytics.fireEventWithMap(
                          AnalyticsEvents.advOff, params);
                    } else {
                      $analytics.fireEventWithMap(
                          AnalyticsEvents.advOff, params);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (context) => YouKassaPayment(
                              product: availableProducts
                                  .firstWhere((e) => e.id == 'adv_off'),
                              onSuccess: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                                $gameVm.getNextLevel(context);
                              }),
                        ),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Stack(
                      children: [
                        Image.asset(
                          'assets/images/turn_off_add.png',
                        ),
                        Positioned(
                          bottom: 26,
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
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedCounter extends StatefulWidget {
  final String suffix;
  final String prefix;
  final int count;

  const AnimatedCounter({
    Key? key,
    this.suffix = '',
    this.prefix = '',
    required this.count,
  }) : super(key: key);

  @override
  _AnimatedCounterState createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = _controller;
    _animation = Tween<double>(
      begin: _animation.value,
      end: widget.count.toDouble(),
    ).animate(CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      parent: _controller,
    ));
    _controller.forward();

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          '${widget.prefix}${_animation.value.toInt()}${widget.suffix}',
          textAlign: TextAlign.center,
          style: ThemeText.wordItemCorrect.merge(const TextStyle(fontSize: 22)),
        );
      },
    );
  }
}
