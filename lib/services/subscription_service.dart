import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

// App Store Connect / Google Play Console に登録するプロダクトID
const String kMonthlySubId = 'clock_learning_premium_monthly';
const String kYearlySubId = 'clock_learning_premium_yearly';

/// サブスクリプション管理サービス
/// App Store (iOS) / Google Play (Android) のサブスクリプションを管理する
class SubscriptionService extends ChangeNotifier {
  static const Set<String> _productIds = {kMonthlySubId, kYearlySubId};
  static const String _premiumKey = 'is_premium';

  bool _isPremium = false;
  bool _isLoading = true;
  bool _storeAvailable = false;
  List<ProductDetails> _products = [];
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  String? _purchaseError;

  /// ユーザー操作による復元中に、対象商品の購入が1件でも流れてきたか
  bool _sawEntitlementDuringRestore = false;

  /// [restorePurchases] が purchaseStream の到着を待つ猶予時間。
  /// テストから `Duration.zero` に差し替えられるよう注入可能にしている
  /// （本番のデフォルト値は変わらない）。
  @visibleForTesting
  static Duration restoreGraceDelay = const Duration(seconds: 2);

  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;
  bool get storeAvailable => _storeAvailable;
  List<ProductDetails> get products => _products;
  String? get purchaseError => _purchaseError;

  ProductDetails? get monthlyProduct =>
      _products.where((p) => p.id == kMonthlySubId).firstOrNull;
  ProductDetails? get yearlyProduct =>
      _products.where((p) => p.id == kYearlySubId).firstOrNull;

  SubscriptionService() {
    _initialize();
  }

  Future<void> _initialize() async {
    // キャッシュされたプレミアム状態を先に読み込む（UI ブロックを防ぐ）
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_premiumKey) ?? false;
    notifyListeners();

    final isAvailable = await InAppPurchase.instance.isAvailable();
    _storeAvailable = isAvailable;

    if (!isAvailable) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    // 購入ストリームを監視
    _purchaseSubscription = InAppPurchase.instance.purchaseStream.listen(
      _handlePurchaseUpdate,
      onError: (dynamic error) {
        debugPrint('Purchase stream error: $error');
      },
    );

    await _loadProducts();

    // 以前の購入を復元（Appleの要件：アプリ起動時に復元を試みる）
    await InAppPurchase.instance.restorePurchases();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadProducts() async {
    final response =
        await InAppPurchase.instance.queryProductDetails(_productIds);
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Store products not found: ${response.notFoundIDs}');
    }
    _products = response.productDetails;
    notifyListeners();
  }

  Future<void> _handlePurchaseUpdate(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final purchase in purchaseDetailsList) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          if (_productIds.contains(purchase.productID)) {
            _sawEntitlementDuringRestore = true;
            await _setPremium(true);
          }
          // in_app_purchase 3.x では pendingCompletionData が廃止されたため
          // purchased / restored 時は常に completePurchase を呼ぶ
          await InAppPurchase.instance.completePurchase(purchase);
          _purchaseError = null;
          break;
        case PurchaseStatus.error:
          _purchaseError = purchase.error?.message ?? 'こうにゅうにしっぱいしました';
          notifyListeners();
          break;
        case PurchaseStatus.canceled:
          _purchaseError = null;
          notifyListeners();
          break;
        case PurchaseStatus.pending:
          break;
      }
    }
  }

  /// サブスクリプションを購入する
  Future<bool> purchaseSubscription(ProductDetails product) async {
    _purchaseError = null;
    notifyListeners();
    try {
      final param = PurchaseParam(productDetails: product);
      return await InAppPurchase.instance.buyNonConsumable(
        purchaseParam: param,
      );
    } catch (e) {
      _purchaseError = 'こうにゅうにしっぱいしました';
      notifyListeners();
      return false;
    }
  }

  /// 以前の購入を復元する（Apple審査要件: Restore Purchases ボタン必須）
  ///
  /// 復元の結果、対象商品の購入が1件も見つからなかった場合は
  /// キャッシュしている `is_premium` を false に戻す。
  /// 別の Apple ID / Google アカウントに切り替えた場合や、
  /// 端末側のキャッシュだけが残っている場合に権利が残り続けるのを防ぐ。
  ///
  /// 注意: StoreKit 1 の復元は失効済みトランザクションも返し得るため、
  /// これだけでは「解約・期限切れ」を確実に検知できない。
  /// 正確な有効期限の判定にはサーバー側でのレシート検証が必要。
  Future<void> restorePurchases() async {
    _purchaseError = null;
    _sawEntitlementDuringRestore = false;
    try {
      await InAppPurchase.instance.restorePurchases();

      // 復元されたトランザクションは purchaseStream に非同期で届くため待機する
      await Future.delayed(restoreGraceDelay);

      if (!_sawEntitlementDuringRestore && _isPremium) {
        await _setPremium(false);
      }
    } catch (e) {
      // 通信エラー等では権利を取り消さない（誤って有料ユーザーを締め出さないため）
      _purchaseError = 'こうにゅうのふっげんにしっぱいしました';
      notifyListeners();
    }
  }

  Future<void> _setPremium(bool value) async {
    _isPremium = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, value);
    notifyListeners();
  }

  /// デバッグ用：プレミアム状態を手動設定
  Future<void> debugSetPremium(bool value) async {
    if (kDebugMode) {
      await _setPremium(value);
    }
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }
}
