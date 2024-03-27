import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../../../../shared.dart';
import '../../data/models/products_model.dart';

class YouKassaPayment extends StatefulWidget {
  final ProductItem product;
  final VoidCallback? onSuccess;

  const YouKassaPayment({
    Key? key,
    required this.product,
    this.onSuccess,
  }) : super(key: key);

  @override
  State<YouKassaPayment> createState() => _YouKassaPaymentState();
}

class _YouKassaPaymentState extends State<YouKassaPayment> {
  late final WebViewController _webCtrl;

  @override
  void initState() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams();
    } else {
      params = AndroidWebViewControllerCreationParams();
    }

    _webCtrl = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(
        const Color(0x00000000),
      );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final t = $paymentVM.createYouKassaToken(widget.product);

      _webCtrl.loadFlutterAsset('assets/html/index.html');
      _webCtrl.setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (request) {
          if (request.url
              .startsWith('https://olympianapp.app/?state=success')) {
            _paymentSuccess();
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
        onPageFinished: (String url) {
          _webCtrl.runJavaScript("setup('$t');");
        },
      ));
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _paymentSuccess() {
    String alertText = widget.product.id == 'adv_off'
        ? 'Реклама отключена'
        : 'Вам начислено ${widget.product.coins} монет';
    if (widget.product.id == 'adv_off') {
      $gameVm.turnOffAdv();
    } else {
      $gameVm.buyPointsComplete(widget.product.coins);
      $gameVm.firePaymentComplete();
    }

    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Оплата успешно проведена!'),
          content: Text(alertText),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                if (widget.onSuccess != null) {
                  widget.onSuccess!();
                }
              },
              child: const Text('Продолжить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Оплата'),
        backgroundColor: const Color(0xFF43311D),
      ),
      body: $paymentVM.isPaymentInProgress
          ? _buildProgress()
          : WebViewWidget(
              controller: _webCtrl,
            ),
    );
  }

  _buildProgress() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
