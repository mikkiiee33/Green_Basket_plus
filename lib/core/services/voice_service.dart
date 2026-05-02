// lib/core/services/voice_service.dart
// Voice input (STT) + Voice output (TTS) for GreenBasket+

import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

// ─────────────────────────────────────────────────────────────────────────────
// VOICE SERVICE
// ─────────────────────────────────────────────────────────────────────────────

class VoiceService {
  VoiceService._();
  static final VoiceService instance = VoiceService._();

  // ── STT ──────────────────────────────────────────────────────────────────
  final SpeechToText _stt = SpeechToText();
  bool _sttReady = false;
  bool _isListening = false;

  bool get isListening => _isListening;
  bool get sttReady    => _sttReady;

  /// Call once at app start (or lazily on first use).
  Future<bool> initSTT() async {
    if (_sttReady) return true;
    try {
      // Ask for mic permission on Android / iOS
      final status = await Permission.microphone.request();
      if (!status.isGranted) return false;

      _sttReady = await _stt.initialize(
        onError: (e) => debugPrint('[VoiceService] STT error: $e'),
        onStatus: (s) => debugPrint('[VoiceService] STT status: $s'),
      );
      return _sttReady;
    } catch (e) {
      debugPrint('[VoiceService] initSTT failed: $e');
      return false;
    }
  }

  /// Start listening. Calls [onResult] with interim + final transcripts.
  /// Calls [onDone] when listening stops (silence or [stop] called).
  Future<void> startListening({
    required void Function(String text, bool isFinal) onResult,
    required void Function() onDone,
    String localeId = 'en_IN',  // Indian English by default
  }) async {
    if (!_sttReady) {
      final ok = await initSTT();
      if (!ok) return;
    }
    if (_isListening) return;
    _isListening = true;

    await _stt.listen(
      localeId: localeId,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      // partialResults: true,
      listenOptions: SpeechListenOptions(partialResults: true),
      onResult: (result) {
        onResult(result.recognizedWords, result.finalResult);
        if (result.finalResult) {
          _isListening = false;
          onDone();
        }
      },
    );
  }

  Future<void> stopListening() async {
    if (!_isListening) return;
    await _stt.stop();
    _isListening = false;
  }

  Future<void> cancelListening() async {
    await _stt.cancel();
    _isListening = false;
  }

  // ── TTS ──────────────────────────────────────────────────────────────────
  final FlutterTts _tts = FlutterTts();
  bool _ttsReady = false;
  bool _isSpeaking = false;
  bool _ttsEnabled = false;  // user toggle

  bool get ttsEnabled => _ttsEnabled;
  bool get isSpeaking  => _isSpeaking;

  Future<void> initTTS() async {
    if (_ttsReady) return;
    try {
      await _tts.setLanguage('en-IN');
      await _tts.setSpeechRate(0.48);   // slightly slower for health context
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      _tts.setStartHandler(() => _isSpeaking = true);
      _tts.setCompletionHandler(() => _isSpeaking = false);
      _tts.setErrorHandler((msg) {
        _isSpeaking = false;
        debugPrint('[VoiceService] TTS error: $msg');
      });

      _ttsReady = true;
    } catch (e) {
      debugPrint('[VoiceService] initTTS failed: $e');
    }
  }

  void setTTSEnabled(bool value) => _ttsEnabled = value;

  /// Speak [text] if TTS is enabled. Strips markdown formatting first.
  Future<void> speak(String text) async {
    if (!_ttsEnabled) return;
    if (!_ttsReady) await initTTS();
    final clean = _stripMarkdown(text);
    if (clean.trim().isEmpty) return;
    await _tts.speak(clean);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
    _isSpeaking = false;
  }

  // Strip common markdown so TTS doesn't read "asterisk asterisk" etc.
  static String _stripMarkdown(String text) => text
      .replaceAll(RegExp(r'\*{1,3}(.*?)\*{1,3}'), r'$1')
      .replaceAll(RegExp(r'#{1,6}\s?'), '')
      .replaceAll(RegExp(r'`{1,3}(.*?)`{1,3}'), r'$1')
      .replaceAll(RegExp(r'\[([^\]]+)\]\([^)]*\)'), r'$1')
      .replaceAll(RegExp(r'•\s?'), '')
      .replaceAll(RegExp(r'\n{2,}'), '. ')
      .replaceAll('\n', '. ')
      .trim();

  void dispose() {
    _stt.cancel();
    _tts.stop();
  }
}



































