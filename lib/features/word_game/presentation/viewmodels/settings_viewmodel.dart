import 'package:flutter/foundation.dart';

import '../../../../core/services/analytics_service.dart' show AnalyticsEvents;
import '../../../../shared.dart' show $analytics, $DB, $audio;

class SettingsViewModel with ChangeNotifier {
  int get sound => $DB.get('sound', 1);
  int get mic => $DB.get('mic', 1);

  toggleSound() {
    $audio.playTap();
    $DB.put('sound', sound == 1 ? 0 : 1);
    $analytics.fireEvent(
        sound == 1 ? AnalyticsEvents.onSoundOn : AnalyticsEvents.onSoundOff);
    notifyListeners();
  }

  toggleMic() {
    $audio.playTap();
    $DB.put('mic', mic == 1 ? 0 : 1);
    $analytics.fireEvent(
        mic == 1 ? AnalyticsEvents.onMusicOn : AnalyticsEvents.onMusicOff);
    notifyListeners();
  }

  clear() async {
    await $DB.clear();
    notifyListeners();
  }

  bool showOnBoarding() {
    return $DB.get('onboarding', true);
  }

  setOnBoardingDone() {
    $DB.put('onboarding', false);
  }
}
