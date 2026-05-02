
// lib/core/services/groq_service.dart
// Llama 3 AI via Groq API — powers GreenBot
// Works on Flutter Web (CORS handled)

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GroqService {
  // ── CONFIG ──────────────────────────────────────────────────────────────────
  // Replace with your key from https://console.groq.com (free, no card needed)
  static String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? '';
  static const String _url = 'https://dark-scene-8a03.mowundha123.workers.dev/';
  static const String _model = 'llama-3.3-70b-versatile';

  // ── SYSTEM PROMPT ────────────────────────────────────────────────────────────
  static const String _system = '''
You are GreenBot, a friendly AI wellness companion inside the GreenBasket+ app — a preventive health app used mainly in India.

Your role:
- Help users with daily health habits, medicines, nutrition, symptoms, and lifestyle
- Focus on Indian context: dal, roti, sabzi, methi, rajma, coconut water, etc.
- Be warm, encouraging, and concise

RESPONSE STYLE:
- Do NOT start with "Namaste" or greet excessively on every message
- Get straight to the helpful answer
- Use emojis and bullet points for readability
- Keep responses under 200 words

STRICT SAFETY RULES:
1. Never diagnose or prescribe — you are NOT a doctor.
2. For any symptom response, end with: ⚠️ Please consult your doctor for accurate medical guidance.
3. If user mentions chest pain, stroke, severe breathing difficulty, or loss of consciousness, respond ONLY with: 🚨 This is a medical emergency. Call 112 immediately.
4. Never recommend stopping prescribed medicines.
''';

  // ── SEND MESSAGE ─────────────────────────────────────────────────────────────
  static Future<String> chat(
    String userMessage, {
    List<Map<String, String>> history = const [],
  }) async {
    final lower = userMessage.toLowerCase();

    if (_isEmergency(lower)) {
      return '🚨 This is a medical emergency.\n\nCall 112 immediately. Do not wait.';
    }

    final messages = [
      {'role': 'system', 'content': _system},
      ...history.length > 10 ? history.sublist(history.length - 10) : history,
      {'role': 'user', 'content': userMessage},
    ];

    final requestBody = jsonEncode({
      'model': _model,
      'messages': messages,
      'max_tokens': 400,
      'temperature': 0.7,
    });

    try {
      final res = await http.post(
        Uri.parse(_url),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer $_apiKey',
        },
        body: requestBody,
      ).timeout(const Duration(seconds: 20));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final text = data['choices']?[0]?['message']?['content'] as String?;
        return text?.trim() ?? _offlineFallback(lower);
      }
      if (res.statusCode == 401) {
        debugPrint('[Groq] ❌ 401 — API key invalid or expired. Visit console.groq.com');
        return '🔑 GreenBot API key is invalid or expired.\n\nGet a new free key at console.groq.com and paste it in groq_service.dart.';
      }
      if (res.statusCode == 429) {
        debugPrint('[Groq] ⏳ 429 — Rate limit hit');
        return '⏳ GreenBot is busy. Please try again in a moment.';
      }
      debugPrint('[Groq] ❌ Status ${res.statusCode}: ${res.body}');
      return _offlineFallback(lower);

    } catch (e) {
      debugPrint('[Groq] ❌ Exception: $e');
      // On Flutter Web this is almost always a CORS error.
      // Run with: flutter run -d chrome --web-browser-flag "--disable-web-security"
      if (kIsWeb) {
        return '🌐 Connection blocked on web browser (CORS).\n\n'
            'Please run your app using:\n'
            'flutter run -d chrome --web-browser-flag "--disable-web-security"\n\n'
            'Or test on Android/iOS where this works fine.';
      }
      return _offlineFallback(lower);
    }
  }

  // ── EMERGENCY CHECK ──────────────────────────────────────────────────────────
  static bool _isEmergency(String text) => [
    'chest pain', 'heart attack', 'stroke', "can't breathe",
    'difficulty breathing', 'unconscious', 'not breathing',
  ].any((k) => text.contains(k));

  // ── OFFLINE FALLBACK ─────────────────────────────────────────────────────────
  static String _offlineFallback(String input) {
    if (input.contains('diabetes') || input.contains('sugar')) {
      return '🩸 Diabetes tips:\n• Eat low-GI foods: oats, rajma, brown rice\n• Walk 20 min after each meal\n• Avoid sugary drinks and white rice\n• Take medicines after food\n\n⚠️ Please consult your doctor for accurate medical guidance.';
    }
    if (input.contains('bp') || input.contains('blood pressure')) {
      return '💓 BP tips:\n• Reduce salt under 5g/day\n• Eat banana, spinach, beetroot\n• Walk 30 min daily\n• Avoid packaged and fried foods\n\n⚠️ Please consult your doctor for accurate medical guidance.';
    }
    if (input.contains('sleep')) {
      return '😴 Sleep tips:\n• Sleep by 10–10:30 PM\n• No screens 30 min before bed\n• Avoid heavy dinner after 8 PM\n• Try 4-7-8 breathing to fall asleep';
    }
    if (input.contains('headache')) {
      return '🤕 For headache:\n• Drink 2 glasses of water immediately\n• Rest in a dark, quiet room\n• Apply cold compress on forehead\n\n⚠️ Please consult your doctor for accurate medical guidance.';
    }
    if (input.contains('eat') || input.contains('meal') || input.contains('food')) {
      return '🥗 Meal ideas for today:\n• Breakfast: Oats with banana or poha with veggies\n• Lunch: Dal + roti + sabzi + curd\n• Snack: Roasted chana or a fruit\n• Dinner: Khichdi or vegetable soup\n\nStay hydrated — drink 8 glasses of water! 💧';
    }
    if (input.contains('motivat') || input.contains('inspire')) {
      return '💪 Every healthy choice you make today is an investment in your future. Keep going — you\'re doing amazing!';
    }
    if (_isGreeting(input)) {
      return '👋 Hello! I\'m GreenBot, your AI wellness companion.\n\nAsk me about meals, medicines, symptoms, or healthy habits!';
    }
    return '🌿 I\'m having trouble connecting right now.\n\nYou can ask me about:\n• Meal ideas\n• Symptom guidance\n• Medicine tips\n• Sleep & stress\n• Motivation\n\nPlease check your internet and try again.';
  }

  static bool _isGreeting(String t) =>
      ['hello', 'hi ', 'hey', 'namaste', 'good morning', 'good evening'].any((k) => t.contains(k));
}