import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

// import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import 'core/presentation/restart_app.dart';
import 'di/dep_injection.dart';
import 'features/word_game/presentation/view/entry_screen.dart';
import 'shared.dart';

Future<void> configureDeps() async {
  // TODO: fixme in android veresion
  // if (defaultTargetPlatform == TargetPlatform.android) {
  //   // TODO: enablePendingPurchases is deprecated
  //   InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
  // }
  if (kReleaseMode) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

Future<void> main() async {
  await Hive.initFlutter();
  await inject();
  // await GetIt.I.allReady();
  await configureDeps();

  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _App());
  // TODO: fixme
  // runZonedGuarded(() async {

  // }, (error, stackTrace) {
  //   if (kDebugMode) {
  //     print(error);
  //     print(stackTrace);
  //     print('runZonedGuarded: Caught error in my root zone.');
  //   }

  //   if (kReleaseMode) {
  //     FirebaseCrashlytics.instance.recordError(error, stackTrace);
  //   }
  // });
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
      child: MaterialApp(
          title: 'Олимпийка',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: Colors.black,
              selectionColor: Colors.black26,
              selectionHandleColor: Colors.black,
            ),
          ),
          home: FutureBuilder(
            future: GetIt.I.allReady(),
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
              if (snapshot.hasData) {
                return const EntryScreen();
              } else {
                return Container(
                  color: Colors.red[100],
                  child: const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                );
              }
            },
          )),
    );
  }
}
