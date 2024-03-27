// ignore_for_file: prefer_relative_imports

import 'package:olympian/core/presentation/app_logo.dart';
import 'package:olympian/core/presentation/base_scaffold.dart';
import 'package:olympian/core/presentation/image_button.dart';
import 'package:olympian/core/services/analytics_service.dart';
import 'package:olympian/core/styles/styles.dart';
import 'package:olympian/features/onboarding/presentation/view/onboarding_screen.dart';
import 'package:olympian/features/settings/presentation/view/settings_dialog.dart';
import 'package:olympian/features/word_game/presentation/controls/score_bar.dart';
import 'package:olympian/shared.dart';

import '../viewmodels/game_viewmodel.dart';
import 'area_screen.dart';
import 'levels_screen.dart';

/// Меню игры / Точка входа
class EntryScreen extends StatelessWidget with WatchItMixin {
  const EntryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if ($settingsVM.showOnBoarding()) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const OnBoardingScreen(), fullscreenDialog: true),
        );
      }
    });
    return const BaseScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScoreBarLayout(),
          AppLogo(),
          PlayButton(),
          NextLevelView(),
          Gap(30),
          LevelScreenButton()
        ],
      ),
    );
  }
}

class ScoreBarLayout extends StatelessWidget {
  const ScoreBarLayout({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ScoreView(),
        ],
      ),
    );
  }
}

class PlayButton extends StatelessWidget {
  const PlayButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(right: 40),
        child: ImageButton(
          onTap: () {
            $gameVm.startPlayGame();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LevelsScreen()),
            );
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AreaScreen()),
            );
            $analytics.fireEvent(AnalyticsEvents.onPlayTap);
          },
          type: ImageButtonType.play,
          width: 230.0,
          height: 230.0,
        ),
      ),
    );
  }
}

class LevelScreenButton extends StatelessWidget {
  const LevelScreenButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ImageButton(
          onTap: () {
            $gameVm.playTapAudio();
            $analytics.fireEvent(AnalyticsEvents.onLevelsTap);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LevelsScreen()),
            );
          },
          type: ImageButtonType.stats,
          height: 70.0,
          width: 70.0,
        ),
        const Gap(20),
        // Settings Dialog
        ImageButton(
          onTap: () {
            $gameVm.playTapAudio();
            $analytics.fireEvent(AnalyticsEvents.onSettingsTap);
            showDialog(
                context: context,
                barrierColor: Colors.black38,
                builder: (_) => const SettingsDialog());
          },
          height: 70.0,
          width: 70.0,
        ),
      ],
    );
  }
}

class NextLevelView extends StatelessWidget with WatchItMixin {
  const NextLevelView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final lastActiveLevel =
        watchValue<GameViewModel, int>((vm) => vm.lastActiveLevel);
    $gameVm.fetchLastActiveLevelIndex();
    return Center(
      child: Text(
        'Продолжить: ${lastActiveLevel + 1} уровень',
        style: ThemeText.mainLabel,
      ),
    );
  }
}
