import '../../../../core/presentation/base_scaffold.dart';
import '../../../../core/styles/styles.dart';
import '../../../../shared.dart';
import '../../data/models/level_model.dart';
import '../controls/score_bar.dart';
import 'area_screen.dart';

/// Представление для просмотра уровней
///
class LevelsScreen extends StatelessWidget {
  const LevelsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final levels = $gameVm.levels;
    return BaseScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          slivers: [
            const SliverAppBar(
              automaticallyImplyLeading: false,
              pinned: false,
              snap: false,
              elevation: 0,
              floating: true,
              expandedHeight: 90.0,
              flexibleSpace: ScoreBar(
                prevScreen: 'Levels',
              ),
              backgroundColor: Colors.transparent,
            ),
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 0,
                mainAxisSpacing: 0,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return LevelItem(
                    index: index,
                    level: levels[index],
                  );
                },
                childCount: levels.length,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class LevelItem extends StatelessWidget {
  final int index;
  final LevelModel level;

  const LevelItem({
    Key? key,
    required this.level,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (level.state == LevelState.disabled) {
          return;
        }
        $gameVm.setActiveLevel(level);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AreaScreen()),
        );
      },
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (level.state == LevelState.success)
              Positioned(
                top: 6,
                right: -14,
                child: Transform.rotate(
                  angle: 0.6,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/leaf.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            if (level.state == LevelState.started)
              Positioned(
                top: 8,
                right: -16,
                child: Transform.rotate(
                  angle: 1,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/leaf_big.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            Image.asset(
              _getImage(level.state),
              width: 60,
              height: 60,
              fit: BoxFit.contain,
            ),
            Positioned(
              top: 4,
              left: 0,
              right: 0,
              child: Text(
                '${index + 1}',
                style: ThemeText.levelItemLabel,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getImage(state) {
    switch (state) {
      case LevelState.started:
      case LevelState.success:
      case LevelState.available:
        return 'assets/images/level_available.png';
      case LevelState.disabled:
      default:
        return 'assets/images/level_disabled.png';
    }
  }
}
