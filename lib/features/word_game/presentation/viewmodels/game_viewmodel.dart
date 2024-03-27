import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/utils/format.dart';
import '../../../../shared.dart';
import '../../../ad/presentation/view/adv_time_screen.dart';
import '../../../notifications/data/models/notification_model.dart';
import '../../../payments/presentation/view/shop_dialog.dart';
import '../../data/models/level_model.dart';
import '../../data/models/word_model.dart';
import '../dialogs/game_complete_dialog.dart';
import '../dialogs/level_complete_dialog.dart';
import '../dialogs/wrong_answer_dialog.dart';

// ignore_for_file: constant_identifier_names
const int maxFailedLoadAttempts = 3;
// const maxWrongAnswerCount = 5;

/// TODO: adservice

class GameViewModel {
  // Game Levels
  List<LevelModel> levels = [];
  late LevelModel activeLevel; // current level
  final levelIndex = ValueNotifier<int>(0);
  // index of last level
  final lastActiveLevel = ValueNotifier<int>(0);

  bool isFirstLevelComplete = false;

  // Word groups
  List<List<WordModel>> groups = [];

  WordModel? focusedWord;
  WordModel? scrollableWord;
  String lastGuessedWord = '';

  // Answer
  final wrongAnswerCount = ValueNotifier<int>(0);
  //TODO: закомментированный код показа рекламы после 5 неверных попыток
  // bool get showWrongAnswerDialog => wrongAnswerCount >= maxWrongAnswerCount;
  bool get showWrongAnswerDialog => false;

  GlobalKey? scrollKey;

  /// Coins
  // All coins in game
  final coins = ValueNotifier<int>(0);
  // By Round
  final coinsByRound = ValueNotifier<int>(0);

  final advSettings = ValueNotifier<bool>(false);

  init() async {
    levels = $DB.getLevels();

    // Дефолтный уровень
    activeLevel = levels.first;

    /// Получение данных с бд
    coins.value = $DB.getCoins();
    wrongAnswerCount.value = $DB.getWrongAnswerCount();

    // Если первый уровень не открыт
    if (levels.first.state == LevelState.disabled) {
      levels.first.state = LevelState.available;
    }

    _cacheImages();
    _save();
  }

  // Проверяет пройден ли уровень
  bool _isLevelComplete() {
    final isComplete =
        activeLevel.data.where((e) => e.state != WordState.correct).isEmpty;
    if (isComplete) {
      if (fetchLevelIndex() == 1 && !isFirstLevelComplete) {
        isFirstLevelComplete = true;
        $analytics.fireEvent(AnalyticsEvents.activation);
      }

      activeLevel.state = LevelState.success;
      final lastCompleteLevel =
          levels.indexWhere((e) => e.id == activeLevel.id);

      final nextOpenLevel = lastCompleteLevel + 1;
      if (nextOpenLevel < levels.length &&
          levels[nextOpenLevel].state != LevelState.success) {
        levels[nextOpenLevel].state = LevelState.available;
        _cacheImages();
      }
    }
    return isComplete;
  }

  // Запуск игры
  void startPlayGame() {
    playTapAudio();
    //
    fetchLastActiveLevelIndex();
    setActiveLevel(lastActiveLevel.value == -1
        ? levels[0]
        : levels[lastActiveLevel.value]);
  }

  /// Levels BL

  void fetchLastActiveLevelIndex() {
    lastActiveLevel.value = levels.indexWhere((l) =>
        (l.state == LevelState.available || l.state == LevelState.started));
  }

  // Добавляем активный уровень
  setActiveLevel(LevelModel level) {
    activeLevel = level;
    coinsByRound.value = 0;

    final maxDepth = activeLevel.data.map<int>((e) => e.depth).reduce(max);
    activeLevel.data = activeLevel.data.map((word) {
      if (word.state == WordState.correct) {
        final isEven = activeLevel.data.indexOf(word) % 2 == 1;
        if (maxDepth == word.depth) {
          word.showStartLeaf = true;
          word.showEndLeaf = true;
        }
        if (isEven) {
          word.showOddLeaf = true;
        } else {
          word.showEvenLeaf = true;
        }
      }
      return word;
    }).toList();

    groups = groupBy(activeLevel.data, (WordModel obj) => obj.depth)
        .values
        .toList()
        .reversed
        .toList();
  }

  // Добавляет в след слово листочки
  _checkNextWordLeaf(WordModel word) {
    final depthWords = activeLevel.data
        .where((element) => element.depth == word.depth)
        .toList();

    final wordIndex = depthWords.indexOf(word);
    final isEven = wordIndex % 2 == 1;

    // Помечаем дочерний элемент
    final nextDepth = word.depth / 2;
    final nextDepthWords = activeLevel.data
        .where((element) => element.depth == nextDepth)
        .toList();

    final actIndex =
        isEven ? (wordIndex / 2).round() - 1 : (wordIndex / 2).round();
    if (isEven) {
      nextDepthWords[actIndex].showEndLeaf = true;
    } else if (nextDepthWords.asMap().containsKey(actIndex)) {
      nextDepthWords[actIndex].showStartLeaf = true;
    }
  }

  // Проверка слова на корректность
  checkWord({
    required WordModel word,
    required String value,
    required BuildContext ctx,
    bool closeDialogOnComplete = false,
  }) {
    final formatted = formatWord(value);
    final isCorrect = word.synonyms.any((element) => formatted == element);

    if (isCorrect) {
      wrongAnswerCount.value = 0;
      word.state = WordState.correct;
      $audio.playRightAnswer();

      lastGuessedWord = word.word;

      final depthWords = activeLevel.data
          .where((element) => element.depth == word.depth)
          .toList();

      final wordIndex = depthWords.indexOf(word);
      final isEven = wordIndex % 2 == 1;

      // Помечаем дочерний элемент
      _checkNextWordLeaf(word);

      coins.value += $conf.appConfig.anyWordCoins;
      coinsByRound.value += $conf.appConfig.anyWordCoins;

      // Добавляем монеты для не 1 уровня
      if (word.depth != 1) {
        // Добавляем монеты
        final nextPairIndex = isEven ? wordIndex - 1 : wordIndex + 1;
        if (depthWords.asMap().containsKey(nextPairIndex)) {
          if (depthWords[nextPairIndex].state == WordState.correct) {
            coins.value += $conf.appConfig.coupleOfWordsCoins;
            coinsByRound.value += $conf.appConfig.coupleOfWordsCoins;
          }
        }

        // Монеты за прохождение всех слов в столбце
        final isRowComplete = depthWords
                .where((element) => element.state == WordState.correct)
                .length ==
            depthWords.length;

        if (isRowComplete) {
          coins.value += $conf.appConfig.entireColumnsCoins;
          coinsByRound.value += $conf.appConfig.entireColumnsCoins;
        }
      }

      // Монеты если разгадал все
      if (_isLevelComplete()) {
        coins.value += $conf.appConfig.finalWordOfTheLevelCoins;
        coinsByRound.value += $conf.appConfig.finalWordOfTheLevelCoins;

        if (closeDialogOnComplete) {
          Navigator.of(ctx, rootNavigator: true).pop();
        }

        showDialog(
          context: ctx,
          barrierDismissible: false,
          builder: (_) {
            return const LevelCompleteDialog();
          },
        );
      }

      _addWordLeaf(word, wordIndex);
    } else if (value != '') {
      wrongAnswerCount.value += 1;
      $analytics.fireEventWithMap(AnalyticsEvents.onWordMistake, {
        'level_id': activeLevel.id,
        'level': fetchLevelIndex(),
        'value': formatted,
        'word': word.word,
        'wordIndex': activeLevel.data.indexWhere((element) => element == word),
      });
      $audio.playWrongAnswer();
      word.state = WordState.incorrect;
    } else {
      word.state = WordState.idle;
    }

    if (activeLevel.state == LevelState.available) {
      activeLevel.state = LevelState.started;

      $analytics.fireEventWithMap(
        AnalyticsEvents.onLevelStart,
        {
          'level_id': activeLevel.id,
          'level': fetchLevelIndex(),
          'coins': coins,
        },
      );
    }

    _save();

    return isCorrect;
  }

  showBanner({required BuildContext context}) {
    // Показ баннера
    if (fetchLevelIndex() > 1) {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) =>
              const AdvTimeScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

  void turnOffAdv() {
    $DB.saveAdvSetting();
    // _ad.turnOffAdd();
  }

  void fetchAdvSettings() {
    advSettings.value = $DB.getAdvSetting();
  }

  void _addWordLeaf(WordModel word, int wordIndex) {
    final isEven = (wordIndex) % 2 == 1;

    // Если это 1 группа ставим листочки
    if (groups.first.contains(word)) {
      word.showStartLeaf = true;
      word.showEndLeaf = true;
    }

    // Помечаем листья для четного нечетного порядка
    if (isEven) {
      word.showEvenLeaf = true;
    } else {
      word.showOddLeaf = true;
    }

    if (word.depth == 1) {
      word.showEndLeaf = false;
      word.showStartLeaf = false;
      word.showOddLeaf = false;
      word.showEvenLeaf = false;
    }
  }

  // Фокус на вводе
  void wordFocus({
    required WordModel word,
    required bool focus,
  }) {
    if (word.state == WordState.correct) {
      return;
    }
    word.state = focus ? WordState.input : WordState.idle;
    try {
      focusedWord =
          activeLevel.data.firstWhere((w) => w.state == WordState.input);
    } catch (e) {
      focusedWord = null;
    }
  }

  void showWrongAnswerModalDialog({
    required BuildContext context,
    required VoidCallback onShow,
  }) {
    onShow();
    showDialog(
      context: context,
      barrierColor: Colors.black38,
      builder: (ctx) => const WrongAnswerDialog(),
    );
  }

  void buyPointsComplete(int newCoins) {
    coins.value += newCoins;
    _save();
  }

  void firePaymentComplete() {
    $analytics.fireEventWithMap(
      AnalyticsEvents.onPaymentComplete,
      {
        'coins': coins,
        'level_id': activeLevel.id,
        'level': fetchLevelIndex(),
      },
    );
  }

  // Покупка подсказки за 25
  void buyPrompt(context) {
    /// Нет монет купи
    if (coins.value < $conf.appConfig.randomHintCost) {
      $analytics.fireEventWithMap(AnalyticsEvents.onMonetizationNoEnoughScore, {
        'level_id': activeLevel.id,
        'level': fetchLevelIndex(),
        'screen': 'HelpScreen25',
      });
      showDialog(
        context: context,
        barrierColor: Colors.black38,
        builder: (ctx) => const ShopDialog(
          title: 'Недостаточно монет',
        ),
      ).then(
        (value) => $analytics.fireEventWithMap(
          AnalyticsEvents.onMonetizationWindowClose,
          {
            'level_id': activeLevel.id,
            'level': fetchLevelIndex(),
            'screen': 'HelpScreen25',
          },
        ),
      );
      return;
    }

    /// Уровень пройден
    if (activeLevel.state == LevelState.success) {
      return;
    }

    final random = Random();
    final words = groups
        .firstWhere((group) =>
            group.firstWhereOrNull((w) =>
                (w.state == WordState.idle || w.state == WordState.input)) !=
            null)
        .toList();

    final idleWords =
        words.where((word) => word.state != WordState.correct).toList();

    final max = idleWords.length;
    final randWord = idleWords[random.nextInt(max)];
    // Нельзя купить последнее слово
    if (randWord.depth == 1) {
      return;
    }

    final wordIndex = words.indexOf(randWord);

    randWord.state = WordState.correct;
    _addWordLeaf(randWord, wordIndex);

    _checkNextWordLeaf(randWord);

    // Списываем монеты
    coins.value -= $conf.appConfig.randomHintCost;

    scrollableWord = randWord;

    wrongAnswerCount.value = 0;

    if (activeLevel.state == LevelState.available) {
      activeLevel.state = LevelState.started;
      $analytics.fireEventWithMap(
        AnalyticsEvents.onLevelStart,
        {
          'level_id': activeLevel.id,
          'level': fetchLevelIndex(),
          'coins': coins,
        },
      );
    }

    if (_isLevelComplete()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return const LevelCompleteDialog();
        },
      );
    }

    lastGuessedWord = randWord.word;

    $analytics.fireEventWithMap(AnalyticsEvents.onHintRandomWord, {
      'level_id': activeLevel.id,
      'level': fetchLevelIndex(),
      'word': randWord.word,
      'wordIndex': wordIndex,
    });

    _save();
  }

  // Подсказка за 50
  void buyPrompt50(context) {
    if (focusedWord == null) {
      return;
    }

    /// Нет монет купи
    if (coins.value < $conf.appConfig.wordHintCost) {
      showDialog(
        context: context,
        barrierColor: Colors.black38,
        builder: (ctx) => const ShopDialog(
          title: 'Недостаточно монет',
        ),
      ).then(
        (value) => $analytics
            .fireEventWithMap(AnalyticsEvents.onMonetizationWindowClose, {
          'level_id': activeLevel.id,
          'level': fetchLevelIndex(),
          'screen': 'HelpScreen50',
        }),
      );
      $analytics.fireEventWithMap(AnalyticsEvents.onMonetizationNoEnoughScore, {
        'level_id': activeLevel.id,
        'level': fetchLevelIndex(),
        'screen': 'HelpScreen50',
      });
      return;
    }

    _checkNextWordLeaf(focusedWord!);

    focusedWord!.state = WordState.correct;
    final wordIndex = activeLevel.data.indexOf(focusedWord!);
    _addWordLeaf(activeLevel.data[wordIndex], wordIndex + 1);

    coins.value -= $conf.appConfig.wordHintCost;

    if (focusedWord!.image != '' || focusedWord!.description != '') {
      Navigator.pop(context, false);
    }

    lastGuessedWord = focusedWord!.word;
    FocusScope.of(context).requestFocus(FocusNode());

    _save();

    $analytics.fireEventWithMap(AnalyticsEvents.onHintOpenWord, {
      'level_id': activeLevel.id,
      'level': fetchLevelIndex(),
      'word': focusedWord!.word,
      'wordIndex': wordIndex,
    });

    if (activeLevel.state == LevelState.available) {
      activeLevel.state = LevelState.started;
      $analytics.fireEventWithMap(
        AnalyticsEvents.onLevelStart,
        {
          'level_id': activeLevel.id,
          'level': fetchLevelIndex(),
          'coins': coins,
        },
      );
    }

    wrongAnswerCount.value = 0;

    if (_isLevelComplete()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return const LevelCompleteDialog();
        },
      );
    } else {
      clearActiveWord();
    }
  }

  // Подсказка за 50
  void buyAttempt() {
    coins.value -= 10;
    wrongAnswerCount.value = 0;
    _save();
  }

  Future<bool> canShowAd() async {
    // return _ad.canShowAd();
    return false;
  }

  showAd(Function onDone) async {
    // _analytics.fireEventWithMap(AnalyticsEvents.onShowAdsWorking, {
    //   'level_id': activeLevel.id,
    //   'level': getLevelIndex(),
    //   'word': focusedWord?.word ?? '',
    // });
    // _ad.show(() {
    //   onDone();
    //   buyPointsComplete(_conf.appConfig.advViewCoins);
    //   _analytics.fireEventWithMap(
    //     AnalyticsEvents.onAdsWatched,
    //     {
    //       'coins': coins,
    //       'level_id': activeLevel.id,
    //       'level': getLevelIndex(),
    //     },
    //   );
    // });
  }

  clearActiveWord() {
    focusedWord = null;
  }

  getNextLevel(BuildContext context) {
    var index =
        levels.indexWhere((element) => element.state != LevelState.success);
    if (index == -1) {
      showDialog(
        context: context,
        barrierColor: Colors.black38,
        builder: (ctx) => const GameCompleteDialog(),
      );
      return;
    }
    setActiveLevel(levels[index]);

    scrollableWord = groups.first[0];

    _save();
  }

  setScrollableWord(WordModel word) {
    scrollableWord = word;
  }

  scrollToWidget() {
    if (scrollKey?.currentContext != null) {
      Scrollable.ensureVisible(scrollKey!.currentContext!);
      scrollableWord = null;
    }
  }

  int fetchLevelIndex() {
    levelIndex.value = levels.indexWhere((e) => e.id == activeLevel.id) + 1;
    return levelIndex.value;
  }

  getAllDoneWords() {
    return activeLevel.data
        .where((element) => element.state == WordState.correct)
        .length;
  }

  /// Play audio on tap
  void playTapAudio() {
    $audio.playTap();
  }

  _save() {
    /// Сохранение
    for (var level in levels) {
      $DB.saveLevel(level);
    }
    $DB.saveLevel(activeLevel);
    $DB.saveCoins(coins.value);
    $DB.saveWrongAnswerCount(wrongAnswerCount.value);

    OneSignal.User.addTags({
      NotificationDataKeys.notificationActiveLevel: activeLevel.id,
      NotificationDataKeys.notificationAdvSettings: advSettings.value,
      NotificationDataKeys.notificationCoins: coins,
    });
  }

  _cacheImages() {
    for (final lvl
        in levels.where((element) => element.state == LevelState.available)) {
      final wordsWithImage =
          lvl.data.where((element) => element.image.isNotEmpty);
      for (final word in wordsWithImage) {
        DefaultCacheManager().downloadFile(word.image);
      }
    }
  }

  bool isLastWord() {
    return activeLevel.data
            .where((elm) =>
                elm.state == WordState.idle || elm.state == WordState.input)
            .length ==
        1;
  }

  isBuy50Disabled() {
    return focusedWord == null || _isLevelComplete();
  }

  isBuy25Disabled() {
    return focusedWord != null ||
        _isLevelComplete() ||
        getAllDoneWords() == activeLevel.data.length - 1;
  }

  /// Добавление монеток
  addCoins(int addCoins) {
    final newCoins = $DB.getCoins() + addCoins;
    coins.value = newCoins;
    $DB.saveCoins(coins.value);
  }
}
