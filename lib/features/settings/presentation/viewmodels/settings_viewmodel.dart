// ignore_for_file: prefer_relative_imports

import 'package:in_app_review/in_app_review.dart';
import 'package:olympian/core/services/analytics_service.dart'
    show AnalyticsEvents;
import 'package:olympian/shared.dart'
    show $DB, $analytics, $audio, $conf, $gameVm, ValueNotifier;
import 'package:package_info_plus/package_info_plus.dart';

class SettingsViewModel {
  final micEnebled = ValueNotifier<bool>(true);
  final soundEnabled = ValueNotifier<bool>(true);
  final appVersion = ValueNotifier<String>('');
  final buildNumber = ValueNotifier<String>('');

  final InAppReview inAppReview = InAppReview.instance;

  PackageInfo packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  Future<void> fetchPackageInfo() async {
    packageInfo = await PackageInfo.fromPlatform();
    appVersion.value = packageInfo.version;
    buildNumber.value = packageInfo.buildNumber;
  }

  Future<void> reviewApp() async {
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
      $analytics.fireEvent(AnalyticsEvents.onAppReviewTap);
    }
  }

  Future<void> reviewAppOnLevelComplete() async {
    Future.delayed(const Duration(seconds: 1), () async {
      if ($gameVm.fetchLevelIndex() > $conf.getRatingMinThreshold() &&
          $gameVm.fetchLevelIndex() % $conf.getRatingStep() != 0) {
        await reviewApp();
      }
    });
  }

  toggleSound() {
    $audio.playTap();
    soundEnabled.value = soundEnabled.value ? false : true;
    $DB.put('sound', soundEnabled.value ? 0 : 1);
    $analytics.fireEvent(
      soundEnabled.value
          ? AnalyticsEvents.onSoundOn
          : AnalyticsEvents.onSoundOff,
    );
  }

  toggleMic() {
    $audio.playTap();
    micEnebled.value = micEnebled.value ? false : true;
    $DB.put('mic', micEnebled.value ? 0 : 1);
    $analytics.fireEvent(
      micEnebled.value ? AnalyticsEvents.onMusicOn : AnalyticsEvents.onMusicOff,
    );
  }

  /// Reset Game Data
  Future<void> clear() async {
    await $DB.clear();
  }

  bool showOnBoarding() {
    return $DB.get('onboarding', true);
  }

  void setOnBoardingDone() {
    $DB.put('onboarding', false);
  }
}
