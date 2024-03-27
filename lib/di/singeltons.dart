import 'package:get_it/get_it.dart';

import '../core/presentation/viewmodels/app_view_mode.dart';
import '../core/services/analytics_service.dart';
import '../core/services/audio_service.dart';
import '../core/services/config_service.dart';
import '../core/services/db_service.dart';
import '../features/notifications/services/notification_service.dart';
import '../features/payments/presentation/viewmodels/payment_viewmodel.dart';
import '../features/payments/presentation/viewmodels/promocode_viewmodel.dart';
import '../features/payments/services/payment_service.dart';
import '../features/settings/presentation/viewmodels/settings_viewmodel.dart';
import '../features/word_game/presentation/viewmodels/area_viewmodel.dart';
import '../features/word_game/presentation/viewmodels/game_viewmodel.dart';

/// Create singletons (logic and services) that can be shared across the app.
Future<void> registerSingletons() async {
  // Конфиги приложения
  GetIt.I.registerLazySingletonAsync<ConfigService>(
    () async {
      final ConfigService conf = ConfigService();
      await conf.init();
      return conf;
    },
  );
  await GetIt.instance.isReady<ConfigService>();
  // Сервис для работы с базой данных
  GetIt.I.registerSingletonAsync<DbService>(
    () async {
      final DbService db = DbService();
      await db.init();
      return db;
    },
    // dependsOn: [ConfigService],
  );

  await GetIt.instance.isReady<DbService>();

  // Аудио сервис
  GetIt.I.registerSingletonAsync<AudioService>(
    () async {
      final AudioService audio = AudioService();
      await audio.init();
      return audio;
    },
    // dependsOn: [DbService],
  );

  await GetIt.instance.isReady<DbService>();
  // Сервис для обработки платежей
  GetIt.I.registerLazySingleton<PaymentService>(() => PaymentService());
  // await GetIt.instance.isReady<PaymentService>();

  // Сервис для обработки уведомлений
  // init later
  GetIt.I
      .registerLazySingleton<NotificationService>(() => NotificationService());

  //
  GetIt.I.registerSingletonAsync<AnalyticsService>(
    () async {
      final analyticsService = AnalyticsService();
      await analyticsService.init();
      return analyticsService;
    },
    // dependsOn: [DbService],
  );

  await GetIt.instance.isReady<AnalyticsService>();

  // ViewModels

  GetIt.I.registerSingleton<AppViewModel>(AppViewModel());
  GetIt.I.registerSingleton<AreaViewModel>(AreaViewModel());
  GetIt.I.registerSingleton<PaymentViewModel>(PaymentViewModel());

  GetIt.I.registerSingletonAsync<PromoCodeViewModel>(
    () async {
      final promoCodeVM = PromoCodeViewModel();
      await promoCodeVM.init();
      return promoCodeVM;
    },
    // dependsOn: [ConfigService],
  );

  await GetIt.instance.isReady<PromoCodeViewModel>();

  GetIt.I.registerSingletonAsync<SettingsViewModel>(
    () async => SettingsViewModel(),
    // dependsOn: [DbService, AudioService, AnalyticsService],
  );

  await GetIt.instance.isReady<SettingsViewModel>();

  GetIt.I.registerSingletonAsync(
    () async {
      final GameViewModel gameViewModel = GameViewModel();
      await gameViewModel.init();
      return gameViewModel;
    },
    // dependsOn: [ConfigService, DbService, AnalyticsService],
  );

  await GetIt.instance.isReady<GameViewModel>();
}
