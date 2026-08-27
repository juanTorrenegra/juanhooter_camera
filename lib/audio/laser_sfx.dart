import 'dart:async';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:juanshooter/audio/laser_synth.dart';

export 'package:juanshooter/audio/laser_synth.dart' show LaserShotTier;

/// Plays procedurally generated laser WAVs through [audioplayers].
/// Same path on Android and web (WAV bytes, no extra plugins).
class LaserSfx {
  late final Uint8List _chargeWav;
  late final Uint8List _sustainWav;
  late final Uint8List _regularWav;
  late final Uint8List _mediumWav;
  late final Uint8List _bigWav;

  AudioPlayer? _chargePlayer;
  AudioPlayer? _sustainPlayer;
  AudioPlayer? _shotPlayer;
  int _gen = 0;
  bool _sustainLooping = false;
  bool _generated = false;

  void generate() {
    if (_generated) return;
    _chargeWav = LaserSynth.chargeSweep();
    _sustainWav = LaserSynth.chargeSustainLoop();
    _regularWav = LaserSynth.shot(LaserShotTier.regular);
    _mediumWav = LaserSynth.shot(LaserShotTier.medium);
    _bigWav = LaserSynth.shot(LaserShotTier.big);
    _generated = true;
  }

  void startCharge() {
    generate();
    _sustainLooping = false;
    unawaited(_playCharge());
  }

  void startSustainIfNeeded() {
    if (_sustainLooping) return;
    unawaited(_playSustain());
  }

  Future<void> stopCharge() async {
    _gen++;
    _sustainLooping = false;
    await _chargePlayer?.stop();
    await _sustainPlayer?.stop();
  }

  Future<void> playShot(LaserShotTier tier) async {
    generate();
    await stopCharge();
    _shotPlayer ??= await _makePlayer();
    final wav = switch (tier) {
      LaserShotTier.regular => _regularWav,
      LaserShotTier.medium => _mediumWav,
      LaserShotTier.big => _bigWav,
    };
    try {
      await _shotPlayer!.stop();
      await _shotPlayer!.setReleaseMode(ReleaseMode.stop);
      await _shotPlayer!.play(_wavSource(wav));
    } catch (_) {}
  }

  Future<void> dispose() async {
    _gen++;
    await _chargePlayer?.dispose();
    await _sustainPlayer?.dispose();
    await _shotPlayer?.dispose();
    _chargePlayer = null;
    _sustainPlayer = null;
    _shotPlayer = null;
  }

  Future<void> _playCharge() async {
    final gen = ++_gen;
    _chargePlayer ??= await _makePlayer();
    if (gen != _gen) return;
    try {
      await _chargePlayer!.stop();
      await _sustainPlayer?.stop();
      if (gen != _gen) return;
      await _chargePlayer!.setReleaseMode(ReleaseMode.stop);
      await _chargePlayer!.play(_wavSource(_chargeWav));
    } catch (_) {}
  }

  Future<void> _playSustain() async {
    if (_sustainLooping) return;
    _sustainLooping = true;
    final gen = _gen;
    _sustainPlayer ??= await _makePlayer();
    if (gen != _gen) {
      _sustainLooping = false;
      return;
    }
    try {
      await _chargePlayer?.stop();
      if (gen != _gen) return;
      await _sustainPlayer!.setReleaseMode(ReleaseMode.loop);
      await _sustainPlayer!.play(_wavSource(_sustainWav));
    } catch (_) {
      _sustainLooping = false;
    }
  }

  BytesSource _wavSource(Uint8List wav) =>
      BytesSource(wav, mimeType: 'audio/wav');

  Future<AudioPlayer> _makePlayer() async {
    final player = AudioPlayer()..audioCache = FlameAudio.audioCache;
    await player.setAudioContext(
      AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers).build(),
    );
    return player;
  }
}
