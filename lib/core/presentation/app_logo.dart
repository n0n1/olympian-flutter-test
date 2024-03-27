// ignore_for_file: prefer_relative_imports

import 'package:olympian/shared.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 60),
      child: Image.asset('assets/images/logo.png'),
    );
  }
}
