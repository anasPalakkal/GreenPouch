import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Enum ─────────────────────────────────────────────────────────────────────

enum TransactionSound {
  income,
  expense,
  transfer,
  goalDeposit,
  goalWithdraw,
  reverse,
}

// ─── SoundService ─────────────────────────────────────────────────────────────

class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  static const _prefKey = 'sound_enabled';

  bool _soundEnabled = false;
  final AudioPlayer _player = AudioPlayer();

  // Asset path for each transaction type
  static const _soundAssets = {
    TransactionSound.income:       'sounds/income.mp3',
    TransactionSound.expense:      'sounds/expense.mp3',
    TransactionSound.transfer:     'sounds/transfer.mp3',
    TransactionSound.goalDeposit:  'sounds/goal_deposit.mp3',
    TransactionSound.goalWithdraw: 'sounds/goal_withdraw.mp3',
    TransactionSound.reverse:      'sounds/reverse.mp3',
  };

  // Volume per transaction type (0.0 = mute, 1.0 = full)
  static const _soundVolumes = {
    TransactionSound.income:       0.1,
    TransactionSound.expense:      0.25,
    TransactionSound.transfer:     0.1,
    TransactionSound.goalDeposit:  0.2,
    TransactionSound.goalWithdraw: 0.1,
    TransactionSound.reverse:      0.25,
  };

  // ─── Init ──────────────────────────────────────────────────────────────────

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool(_prefKey) ?? false;
    await _player.setPlayerMode(PlayerMode.lowLatency);
  }

  // ─── Public API ────────────────────────────────────────────────────────────

  Future<void> playTransaction(TransactionSound type) async {
    if (!_soundEnabled) return;
    Future.wait([
      _playSound(type),
      _vibrate(type),
    ]).ignore();
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, enabled);
  }

  bool get soundEnabled => _soundEnabled;

  Future<void> dispose() async {
    await _player.dispose();
  }

  // ─── Private ───────────────────────────────────────────────────────────────

  Future<void> _playSound(TransactionSound type) async {
    try {
      final asset = _soundAssets[type];
      if (asset == null) return;

      final volume = _soundVolumes[type] ?? 0.3;

      await _player.stop();
      await _player.setVolume(volume); // 🔊 low volume
      await _player.play(AssetSource(asset));
    } catch (_) {
      // Fail silently — sound is non-critical
    }
  }

  Future<void> _vibrate(TransactionSound type) async {
    try {
      switch (type) {
        case TransactionSound.income:
          HapticFeedback.lightImpact();
          break;
        case TransactionSound.expense:
          HapticFeedback.mediumImpact();
          break;
        case TransactionSound.transfer:
          HapticFeedback.selectionClick();
          break;
        default:
          HapticFeedback.lightImpact();
      }
    } catch (_) {}
  }
}