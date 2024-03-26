import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:provider/provider.dart';

import 'di/dep_injection.dart';
import 'screens/entry_screen.dart';
// import 'services/ad_service.dart';

import 'shared.dart';
import 'viewmodels/game_viewmodel.dart';
import 'viewmodels/payment_viewmodel.dart';
import 'viewmodels/promocode_viewmodel.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'widgets/restart_app.dart';

Future<void> configureDeps() async {
  await $conf.init();
  await $DB.init();
  await $audio.init();
  await $analytics.init();

  // TODO: fixme in android veresion
  // if (defaultTargetPlatform == TargetPlatform.android) {
  //   // TODO: enablePendingPurchases is deprecated
  //   InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
  // }

  if (kReleaseMode) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  }
}

Future<void> main() async {
  await Hive.initFlutter();
  await inject();
  await configureDeps();

  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const _App());
  }, (error, stackTrace) {
    if (kDebugMode) {
      print(error);
      print(stackTrace);
      print('runZonedGuarded: Caught error in my root zone.');
    }

    if (kReleaseMode) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    }
  });
}

class _App extends StatefulWidget {
  const _App({Key? key}) : super(key: key);

  @override
  State<_App> createState() => _AppState();
}

class _AppState extends State<_App> {
  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom],
    );
    return RestartWidget(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => GameViewModel()),
          ChangeNotifierProvider(create: (_) => SettingsViewModel()),
          ChangeNotifierProvider(create: (_) => PromoCodeViewModel()),
          ChangeNotifierProvider(create: (_) => PaymentViewModel()),
        ],
        builder: (context, child) {
          return MaterialApp(
            title: 'Олимпийка',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              textSelectionTheme: const TextSelectionThemeData(
                cursorColor: Colors.black,
                selectionColor: Colors.black26,
                selectionHandleColor: Colors.black,
              ),
            ),
            home: const EntryScreen(),
          );
        },
      ),
    );
  }
}
