import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:clock_learning/services/subscription_service.dart';

/// [InAppPurchase] の差し替え用フェイク。
///
/// `InAppPurchasePlatform.instance` を差し替える方式は使えない。
/// `InAppPurchase.instance` は最初に参照した時点で実行プラットフォームの実装を登録し、
/// `flutter test` の `defaultTargetPlatform` は android のため、差し込んだモックが
/// 上書きされてしまう。そのため `SubscriptionService` へコンストラクタ注入している。
class _FakeIap implements InAppPurchase {
  final StreamController<List<PurchaseDetails>> _controller =
      StreamController<List<PurchaseDetails>>.broadcast();

  bool available = true;
  ProductDetailsResponse productResponse = ProductDetailsResponse(
    productDetails: [_monthly, _yearly],
    notFoundIDs: const [],
  );

  /// `restorePurchases()` が呼ばれたときにストリームへ流す購入（復元結果の再現）。
  List<PurchaseDetails> restoredOnRestore = [];

  /// `true` にすると `restorePurchases()` が通信エラーで失敗する。
  bool restoreThrows = false;

  /// `buyNonConsumable()` が返す値。`buyThrows` が `true` なら例外を投げる。
  bool buyResult = true;
  bool buyThrows = false;

  int restoreCalls = 0;
  final List<String> boughtProductIds = [];
  final List<PurchaseDetails> completed = [];

  /// ストアから購入イベントが届いたことを再現する。
  void emit(List<PurchaseDetails> purchases) => _controller.add(purchases);

  void emitError(Object error) => _controller.addError(error);

  Future<void> close() => _controller.close();

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _controller.stream;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<ProductDetailsResponse> queryProductDetails(
    Set<String> identifiers,
  ) async =>
      productResponse;

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async {
    if (buyThrows) throw Exception('buy failed');
    boughtProductIds.add(purchaseParam.productDetails.id);
    return buyResult;
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {
    completed.add(purchase);
  }

  @override
  Future<void> restorePurchases({String? applicationUserName}) async {
    restoreCalls++;
    if (restoreThrows) throw Exception('network down');
    if (restoredOnRestore.isNotEmpty) emit(restoredOnRestore);
  }

  // 使わないメンバー（buyConsumable / countryCode / getPlatformAddition）は未実装でよい
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final ProductDetails _monthly = ProductDetails(
  id: kMonthlySubId,
  title: 'プレミアム月額',
  description: '月額',
  price: '¥480',
  rawPrice: 480,
  currencyCode: 'JPY',
  currencySymbol: '¥',
);

final ProductDetails _yearly = ProductDetails(
  id: kYearlySubId,
  title: 'プレミアム年額',
  description: '年額',
  price: '¥4,800',
  rawPrice: 4800,
  currencyCode: 'JPY',
  currencySymbol: '¥',
);

PurchaseDetails _purchase(String productId, PurchaseStatus status,
    {IAPError? error}) {
  final p = PurchaseDetails(
    purchaseID: 'id-$productId',
    productID: productId,
    verificationData: PurchaseVerificationData(
      localVerificationData: 'local',
      serverVerificationData: 'server',
      source: 'test',
    ),
    transactionDate: '0',
    status: status,
  );
  p.pendingCompletePurchase = true;
  if (error != null) p.error = error;
  return p;
}

/// `purchaseStream` 経由の非同期処理（プレミアム保存・completePurchase など）が
/// 落ち着くまでイベントループを回す。
Future<void> _flush() async {
  for (var i = 0; i < 20; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

/// 起動時の初期化（`isLoading` が false になる）の完了を待つ。
Future<void> _waitUntilLoaded(SubscriptionService service) async {
  if (!service.isLoading) return;
  final done = Completer<void>();
  void check() {
    if (!service.isLoading && !done.isCompleted) done.complete();
  }

  service.addListener(check);
  try {
    await done.future.timeout(const Duration(seconds: 5));
  } finally {
    service.removeListener(check);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeIap iap;
  late SubscriptionService service;

  /// [cachedPremium] は端末に保存済みの `is_premium` の初期値。
  Future<void> createService({bool? cachedPremium}) async {
    SharedPreferences.setMockInitialValues({
      if (cachedPremium != null) 'is_premium': cachedPremium,
    });
    service = SubscriptionService(
      inAppPurchase: iap,
      restoreSettleDelay: Duration.zero,
    );
    await _waitUntilLoaded(service);
  }

  Future<bool?> storedPremium() async =>
      (await SharedPreferences.getInstance()).getBool('is_premium');

  setUp(() {
    iap = _FakeIap();
  });

  tearDown(() async {
    service.dispose();
    await iap.close();
  });

  group('起動時の初期化', () {
    test('ストアが利用できない場合は storeAvailable=false で読み込みを終える', () async {
      iap.available = false;
      await createService();

      expect(service.storeAvailable, isFalse);
      expect(service.isLoading, isFalse);
      expect(service.products, isEmpty);
    });

    test('月額・年額の両方の商品を取得できる', () async {
      await createService();

      expect(service.storeAvailable, isTrue);
      expect(service.monthlyProduct?.id, kMonthlySubId);
      expect(service.yearlyProduct?.id, kYearlySubId);
    });

    test('商品が一部見つからなくてもクラッシュせず、取得できた分だけ使える', () async {
      // App Store Connect の Product ID 登録ミスを再現（notFoundIDs に入る）
      iap.productResponse = ProductDetailsResponse(
        productDetails: [_monthly],
        notFoundIDs: const [kYearlySubId],
      );
      await createService();

      expect(service.isLoading, isFalse);
      expect(service.monthlyProduct, isNotNull);
      expect(service.yearlyProduct, isNull);
    });

    test('端末に保存済みのプレミアム状態を読み込む', () async {
      await createService(cachedPremium: true);

      expect(service.isPremium, isTrue);
    });

    test('起動時の自動復元では、結果が空でも保存済みの権利を取り消さない', () async {
      // オフライン起動などで復元結果が空でも、有料ユーザーを締め出さない
      await createService(cachedPremium: true);

      expect(iap.restoreCalls, 1, reason: '起動時に復元を試みる（Apple の要件）');
      expect(service.isPremium, isTrue);
      expect(await storedPremium(), isTrue);
    });
  });

  group('購入', () {
    test('購入成功でプレミアムが解放され、保存され、completePurchase が呼ばれる', () async {
      await createService();
      final purchase = _purchase(kMonthlySubId, PurchaseStatus.purchased);

      iap.emit([purchase]);
      await _flush();

      expect(service.isPremium, isTrue);
      expect(await storedPremium(), isTrue);
      expect(iap.completed, [purchase]);
      expect(service.purchaseError, isNull);
    });

    test('年額プランの購入でも解放される', () async {
      await createService();

      iap.emit([_purchase(kYearlySubId, PurchaseStatus.purchased)]);
      await _flush();

      expect(service.isPremium, isTrue);
    });

    test('対象外の商品IDでは解放しない（ただし completePurchase は呼ぶ）', () async {
      await createService();
      final other = _purchase('some_other_product', PurchaseStatus.purchased);

      iap.emit([other]);
      await _flush();

      expect(service.isPremium, isFalse);
      expect(iap.completed, [other], reason: '未完了のまま残すとストアに再送され続ける');
    });

    test('購入キャンセルではエラーを出さず、プレミアム状態も変えない', () async {
      await createService();

      iap.emit([_purchase(kMonthlySubId, PurchaseStatus.canceled)]);
      await _flush();

      expect(service.purchaseError, isNull);
      expect(service.isPremium, isFalse);
      expect(iap.completed, isEmpty);
    });

    test('キャンセルは直前のエラー表示を消す', () async {
      await createService();

      iap.emit([_purchase(kMonthlySubId, PurchaseStatus.error)]);
      await _flush();
      expect(service.purchaseError, isNotNull);

      iap.emit([_purchase(kMonthlySubId, PurchaseStatus.canceled)]);
      await _flush();
      expect(service.purchaseError, isNull);
    });

    test('購入エラーでストアのメッセージを表示し、プレミアムにはならない', () async {
      await createService();

      iap.emit([
        _purchase(
          kMonthlySubId,
          PurchaseStatus.error,
          error: IAPError(source: 'test', code: 'x', message: 'カード情報が無効です'),
        ),
      ]);
      await _flush();

      expect(service.purchaseError, 'カード情報が無効です');
      expect(service.isPremium, isFalse);
    });

    test('購入エラーにメッセージが無い場合は既定の文言を出す', () async {
      await createService();

      iap.emit([_purchase(kMonthlySubId, PurchaseStatus.error)]);
      await _flush();

      expect(service.purchaseError, 'こうにゅうにしっぱいしました');
    });

    test('購入待機中(pending)では何も変えない', () async {
      await createService();

      iap.emit([_purchase(kMonthlySubId, PurchaseStatus.pending)]);
      await _flush();

      expect(service.isPremium, isFalse);
      expect(service.purchaseError, isNull);
      expect(iap.completed, isEmpty);
    });

    test('購入ストリームがエラーを流してもクラッシュしない', () async {
      await createService();

      iap.emitError(Exception('stream error'));
      await _flush();

      // その後も購入イベントを処理できる
      iap.emit([_purchase(kMonthlySubId, PurchaseStatus.purchased)]);
      await _flush();
      expect(service.isPremium, isTrue);
    });

    test('purchaseSubscription は選んだ商品を購入リクエストする', () async {
      await createService();

      final ok = await service.purchaseSubscription(_yearly);

      expect(ok, isTrue);
      expect(iap.boughtProductIds, [kYearlySubId]);
    });

    test('purchaseSubscription が例外になったら false とエラー表示を返す', () async {
      await createService();
      iap.buyThrows = true;

      final ok = await service.purchaseSubscription(_monthly);

      expect(ok, isFalse);
      expect(service.purchaseError, 'こうにゅうにしっぱいしました');
    });
  });

  group('復元（restorePurchases）', () {
    test('対象商品が復元されたらプレミアムになる', () async {
      await createService();
      iap.restoredOnRestore = [
        _purchase(kYearlySubId, PurchaseStatus.restored),
      ];

      await service.restorePurchases();
      await _flush();

      expect(service.isPremium, isTrue);
      expect(await storedPremium(), isTrue);
    });

    test('対象商品が1件も復元されなければプレミアムを解除する（別アカウントでの復元など）', () async {
      // 端末のキャッシュだけが有料のまま残っている状態
      await createService(cachedPremium: true);
      expect(service.isPremium, isTrue);

      await service.restorePurchases();
      await _flush();

      expect(service.isPremium, isFalse);
      expect(await storedPremium(), isFalse);
    });

    test('対象外の商品しか復元されなければ、やはり解除する', () async {
      await createService(cachedPremium: true);
      iap.restoredOnRestore = [
        _purchase('some_other_product', PurchaseStatus.restored),
      ];

      await service.restorePurchases();
      await _flush();

      expect(service.isPremium, isFalse);
    });

    test('未購入のまま復元しても、プレミアムにならず・エラーも出ない', () async {
      await createService();

      await service.restorePurchases();
      await _flush();

      expect(service.isPremium, isFalse);
      expect(service.purchaseError, isNull);
    });

    test('通信エラーで復元に失敗しても権利は取り消さない', () async {
      await createService(cachedPremium: true);
      // 起動時の自動復元は成功させ、ユーザー操作の復元だけ失敗させる
      iap.restoreThrows = true;

      await service.restorePurchases();
      await _flush();

      expect(service.isPremium, isTrue, reason: '有料ユーザーを誤って締め出さない');
      expect(await storedPremium(), isTrue);
      expect(service.purchaseError, 'こうにゅうのふくげんにしっぱいしました');
    });

    test('復元を始めるときに前回のエラー表示を消す', () async {
      await createService();
      iap.emit([_purchase(kMonthlySubId, PurchaseStatus.error)]);
      await _flush();
      expect(service.purchaseError, isNotNull);

      await service.restorePurchases();

      expect(service.purchaseError, isNull);
    });
  });
}
