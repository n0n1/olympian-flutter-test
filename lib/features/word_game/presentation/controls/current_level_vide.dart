// Представление показыет текущий уровень в игре
// ignore_for_file: prefer_relative_imports

import 'package:olympian/core/styles/styles.dart';
import 'package:olympian/features/word_game/presentation/viewmodels/game_viewmodel.dart';
import 'package:olympian/shared.dart';

class CurretLevelView extends WatchingWidget {
  const CurretLevelView({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final levelIndex = watchValue<GameViewModel, int>((p0) => p0.levelIndex);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 6),
      child: Center(
        child: Text(
          'Уровень  $levelIndex',
          style: ThemeText.levelName,
        ),
      ),
    );
  }
}
