import 'package:flutter/material.dart';

/// シールの種類と見た目定義
class StickerDef {
  final String emoji;
  final Color bgColor;
  final String name;

  const StickerDef({
    required this.emoji,
    required this.bgColor,
    required this.name,
  });
}

const List<StickerDef> kStickerTypes = [
  StickerDef(emoji: '⭐', bgColor: Color(0xFFFFC107), name: 'ほし'),
  StickerDef(emoji: '🌙', bgColor: Color(0xFF7986CB), name: 'つき'),
  StickerDef(emoji: '☀️', bgColor: Color(0xFFFF7043), name: 'たいよう'),
  StickerDef(emoji: '🌈', bgColor: Color(0xFF29B6F6), name: 'にじ'),
  StickerDef(emoji: '🌸', bgColor: Color(0xFFF06292), name: 'はな'),
  StickerDef(emoji: '🎉', bgColor: Color(0xFFAB47BC), name: 'きねん'),
  StickerDef(emoji: '🚀', bgColor: Color(0xFF7C4DFF), name: 'ロケット'),
  StickerDef(emoji: '🏆', bgColor: Color(0xFFFFB300), name: 'とろふぃ'),
  StickerDef(emoji: '💎', bgColor: Color(0xFF26C6DA), name: 'たから'),
  StickerDef(emoji: '⏰', bgColor: Color(0xFF26A69A), name: 'とけい'),
  StickerDef(emoji: '👑', bgColor: Color(0xFFEF6C00), name: 'おうかん'),
  StickerDef(emoji: '✨', bgColor: Color(0xFF9575CD), name: 'きらきら'),
  StickerDef(emoji: '🐱', bgColor: Color(0xFFFF8A65), name: 'ねこ'),
  StickerDef(emoji: '🐰', bgColor: Color(0xFFEC407A), name: 'うさぎ'),
  StickerDef(emoji: '🍭', bgColor: Color(0xFF66BB6A), name: 'あめ'),
];

/// シール枚数に応じたはげましメッセージ
String stickerEncouragementMessage(int count) {
  if (count == 0) return 'もんだいをといてシールをあつめよう！';
  if (count < 5) return 'あつめはじめたね！このちょうしで！';
  if (count < 10) return 'シールがふえてきたよ！すごいね！';
  if (count < 20) return 'たくさんあつまってきた！やるね！';
  if (count < 30) return 'もうすぐ30まい！がんばれ！';
  if (count < 50) return 'シールだいすき！めざせ50まい！';
  return 'シールのたつじん！きみはすごい！🎉';
}
