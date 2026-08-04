import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clock_learning/constants/legal_urls.dart';
import 'package:clock_learning/screens/paywall_screen.dart';
import 'package:clock_learning/services/subscription_service.dart';

import '../helpers/fake_in_app_purchase_platform.dart';

/// [PaywallScreen] を、pop 先が存在するホスト画面から push した状態で描画する。
///
/// `testWidgets` 内では `Future.delayed`（実タイマー）は明示的に pump しない限り
/// 解決しないため、[SubscriptionService] の非同期初期化を待つのも
/// `tester.pump()` / `pumpAndSettle()` を通じて行う（`_initialize()` 自体は
/// マイクロタスクのみで完結するため、pumpWidget 後の1回の settle で足りる）。
Future<void> _pumpPaywall(
  WidgetTester tester,
  SubscriptionService service,
) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<SubscriptionService>.value(
      value: service,
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaywallScreen()),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  // pumpAndSettle はページ遷移アニメーションを終端まで進める。
  // isAvailable() 等を Completer で止めている場合でも、それ自体は
  // フレームを再スケジュールし続けないため、pumpAndSettle は
  // 「止まったまま」の状態で正しく収束する。
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const prefsChannel = MethodChannel('plugins.flutter.io/shared_preferences');
  const urlLauncherChannel = MethodChannel('plugins.flutter.io/url_launcher');
  late FakeInAppPurchasePlatform fake;
  late List<Map<Object?, Object?>> canLaunchCalls;

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(prefsChannel, (MethodCall call) async {
      if (call.method == 'getAll') return <String, dynamic>{};
      return null;
    });
    canLaunchCalls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(urlLauncherChannel, (MethodCall call) async {
      if (call.method == 'canLaunch') {
        canLaunchCalls.add(call.arguments as Map<Object?, Object?>);
        return false; // launchUrl は呼ばれない
      }
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
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(urlLauncherChannel, null);
  });

  group('PaywallScreen', () {
    testWidgets('加入済みの場合は完了画面が表示され、価格カードは出ない', (tester) async {
      fake.productsToReturn = [
        buildProduct(id: kMonthlySubId),
        buildProduct(id: kYearlySubId),
      ];
      final service = SubscriptionService();
      await service.debugSetPremium(true);

      await _pumpPaywall(tester, service);

      expect(find.text('プレミアムプランに\nご加入済みです！'), findsOneWidget);
      expect(find.text('年額プラン'), findsNothing);
      expect(find.text('月額プラン'), findsNothing);

      await tester.tap(find.text('もどる'));
      await tester.pumpAndSettle();
      expect(find.text('open'), findsOneWidget);
    });

    testWidgets('ロード中はスピナーが表示される', (tester) async {
      final gate = Completer<void>();
      fake.isAvailableGate = gate;
      final service = SubscriptionService();

      // isAvailable() が gate で止まっている間は isLoading==true のまま。
      // CircularProgressIndicator は無限に回転するアニメーションを持つため
      // pumpAndSettle() は収束しない（既知の Flutter テストの落とし穴）。
      // ここでは _pumpPaywall は使わず、Navigator遷移が終わる分だけ
      // 個別に pump() する。
      await tester.pumpWidget(
        ChangeNotifierProvider<SubscriptionService>.value(
          value: service,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PaywallScreen()),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pump(); // ページ遷移を開始
      await tester.pump(const Duration(milliseconds: 300)); // 遷移アニメーション分

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('年額プラン'), findsNothing);

      gate.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('ストア利用不可の場合はメッセージが表示される', (tester) async {
      fake.isAvailableValue = false;
      final service = SubscriptionService();

      await _pumpPaywall(tester, service);

      expect(find.textContaining('ストアに接続できません'), findsOneWidget);
      expect(find.text('年額プラン'), findsNothing);
    });

    testWidgets('商品が2件そろっている場合は両方のプランが表示される', (tester) async {
      fake.productsToReturn = [
        buildProduct(
          id: kYearlySubId,
          price: '¥9,800',
          rawPrice: 9800,
          currencySymbol: '¥',
        ),
        buildProduct(id: kMonthlySubId, price: '¥980'),
      ];
      final service = SubscriptionService();

      await _pumpPaywall(tester, service);

      expect(find.text('年額プラン'), findsOneWidget);
      expect(find.text('月額プラン'), findsOneWidget);
      expect(find.text('おとく！'), findsOneWidget);
      expect(find.text('¥9,800'), findsOneWidget);
      expect(find.text('¥980'), findsOneWidget);
      // (9800 / 12).round() == 817
      expect(find.textContaining('1か月あたり ¥817 相当'), findsOneWidget);
    });

    testWidgets('年額商品のみの場合は年額カードだけ表示される', (tester) async {
      fake.productsToReturn = [buildProduct(id: kYearlySubId)];
      fake.notFoundIds = [kMonthlySubId];
      final service = SubscriptionService();

      await _pumpPaywall(tester, service);

      expect(find.text('年額プラン'), findsOneWidget);
      expect(find.text('月額プラン'), findsNothing);
    });

    testWidgets('rawPrice が0以下の場合は「1か月あたり」表記が出ない', (tester) async {
      fake.productsToReturn = [
        buildProduct(id: kYearlySubId, rawPrice: 0),
      ];
      fake.notFoundIds = [kMonthlySubId];
      final service = SubscriptionService();

      await _pumpPaywall(tester, service);

      expect(find.text('1年ごとに自動更新'), findsOneWidget);
      expect(find.textContaining('1か月あたり'), findsNothing);
    });

    testWidgets('購入完了イベントを受けると加入済み画面に切り替わる', (tester) async {
      // 実プラットフォームでは buyNonConsumable() の戻り値は
      // 「購入フローを開始できたか」を示すのみで、実際の購入確定は
      // 常にそれより後に purchaseStream 経由で非同期に届く。そのため
      // _onPurchaseTap 内の「service.purchaseSubscription() の直後に
      // isPremium を見て成功スナックバーを出す」分岐は、確定イベントが
      // 常にそれより遅れて届く実環境ではほぼ到達しない
      // （このテストで購入成功のスナックバー表示は検証しない）。
      // 一方、確定イベントで isPremium が true になれば Consumer が
      // 再描画され、加入済み画面に切り替わることは保証されている。
      fake.productsToReturn = [buildProduct(id: kMonthlySubId)];
      final service = SubscriptionService();

      await _pumpPaywall(tester, service);

      await tester.tap(find.text('月額プラン'));
      await tester.pump();
      fake.emit([
        buildPurchase(productId: kMonthlySubId, status: PurchaseStatus.purchased),
      ]);
      await tester.pumpAndSettle();

      expect(find.text('プレミアムプランに\nご加入済みです！'), findsOneWidget);
      // まだ PaywallScreen（の加入済み表示）上であり、pop はされていない
      expect(find.text('open'), findsNothing);
    });

    testWidgets('購入失敗でエラーメッセージが表示され画面は閉じない', (tester) async {
      fake.productsToReturn = [buildProduct(id: kMonthlySubId)];
      final service = SubscriptionService();

      await _pumpPaywall(tester, service);

      await tester.tap(find.text('月額プラン'));
      await tester.pump();
      fake.emit([
        buildPurchase(
          productId: kMonthlySubId,
          status: PurchaseStatus.error,
          error: IAPError(source: 'test', code: 'x', message: 'こうにゅうにしっぱいしました'),
        ),
      ]);
      await tester.pumpAndSettle();

      expect(find.text('こうにゅうにしっぱいしました'), findsWidgets);
      expect(find.text('open'), findsNothing); // まだ PaywallScreen 上
    });

    testWidgets('復元して見つかった場合は成功メッセージが表示され画面が閉じる', (tester) async {
      fake.productsToReturn = [buildProduct(id: kMonthlySubId)];
      final service = SubscriptionService();

      await _pumpPaywall(tester, service);
      await tester.ensureVisible(find.text('こうにゅうをふっげんする'));
      await tester.pump(); // スクロール位置をレイアウトに反映させる

      // restorePurchases() は猶予時間（テストでは0秒）待ってから判定するが、
      // マイクロタスクは常にタイマーより先に処理されるため、pump を挟まず
      // tap 直後に emit すれば、猶予時間のタイマーが発火する前に
      // ストリームからの復元イベントが確実に反映される。
      await tester.tap(find.text('こうにゅうをふっげんする'));
      fake.emit([
        buildPurchase(productId: kMonthlySubId, status: PurchaseStatus.restored),
      ]);
      await tester.pumpAndSettle();

      expect(find.text('プレミアムプランを復元しました！'), findsOneWidget);
      expect(find.text('open'), findsOneWidget);
    });

    testWidgets('復元して見つからない場合は案内メッセージのみで画面は閉じない', (tester) async {
      fake.productsToReturn = [buildProduct(id: kMonthlySubId)];
      final service = SubscriptionService();

      await _pumpPaywall(tester, service);
      await tester.ensureVisible(find.text('こうにゅうをふっげんする'));
      await tester.pump();

      await tester.tap(find.text('こうにゅうをふっげんする'));
      await tester.pumpAndSettle();

      expect(find.text('こうにゅうをかくにんしました'), findsOneWidget);
      expect(find.text('open'), findsNothing);
    });

    testWidgets('法的リンクをタップしても落ちず、正しいURLで起動を試みる', (tester) async {
      fake.productsToReturn = [buildProduct(id: kMonthlySubId)];
      final service = SubscriptionService();

      await _pumpPaywall(tester, service);

      await tester.ensureVisible(find.text('プライバシーポリシー'));
      await tester.pump();
      await tester.tap(find.text('プライバシーポリシー'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('りようきやく'));
      await tester.pump();
      await tester.tap(find.text('りようきやく'));
      await tester.pumpAndSettle();

      expect(canLaunchCalls.map((c) => c['url']), [
        kPrivacyPolicyUrl,
        kTermsOfServiceUrl,
      ]);
    });
  });
}
