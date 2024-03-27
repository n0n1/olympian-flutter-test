import 'package:flutter/foundation.dart';

import '../../../../core/presentation/dialog_wrapper.dart';
import '../../../../core/presentation/image_button.dart';
import '../../../../core/presentation/radio_image.dart';
import '../../../../core/presentation/restart_app.dart';
import '../../../../core/styles/styles.dart';
import '../../../../shared.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsDialog extends StatelessWidget with WatchItMixin {
  const SettingsDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final micEnabled =
        watchValue<SettingsViewModel, bool>((p0) => p0.micEnebled);
    final soundEnabled =
        watchValue<SettingsViewModel, bool>((p0) => p0.soundEnabled);
    $settingsVM.fetchPackageInfo();
    var version = watchValue<SettingsViewModel, String>((p0) => p0.appVersion);
    var buildNumber =
        watchValue<SettingsViewModel, String>((p0) => p0.buildNumber);
    return Dialog(
      elevation: 0,
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
      clipBehavior: Clip.none,
      backgroundColor: Colors.transparent,
      child: DialogWrapper(
        child: SizedBox(
          width: 280,
          height: MediaQuery.of(context).size.height * .55,
          child: Column(
            children: [
              const Gap(16),
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/mic.png',
                      width: 40,
                      height: 40,
                    ),
                    const Gap(20),
                    RadioImage(
                      value: micEnabled,
                      onTap: (_) => $settingsVM.toggleMic(),
                    ),
                  ],
                ),
              ),
              const Gap(16),
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/sound.png',
                      width: 40,
                      height: 40,
                    ),
                    const Gap(20),
                    RadioImage(
                      value: soundEnabled,
                      onTap: (_) => $settingsVM.toggleSound(),
                    ),
                  ],
                ),
              ),
              const Gap(26),
              ImageButton(
                onTap: () async {
                  await $settingsVM.reviewApp();
                },
                type: ImageButtonType.rate,
                width: 260.0,
                height: 80.0,
              ),
              Stack(
                children: [
                  if (kDebugMode)
                    GestureDetector(
                      onTap: () async {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('Вы уверены?'),
                            content: const Text(
                                'Будет удалено все прохождение и монеты'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, 'Cancel'),
                                child: const Text('Отмена'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await $settingsVM.clear();

                                  /// TODO: fixme, context on async
                                  RestartWidget.restartApp(context);
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  'Удалить',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Image.asset('assets/images/green_btn_reset.png'),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                'Version: $version, Build number: $buildNumber',
                style: ThemeText.info,
              )
            ],
          ),
        ),
      ),
    );
  }
}
