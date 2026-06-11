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
            await _setPremium(true);
          }
          if (purchase.pendingCompletionData != null) {
            await InAppPurchase.instance.completePurchase(purchase);
          }
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
  Future<void> restorePurchases() async {
    _purchaseError = null;
    try {
      await InAppPurchase.instance.restorePurchases();
    } catch (e) {
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
