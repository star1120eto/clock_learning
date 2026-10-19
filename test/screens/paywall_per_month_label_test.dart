import 'package:flutter_test/flutter_test.dart';
import 'package:clock_learning/screens/paywall_screen.dart';

void main() {
  group('perMonthLabelFor', () {
    test('日本円は小数を付けずに表示する', () {
      expect(
        perMonthLabelFor(
          rawPrice: 4800,
          currencySymbol: '¥',
          formattedPrice: '¥4,800',
        ),
        '1か月あたり ¥400 相当',
      );
    });

    test('米ドルは小数2桁で表示する（整数に丸めて安く見せない）', () {
      // 回帰テスト: 以前は .round() で "\$2" と表示され、
      // 実際の月額 \$2.99 に対して約20%安く見えていた。
      expect(
        perMonthLabelFor(
          rawPrice: 29.99,
          currencySymbol: '\$',
          formattedPrice: '\$29.99',
        ),
        '1か月あたり \$2.50 相当',
      );
    });

    test('小数点にカンマを使う表記でも小数2桁を維持する', () {
      expect(
        perMonthLabelFor(
          rawPrice: 29.99,
          currencySymbol: '€',
          formattedPrice: '29,99 €',
        ),
        '1か月あたり €2.50 相当',
      );
    });

    test('桁区切りと小数が混在する表記を正しく解釈する', () {
      // ドイツ語圏などの `1.234,56 €` 形式
      expect(
        perMonthLabelFor(
          rawPrice: 1234.56,
          currencySymbol: '€',
          formattedPrice: '1.234,56 €',
        ),
        '1か月あたり €102.88 相当',
      );
    });

    test('桁区切りのカンマを小数部と誤認しない', () {
      // "₩48,000" の ",000" は3桁なので小数部ではない
      expect(
        perMonthLabelFor(
          rawPrice: 48000,
          currencySymbol: '₩',
          formattedPrice: '₩48,000',
        ),
        '1か月あたり ₩4000 相当',
      );
    });

    test('価格が0以下のときは表示しない', () {
      expect(
        perMonthLabelFor(
          rawPrice: 0,
          currencySymbol: '¥',
          formattedPrice: '¥0',
        ),
        isNull,
      );
    });
  });
}
