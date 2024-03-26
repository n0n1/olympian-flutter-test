import 'package:dio/dio.dart';

import '../models/products_model.dart';
import '../shared.dart' show $conf;

class PaymentService {
  Future<String> createYouKassaToken(ProductItem product) async {
    String token = '';

    var dio = Dio();
    dio.options.headers.addAll({
      'Authorization': $conf.getYouKassaAuth(),
      'Content-Type': 'application/json',
      'Idempotence-Key': DateTime.now().toIso8601String(),
    });

    try {
      final order = {
        'amount': {'value': product.price.toDouble(), 'currency': 'RUB'},
        'confirmation': {'type': 'embedded'},
        'capture': true,
        'description': 'Заказ время: ${DateTime.now()} тип: ${product.coins}'
      };
      final response =
          await dio.post('https://api.yookassa.ru/v3/payments', data: order);
      final Map<String, dynamic> json = response.data;

      token = json['confirmation']['confirmation_token'];
      return token;
    } catch (e) {
      // print(e);
      // do nothing.
    }

    return token;
  }
}
