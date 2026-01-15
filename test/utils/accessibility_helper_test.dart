import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:clock_learning/utils/accessibility_helper.dart';

void main() {
  group('AccessibilityHelper', () {
    group('コントラスト比の計算', () {
      test('白と黒のコントラスト比は21:1', () {
        final ratio = AccessibilityHelper.calculateContrastRatio(
          Colors.white,
          Colors.black,
        );
        expect(ratio, closeTo(21.0, 0.1));
      });

      test('緑と白のコントラスト比を計算できる', () {
        final ratio = AccessibilityHelper.calculateContrastRatio(
          Colors.green,
          Colors.white,
        );
        // 標準の緑は白背景に対してWCAG AA準拠を満たさない場合がある
        // これは実際の値として記録する
        expect(ratio, greaterThan(0));
        expect(ratio, lessThan(10));
      });

      test('赤と白のコントラスト比を計算できる', () {
        final ratio = AccessibilityHelper.calculateContrastRatio(
          Colors.red,
          Colors.white,
        );
        expect(ratio, greaterThan(0));
        expect(ratio, lessThan(10));
      });

      test('青と白のコントラスト比を計算できる', () {
        final ratio = AccessibilityHelper.calculateContrastRatio(
          Colors.blue,
          Colors.white,
        );
        expect(ratio, greaterThan(0));
        expect(ratio, lessThan(10));
      });
    });

    group('WCAG準拠チェック', () {
      test('白と黒はWCAG AA準拠', () {
        expect(
          AccessibilityHelper.isWCAGAACompliant(Colors.white, Colors.black),
          isTrue,
        );
      });

      test('白と黒はWCAG AAA準拠', () {
        expect(
          AccessibilityHelper.isWCAGAAACompliant(Colors.white, Colors.black),
          isTrue,
        );
      });

      test('濃い緑と白はWCAG AA準拠', () {
        // より濃い緑を使用（WCAG AA準拠を満たす）
        final darkGreen = const Color(0xFF1B5E20); // 濃い緑
        expect(
          AccessibilityHelper.isWCAGAACompliant(darkGreen, Colors.white),
          isTrue,
        );
      });

      test('濃い赤と白はWCAG AA準拠', () {
        // より濃い赤を使用（WCAG AA準拠を満たす）
        final darkRed = const Color(0xFFB71C1C); // 濃い赤
        expect(
          AccessibilityHelper.isWCAGAACompliant(darkRed, Colors.white),
          isTrue,
        );
      });

      test('濃い青と白はWCAG AA準拠', () {
        // より濃い青を使用（WCAG AA準拠を満たす）
        final darkBlue = const Color(0xFF0D47A1); // 濃い青
        expect(
          AccessibilityHelper.isWCAGAACompliant(darkBlue, Colors.white),
          isTrue,
        );
      });
    });
  });
}
