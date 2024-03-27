import '../../../../shared.dart';
import '../../data/models/promocode_model.dart';

class PromoCodeViewModel {
  final List<PromoCodeModel> _codes = [];
  final showPromoCode = ValueNotifier(false);

  init() async {
    var data = $conf.getPromoCodes();

    if (data['codes'] != null) {
      data['codes'].forEach((code) {
        _codes.add(PromoCodeModel.fromJson(code));
      });
    }
  }

  bool checkCode(String code) {
    final codeExist = _codes.any((element) => element.code == code); // true
    final isApplied = $DB.get('code_$code', false);

    if (!codeExist || isApplied) {
      return false;
    }

    $DB.put('code_$code', true);

    return true;
  }

  int getCoins(String code) {
    return _codes.firstWhere((element) => element.code == code).coins;
  }

  void toogleShowPromoCode() {
    showPromoCode.value = !showPromoCode.value;
  }
}
