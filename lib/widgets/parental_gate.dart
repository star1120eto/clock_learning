import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ペアレンタルゲート（保護者確認）
///
/// 子ども向けアプリで、課金導線や外部リンクなど「子どもが単独で実行すべきでない
/// 操作」の前に表示する確認ダイアログ。
///
/// 対象年齢（4〜8歳）が突破できないよう、以下の設計にしている:
/// - 説明文をすべて漢字表記にする（未就学〜低学年は読めない）
/// - 2桁 × 1桁の掛け算を、選択肢ではなく数値入力で回答させる
/// - 誤答は [_maxAttempts] 回までとし、超えたら閉じる
class ParentalGate {
  ParentalGate._();

  static const int _maxAttempts = 3;

  /// ペアレンタルゲートを表示し、突破できた場合のみ `true` を返す。
  ///
  /// キャンセル・誤答回数超過・ダイアログ外タップの場合は `false`。
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _ParentalGateDialog(),
    );
    return result ?? false;
  }

  /// ゲートを突破した場合のみ [action] を実行するヘルパー。
  ///
  /// 呼び出し側で `context.mounted` を確認する手間を省くため、
  /// [action] は突破後に `mounted` が真である場合のみ実行される。
  static Future<void> guard(
    BuildContext context,
    VoidCallback action,
  ) async {
    final passed = await show(context);
    if (!passed || !context.mounted) return;
    action();
  }
}

class _ParentalGateDialog extends StatefulWidget {
  const _ParentalGateDialog();

  @override
  State<_ParentalGateDialog> createState() => _ParentalGateDialogState();
}

class _ParentalGateDialogState extends State<_ParentalGateDialog> {
  final _controller = TextEditingController();
  final _random = Random();

  late int _left;
  late int _right;
  int _attempts = 0;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generateQuestion() {
    // 11〜29 × 3〜9（暗算では解きにくく、大人なら確実に解ける難易度）
    _left = 11 + _random.nextInt(19);
    _right = 3 + _random.nextInt(7);
    _controller.clear();
  }

  void _onSubmit() {
    final answer = int.tryParse(_controller.text.trim());
    if (answer == _left * _right) {
      Navigator.of(context).pop(true);
      return;
    }

    _attempts++;
    if (_attempts >= ParentalGate._maxAttempts) {
      Navigator.of(context).pop(false);
      return;
    }

    setState(() {
      _hasError = true;
      _generateQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    final remaining = ParentalGate._maxAttempts - _attempts;

    return AlertDialog(
      title: const Text(
        '保護者の方へ',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'この先は保護者の方向けの内容です。'
            'お子様による誤操作を防ぐため、下記の計算にお答えください。',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 20),
          Center(
            child: Semantics(
              label: '$_left かける $_right は？',
              child: ExcludeSemantics(
                child: Text(
                  '$_left × $_right = ?',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24),
            decoration: InputDecoration(
              hintText: '答えを入力',
              border: const OutlineInputBorder(),
              errorText: _hasError
                  ? '答えが違います（残り $remaining 回）'
                  : null,
            ),
            onSubmitted: (_) => _onSubmit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: _onSubmit,
          child: const Text('確認'),
        ),
      ],
    );
  }
}
