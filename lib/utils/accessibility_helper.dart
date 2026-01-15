import 'dart:math';
import 'package:flutter/material.dart';

/// アクセシビリティ関連のヘルパー関数
class AccessibilityHelper {
  /// WCAG AA準拠のコントラスト比（4.5:1以上）を確認
  /// 
  /// [foreground] 前景色（テキストなど）
  /// [background] 背景色
  /// 
  /// 戻り値: コントラスト比（4.5以上でWCAG AA準拠）
  static double calculateContrastRatio(Color foreground, Color background) {
    final foregroundLuminance = _getRelativeLuminance(foreground);
    final backgroundLuminance = _getRelativeLuminance(background);
    
    final lighter = foregroundLuminance > backgroundLuminance 
        ? foregroundLuminance 
        : backgroundLuminance;
    final darker = foregroundLuminance > backgroundLuminance 
        ? backgroundLuminance 
        : foregroundLuminance;
    
    return (lighter + 0.05) / (darker + 0.05);
  }
  
  /// 相対輝度を計算（WCAG 2.1準拠）
  static double _getRelativeLuminance(Color color) {
    final r = _linearizeColorComponent((color.r * 255.0).round().clamp(0, 255) / 255.0);
    final g = _linearizeColorComponent((color.g * 255.0).round().clamp(0, 255) / 255.0);
    final b = _linearizeColorComponent((color.b * 255.0).round().clamp(0, 255) / 255.0);
    
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }
  
  /// 色成分を線形化
  static double _linearizeColorComponent(double component) {
    if (component <= 0.03928) {
      return component / 12.92;
    } else {
      return pow((component + 0.055) / 1.055, 2.4).toDouble();
    }
  }
  
  /// コントラスト比がWCAG AA準拠（4.5:1以上）か確認
  static bool isWCAGAACompliant(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= 4.5;
  }
  
  /// コントラスト比がWCAG AAA準拠（7:1以上）か確認
  static bool isWCAGAAACompliant(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= 7.0;
  }
}
