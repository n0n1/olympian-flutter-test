// ignore_for_file: prefer_relative_imports

import 'package:olympian/shared.dart';

class HelpButton extends StatelessWidget {
  final bool word;
  final bool defaultDisabled;
  final String? helpText;

  const HelpButton({
    Key? key,
    this.word = false,
    this.defaultDisabled = false,
    this.helpText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<State<Tooltip>>();

    final disabled = $gameVm.isBuy50Disabled() || defaultDisabled;

    if (word) {
      return Tooltip(
        message: helpText ?? 'Сначала выберите слово',
        key: key,
        child: GestureDetector(
          onTap: () {
            if (disabled) {
              final dynamic tooltip = key.currentState;
              tooltip?.ensureTooltipVisible();
              return;
            }
            $gameVm.buyPrompt50(context);
          },
          child: Container(
            width: 74,
            margin: const EdgeInsets.only(bottom: 4),
            child: Image.asset(
                "assets/images/rand_help_word${disabled ? '_disabled' : ''}.png"),
          ),
        ),
      );
    }

    final isBuy25Disabled = $gameVm.isBuy25Disabled() || defaultDisabled;

    return Tooltip(
      message: helpText ?? 'Перейдите на список слов',
      key: key,
      child: GestureDetector(
        onTap: () {
          if (isBuy25Disabled) {
            final dynamic tooltip = key.currentState;
            tooltip?.ensureTooltipVisible();
            return;
          }
          $gameVm.buyPrompt(context);
        },
        child: Container(
          width: 74,
          margin: const EdgeInsets.only(bottom: 4),
          child: Image.asset(
              "assets/images/rand_help${isBuy25Disabled ? '_disabled' : ''}.png"),
        ),
      ),
    );
  }
}
