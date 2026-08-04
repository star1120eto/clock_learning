import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clock_learning/services/subscription_service.dart';

import '../helpers/fake_in_app_purchase_platform.dart';

/// 非同期初期化（コンストラクタからは await できない）が落ち着くまで待つ。
Future<void> _settle() async {
  for (var i = 0; i < 10; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

/// [service] が次に notifyListeners() するまで待つ。
Future<void> _waitForNotify(SubscriptionService service) {
  final completer = Completer<void>();
  void listener() {
    if (!completer.isCompleted) completer.complete();
  }

  service.addListener(listener);
  return completer.future.whenComplete(() => service.removeListener(listener));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.flutter.io/shared_preferences');
  late FakeInAppPurchasePlatform fake;

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      if (call.method == 'getAll') return <String, dynamic>{};
      return null;
    });
    SharedPreferences.setMockInitialValues({});

    fake = FakeInAppPurchasePlatform();
    installFakeInAppPurchasePlatform(fake);
    SubscriptionService.restoreGraceDelay = Duration.zero;
  });

  tearDown(() async {
    SubscriptionService.restoreGraceDelay = const Duration(seconds: 2);
    await fake.dispose();
  });

  group('SubscriptionService', () {
    test('ストアが利用不可の場合、ローディングを終えてクラッシュしない', () async {
      fake.isAvailableValue = false;
      final service = SubscriptionService();

      await _settle();

      expect(service.isLoading, isFalse);
      expect(service.storeAvailable, isFalse);
      expect(service.isPremium, isFalse);
      expect(service.products, isEmpty);
    });

    test('商品情報がロードされる', () async {
      fake.productsToReturn = [
        buildProduct(id: kMonthlySubId, title: 'monthly'),
        buildProduct(id: kYearlySubId, title: 'yearly'),
      ];
      final service = SubscriptionService();

      await _settle();

      expect(service.products.length, 2);
      expect(service.monthlyProduct?.id, kMonthlySubId);
      expect(service.yearlyProduct?.id, kYearlySubId);
    });

    test('既知の商品IDの購入イベントでプレミアムになり、購入は完了扱いになる', () async {
      final service = SubscriptionService();
      await _settle();

      final notified = _waitForNotify(service);
      fake.emit([
        buildPurchase(productId: kMonthlySubId, status: PurchaseStatus.purchased),
      ]);
      await notified;
      await _settle();

      expect(service.isPremium, isTrue);
      expect(fake.completePurchaseCallCount, 1);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('is_premium'), isTrue);
    });

    test('未知の商品IDの購入イベントではプレミアムにならないが、購入は完了扱いになる', () async {
      // 現状の実装は productID の一致を見ずに completePurchase を呼ぶ。
      // 未知の商品を無条件に完了扱いにしている点は将来見直す余地があるが、
      // ここでは現状の挙動をそのまま固定する。
      // 対象IDが一致しない場合は _setPremium() が呼ばれず notifyListeners()
      // も発生しないため、通知待ちではなく settle() で完了を待つ。
      final service = SubscriptionService();
      await _settle();

      fake.emit([
        buildPurchase(productId: 'unknown_sku', status: PurchaseStatus.purchased),
      ]);
      await _settle();

      expect(service.isPremium, isFalse);
      expect(fake.completePurchaseCallCount, 1);
    });

    test('エラーステータスで purchaseError が設定される', () async {
      final service = SubscriptionService();
      await _settle();

      final notified = _waitForNotify(service);
      fake.emit([
        buildPurchase(
          productId: kMonthlySubId,
          status: PurchaseStatus.error,
          error: IAPError(source: 'test', code: 'x', message: 'てすとえらー'),
        ),
      ]);
      await notified;

      expect(service.purchaseError, 'てすとえらー');
    });

    test('キャンセルステータスで purchaseError がクリアされる', () async {
      final service = SubscriptionService();
      await _settle();

      final errored = _waitForNotify(service);
      fake.emit([
        buildPurchase(
          productId: kMonthlySubId,
          status: PurchaseStatus.error,
          error: IAPError(source: 'test', code: 'x', message: 'てすとえらー'),
        ),
      ]);
      await errored;
      expect(service.purchaseError, isNotNull);

      final canceled = _waitForNotify(service);
      fake.emit([
        buildPurchase(productId: kMonthlySubId, status: PurchaseStatus.canceled),
      ]);
      await canceled;

      expect(service.purchaseError, isNull);
    });

    test('restorePurchases: 対象商品が復元されればプレミアムになる', () async {
      final service = SubscriptionService();
      await _settle();

      final restoreFuture = service.restorePurchases();
      fake.emit([
        buildPurchase(productId: kYearlySubId, status: PurchaseStatus.restored),
      ]);
      await restoreFuture;

      expect(service.isPremium, isTrue);
    });

    test('restorePurchases: 何も見つからなければ、既にプレミアムでも false に戻る', () async {
      final service = SubscriptionService();
      await _settle();

      // 事前にプレミアム状態にしておく
      final notified = _waitForNotify(service);
      fake.emit([
        buildPurchase(productId: kMonthlySubId, status: PurchaseStatus.purchased),
      ]);
      await notified;
      expect(service.isPremium, isTrue);

      await service.restorePurchases(); // 何もemitしない

      expect(service.isPremium, isFalse);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('is_premium'), isFalse);
    });

    test('restorePurchases: 例外が発生してもプレミアム状態は変わらない', () async {
      final service = SubscriptionService();
      await _settle();

      final notified = _waitForNotify(service);
      fake.emit([
        buildPurchase(productId: kMonthlySubId, status: PurchaseStatus.purchased),
      ]);
      await notified;
      expect(service.isPremium, isTrue);

      fake.restorePurchasesError = Exception('network error');
      await service.restorePurchases();

      expect(service.isPremium, isTrue);
      expect(service.purchaseError, 'こうにゅうのふっげんにしっぱいしました');
    });

    test('debugSetPremium でプレミアム状態を手動切り替えできる', () async {
      final service = SubscriptionService();
      await _settle();

      await service.debugSetPremium(true);
      expect(service.isPremium, isTrue);
      var prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('is_premium'), isTrue);

      await service.debugSetPremium(false);
      expect(service.isPremium, isFalse);
      prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('is_premium'), isFalse);
    });

    test('起動時にキャッシュされたプレミアム状態をストア応答前に反映する', () async {
      SharedPreferences.setMockInitialValues({'is_premium': true});
      final service = SubscriptionService();

      // ストア応答を待たず、キャッシュ読み込み直後の通知だけを待つ
      await _waitForNotify(service);

      expect(service.isPremium, isTrue);
    });
  });
}
