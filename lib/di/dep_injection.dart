import 'singeltons.dart';

export 'dep_injection.dart';

/// Impl inject logic
Future<void> inject() async {
  await registerSingletons();
}
