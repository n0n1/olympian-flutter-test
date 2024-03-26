// ignore: unused_import
import 'package:firebase_core/firebase_core.dart';

import 'core/services/analytics_service.dart';
import 'core/services/audio_service.dart';
import 'core/services/config_service.dart';
import 'core/services/db_service.dart';
import 'features/notifications/services/notification_service.dart';
import 'features/payments/services/payment_service.dart';
import 'shared.dart';

// Styles
// AppColors get $colors => GetIt.I.get<AppColors>();
// AppStyles get $syles => GetIt.I.get<AppStyles>();

// BL
ConfigService get $conf => GetIt.I.get<ConfigService>();

// Data
DbService get $DB => GetIt.I.get<DbService>();

// Services
PaymentService get $payments => GetIt.I.get<PaymentService>();
AnalyticsService get $analytics => GetIt.I.get<AnalyticsService>();
AudioService get $audio => GetIt.I.get<AudioService>();
NotificationService get $notification => GetIt.I.get<NotificationService>();

// TODO: AdService


