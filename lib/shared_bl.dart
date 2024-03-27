// ignore: unused_import
import 'package:firebase_core/firebase_core.dart';

import 'core/presentation/viewmodels/app_view_mode.dart';
import 'core/services/analytics_service.dart';
import 'core/services/audio_service.dart';
import 'core/services/config_service.dart';
import 'core/services/db_service.dart';
import 'features/notifications/services/notification_service.dart';
import 'features/payments/presentation/viewmodels/payment_viewmodel.dart';
import 'features/payments/presentation/viewmodels/promocode_viewmodel.dart';
import 'features/payments/services/payment_service.dart';
import 'features/settings/presentation/viewmodels/settings_viewmodel.dart';
import 'features/word_game/presentation/viewmodels/area_viewmodel.dart';
import 'features/word_game/presentation/viewmodels/game_viewmodel.dart';
import 'shared.dart';

// Styles
// AppColors get $colors => GetIt.I.get<AppColors>();
// AppStyles get $syles => GetIt.I.get<AppStyles>();

// Data
DbService get $DB => GetIt.I.get<DbService>();
// Services
PaymentService get $payments => GetIt.I.get<PaymentService>();
AnalyticsService get $analytics => GetIt.I.get<AnalyticsService>();
AudioService get $audio => GetIt.I.get<AudioService>();
NotificationService get $notification => GetIt.I.get<NotificationService>();
ConfigService get $conf => GetIt.I.get<ConfigService>();
// TODO: AdService

/// Area scroll controller
ScrollController get $areaScroller => ScrollController();

// BL
AppViewModel get $appVm => GetIt.I.get<AppViewModel>();
GameViewModel get $gameVm => GetIt.I.get<GameViewModel>();
AreaViewModel get $areaVm => GetIt.I.get<AreaViewModel>();
PaymentViewModel get $paymentVM => GetIt.I.get<PaymentViewModel>();
PromoCodeViewModel get $promoVM => GetIt.I.get<PromoCodeViewModel>();
SettingsViewModel get $settingsVM => GetIt.I.get<SettingsViewModel>();
