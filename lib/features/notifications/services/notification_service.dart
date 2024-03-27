import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../../config/config.dart';
import '../../../shared.dart';
import '../data/models/notification_model.dart';

class NotificationService {
  init() {
    if (kDebugMode) {
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    }

    OneSignal.initialize(Config.oneSignalAppId);
    OneSignal.Location.setShared(false);
    OneSignal.Notifications.requestPermission(true);

    OneSignal.Notifications.addClickListener((event) {
      if (event.notification.additionalData == null) {
        return;
      }
      final data =
          NotificationModel.fromJson(event.notification.additionalData!);
      if (data.addCoins != 0) {
        OneSignal.User.addTagWithKey(
            NotificationDataKeys.notificationOpen.toString(), true);

        $gameVm.updateCoins(data.addCoins);
      }
    });

    OneSignal.Notifications.addPermissionObserver((permission) {
      OneSignal.User.addTagWithKey(
          NotificationDataKeys.notificationPermissionAccepted.toString(),
          permission);
    });
  }
}
