import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

/// テスト用の [InAppPurchasePlatform] フェイク。
///
/// [InAppPurchase.instance] は初回アクセス時に実プラットフォーム
/// （テスト実行時は Android 扱いになる）を自己登録してしまうため、
/// 単純に [InAppPurchasePlatform.instance] を差し替えるだけでは
/// タイミング次第で上書きされる。必ず [installFakeInAppPurchasePlatform]
/// 経由でインストールすること。
class FakeInAppPurchasePlatform extends InAppPurchasePlatform {
  bool isAvailableValue = true;

  /// isAvailable() の解決を止めておきたいときに使う（テストで完了させる）
  Completer<void>? isAvailableGate;

  List<ProductDetails> productsToReturn = [];
  List<String> notFoundIds = [];
  Object? queryProductDetailsError;

  bool buyNonConsumableResult = true;
  Object? buyNonConsumableError;

  Object? restorePurchasesError;

  int completePurchaseCallCount = 0;
  final List<PurchaseDetails> completedPurchases = [];
  int restorePurchasesCallCount = 0;
  PurchaseParam? lastBuyNonConsumableParam;

  final StreamController<List<PurchaseDetails>> _controller =
      StreamController<List<PurchaseDetails>>.broadcast();

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _controller.stream;

  /// 実際の購入ストリームイベントを模擬する。
  /// 何も呼ばなければ「復元しても対象の購入が見つからない」状態になる。
  void emit(List<PurchaseDetails> events) => _controller.add(events);

  @override
  Future<bool> isAvailable() async {
    if (isAvailableGate != null) {
      await isAvailableGate!.future;
    }
    return isAvailableValue;
  }

  @override
  Future<ProductDetailsResponse> queryProductDetails(
    Set<String> identifiers,
  ) async {
    if (queryProductDetailsError != null) throw queryProductDetailsError!;
    return ProductDetailsResponse(
      productDetails: productsToReturn,
      notFoundIDs: notFoundIds,
    );
  }

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async {
    lastBuyNonConsumableParam = purchaseParam;
    if (buyNonConsumableError != null) throw buyNonConsumableError!;
    return buyNonConsumableResult;
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {
    completePurchaseCallCount++;
    completedPurchases.add(purchase);
  }

  @override
  Future<void> restorePurchases({String? applicationUserName}) async {
    restorePurchasesCallCount++;
    if (restorePurchasesError != null) throw restorePurchasesError!;
    // 実際の実装同様、復元されたトランザクションはこのメソッドの戻り値ではなく
    // purchaseStream に非同期で届く。テスト側で emit() を呼んで模擬する。
  }

  Future<void> dispose() => _controller.close();
}

bool _consumedRealPlatformRegistration = false;

/// [InAppPurchase.instance] への最初のアクセスで実プラットフォーム
/// （テスト実行時は Android 扱い）が自己登録され、その `BillingClientManager`
/// が即座にコネクション確立を試みる。テスト環境には応答するプラットフォームが
/// 存在しないため、この接続試行は失敗し、しかも `onBillingServiceDisconnected`
/// が自動再接続を仕掛けるため、放置すると**プロセスが生きている限り
/// 無限に再接続を試み続ける**（成功したテストの後続の testWidgets で
/// pumpAndSettle() が数十秒〜数分単位で不可解に固まる原因になる）。
///
/// 対策として、実プラットフォームが接続確立に使う Pigeon チャンネル
/// （dev.flutter.pigeon.in_app_purchase_android.InAppPurchaseApi.*）に、
/// 「呼ばれても永遠に応答しない」モックハンドラを登録しておく。
/// これにより `_connect()` の呼び出しは無害に停止したまま残り続けるだけになり、
/// 失敗による自動再接続ループが発生しなくなる。
const _pigeonPrefix = 'dev.flutter.pigeon.in_app_purchase_android.InAppPurchaseApi.';
const _pigeonMethods = [
  'isReady',
  'startConnection',
  'endConnection',
  'onDisconnect',
  'queryPurchasesAsync',
  'launchBillingFlow',
  'consumeAsync',
  'acknowledgePurchase',
  'isFeatureSupported',
  'getConnectionState',
  'queryProductDetailsAsync',
  'getBillingConfig',
];

void _neutralizeRealBillingChannels() {
  for (final method in _pigeonMethods) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('$_pigeonPrefix$method', (_) {
      // 呼ばれても解決しない Future を返し、恒久的に「接続試行中」のまま
      // 無害に止めておく。エラーにすると自動再接続ループが起動してしまう。
      return Completer<ByteData?>().future;
    });
  }
}

/// [fake] を [InAppPurchasePlatform.instance] にインストールする。
///
/// [InAppPurchase.instance] への最初のアクセスで実プラットフォームが
/// 自己登録され `InAppPurchasePlatform.instance` を上書きしてしまうため、
/// 先に実プラットフォームのチャンネルを無害化したうえで、その自己登録を
/// 消費してからフェイクを設定する。
void installFakeInAppPurchasePlatform(FakeInAppPurchasePlatform fake) {
  if (!_consumedRealPlatformRegistration) {
    _consumedRealPlatformRegistration = true;
    _neutralizeRealBillingChannels();
    runZonedGuarded(() {
      InAppPurchase.instance; // 自己登録を消費するためだけの参照
    }, (Object error, StackTrace stack) {
      // 想定内: 上記の無害化があっても、登録処理自体が別の理由で
      // 例外を投げる可能性に備えて念のため隔離しておく。
    });
  }
  InAppPurchasePlatform.instance = fake;
}

ProductDetails buildProduct({
  required String id,
  String title = 'title',
  String description = 'description',
  String price = '¥980',
  double rawPrice = 980,
  String currencyCode = 'JPY',
  String currencySymbol = '¥',
}) {
  return ProductDetails(
    id: id,
    title: title,
    description: description,
    price: price,
    rawPrice: rawPrice,
    currencyCode: currencyCode,
    currencySymbol: currencySymbol,
  );
}

PurchaseDetails buildPurchase({
  required String productId,
  required PurchaseStatus status,
  IAPError? error,
}) {
  return PurchaseDetails(
    productID: productId,
    verificationData: PurchaseVerificationData(
      localVerificationData: 'local',
      serverVerificationData: 'server',
      source: 'google_play',
    ),
    transactionDate: DateTime.now().millisecondsSinceEpoch.toString(),
    status: status,
  )..error = error;
}
