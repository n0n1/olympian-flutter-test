import '../../../../core/presentation/dialog_wrapper.dart';
import '../../../../core/presentation/image_button.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/styles/styles.dart';
import '../../../../shared.dart';

class WrongAnswerDialog extends StatefulWidget {
  const WrongAnswerDialog({Key? key}) : super(key: key);

  @override
  State<WrongAnswerDialog> createState() => _WrongAnswerDialogState();
}

class _WrongAnswerDialogState extends State<WrongAnswerDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
      clipBehavior: Clip.none,
      backgroundColor: Colors.transparent,
      child: DialogWrapper(
        child: SizedBox(
          width: 280,
          height: 330,
          child: Column(
            children: [
              Text(
                'У вас закончились \n попытки',
                textAlign: TextAlign.center,
                style: ThemeText.mainTitle.copyWith(
                  fontSize: 28,
                  color: const Color.fromRGBO(
                    100,
                    54,
                    12,
                    1,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'Получить 5 попыток',
                textAlign: TextAlign.center,
                style: ThemeText.mainTitle.copyWith(
                  fontSize: 24,
                  color: const Color.fromRGBO(
                    100,
                    54,
                    12,
                    1,
                  ),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              ImageButton(
                onTap: () {
                  $gameVm.buyAttempt();
                  Navigator.of(context).pop();
                },
                type: ImageButtonType.spend,
                width: 220,
                height: 65,
              ),
              const SizedBox(
                height: 14,
              ),
              Text(
                'ИЛИ',
                textAlign: TextAlign.center,
                style: ThemeText.mainTitle.copyWith(
                  fontSize: 24,
                  color: const Color.fromRGBO(
                    100,
                    54,
                    12,
                    1,
                  ),
                ),
              ),
              const SizedBox(
                height: 14,
              ),
              FutureBuilder<bool>(
                builder: (context, AsyncSnapshot<bool> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!) {
                      return ImageButton(
                        onTap: () {
                          $analytics.fireEvent(AnalyticsEvents.onShowAdvTap);
                          $gameVm.showAd(() {
                            $gameVm.wrongAnswerCount.value = 0;
                            Navigator.of(context).pop();
                          });
                        },
                        type: ImageButtonType.watchAdd,
                        width: 220,
                        height: 65,
                      );
                    }
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color.fromRGBO(
                          100,
                          54,
                          12,
                          1,
                        ),
                      ),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color.fromRGBO(
                        100,
                        54,
                        12,
                        1,
                      ),
                    ),
                  );
                },
                initialData: false,
                future: $gameVm.canShowAd(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
