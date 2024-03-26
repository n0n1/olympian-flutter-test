import 'package:get_it/get_it.dart';

import '../core/presentation/viewmodels/app_view_mode.dart';
import '../core/services/analytics_service.dart';
import '../core/services/audio_service.dart';
import '../core/services/config_service.dart';
import '../core/services/db_service.dart';
import '../features/notifications/services/notification_service.dart';
import '../features/payments/services/payment_service.dart';

/// Create singletons (logic and services) that can be shared across the app.
Future<void> registerSingletons() async {
  // Конфиги приложения
  GetIt.I.registerLazySingleton<ConfigService>(() => ConfigService());
  // Сервис для работы с базой данных
  GetIt.I.registerLazySingleton<DbService>(() => DbService());
  // Сервис для обработки платежей
  GetIt.I.registerLazySingleton<PaymentService>(() => PaymentService());
  // Аудио сервис
  GetIt.I.registerLazySingleton<AudioService>(() => AudioService());

  // Сервис для обработки уведомлений
  GetIt.I
      .registerLazySingleton<NotificationService>(() => NotificationService());
  GetIt.I.registerLazySingleton<AnalyticsService>(() => AnalyticsService());

  // ViewModel приложения
  GetIt.I.registerLazySingleton<AppViewModel>(() => AppViewModel());
}
