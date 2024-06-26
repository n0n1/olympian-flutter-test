// ignore_for_file: prefer_relative_imports

import 'package:flutter/material.dart';
import 'package:olympian/core/presentation/dialog_wrapper.dart';
import 'package:olympian/core/styles/styles.dart';
import 'package:olympian/shared_bl.dart';

class PromoCode extends StatefulWidget {
  const PromoCode({Key? key}) : super(key: key);

  @override
  State<PromoCode> createState() => _PromoCodeState();
}

class _PromoCodeState extends State<PromoCode> {
  final fieldController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    fieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: DialogWrapper(
        padding: const EdgeInsets.only(
          left: 28.0,
          right: 28.0,
          top: 28.0,
        ),
        child: SizedBox(
          width: 246,
          height: 250,
          child: Column(
            children: [
              const Text(
                'Введите промокод',
                style: ThemeText.shopTitle,
              ),
              const SizedBox(
                height: 40,
              ),
              TextField(
                textAlign: TextAlign.center,
                autofocus: true,
                controller: fieldController,
                decoration: const InputDecoration(
                  hintText: 'Промокод',
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromRGBO(100, 54, 12, 1),
                      width: 2.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              GestureDetector(
                onTap: () {
                  final result = $promoVM.checkCode(fieldController.text);

                  if (result) {
                    final coins = $promoVM.getCoins(fieldController.text);
                    $gameVm.buyPointsComplete(coins);
                    $gameVm.firePaymentComplete();
                    Navigator.pop(context);
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Промокод не найден'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'Cancel'),
                            child: const Text('Ок'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: Image.asset('assets/images/green_btn_apply.png'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
