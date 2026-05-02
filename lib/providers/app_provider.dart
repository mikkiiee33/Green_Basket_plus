
// // lib/providers/app_provider.dart
// // Central state management using Provider
 
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../core/services/groq_service.dart';
// import '../core/services/firestore_service.dart';
 
// import '../models/user_profile.dart';
// import '../models/medication.dart';
// import '../models/habit.dart';
// import '../models/checkup.dart';
// import '../models/chat_message.dart';
// import '../models/lifestyle_reminder.dart';
// import '../core/constants/app_constants.dart';
 
// // ═══════════════════════════════════════════════════════════════
// // AUTH PROVIDER
// // ═══════════════════════════════════════════════════════════════
// class AuthProvider extends ChangeNotifier {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
 
//   bool _isLoading = false;
//   String? _errorMessage;
 
//   User? get currentUser => _auth.currentUser;
//   bool get isLoggedIn => _auth.currentUser != null;
//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;
 
//   // Real display name from Firebase Auth (set on signup)
//   String get displayName =>
//       _auth.currentUser?.displayName?.trim().isNotEmpty == true
//           ? _auth.currentUser!.displayName!.trim()
//           : _auth.currentUser?.email?.split('@').first ?? 'User';
 
//   String get userEmail => _auth.currentUser?.email ?? '';
 
//   Future<bool> signup(String name, String email, String password) async {
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();
//     try {
//       final credential = await _auth.createUserWithEmailAndPassword(
//         email: email.trim(),
//         password: password,
//       );
//       // Save the real name to Firebase Auth profile
//       await credential.user?.updateDisplayName(name.trim());
//       // Reload so displayName is immediately available
//       await _auth.currentUser?.reload();
//       // ── Save user document to Firestore on signup ─────────────
//       await FirestoreService.initializeNewUser(
//         name: name.trim(),
//         email: email.trim(),
//       );
//       _isLoading = false;
//       notifyListeners();
//       return true;
//     } on FirebaseAuthException catch (e) {
//       _errorMessage = _friendlyError(e.code);
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//   }
 
//   Future<bool> login(String email, String password) async {
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();
//     try {
//       await _auth.signInWithEmailAndPassword(
//         email: email.trim(),
//         password: password,
//       );
//       // Reload to get latest displayName
//       await _auth.currentUser?.reload();
//       _isLoading = false;
//       notifyListeners();
//       return true;
//     } on FirebaseAuthException catch (e) {
//       _errorMessage = _friendlyError(e.code);
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//   }
 
//   Future<void> logout() async {
//     await _auth.signOut();
//     notifyListeners();
//   }
 
//   Future<bool> resetPassword(String email) async {
//     try {
//       await _auth.sendPasswordResetEmail(email: email.trim());
//       return true;
//     } on FirebaseAuthException catch (e) {
//       _errorMessage = _friendlyError(e.code);
//       notifyListeners();
//       return false;
//     }
//   }
 
//   void clearError() {
//     _errorMessage = null;
//     notifyListeners();
//   }
 
//   String _friendlyError(String code) {
//     switch (code) {
//       case 'email-already-in-use':
//         return 'An account with this email already exists.';
//       case 'invalid-email':
//         return 'Please enter a valid email address.';
//       case 'weak-password':
//         return 'Password must be at least 6 characters.';
//       case 'user-not-found':
//         return 'No account found with this email.';
//       case 'wrong-password':
//         return 'Incorrect password. Please try again.';
//       case 'invalid-credential':
//         return 'Email or password is incorrect.';
//       case 'too-many-requests':
//         return 'Too many attempts. Please try again later.';
//       case 'network-request-failed':
//         return 'No internet connection. Please check your network.';
//       default:
//         return 'Something went wrong. Please try again.';
//     }
//   }
// }
 
// // ═══════════════════════════════════════════════════════════════
// // USER PROFILE PROVIDER
// // ═══════════════════════════════════════════════════════════════
// class UserProfileProvider extends ChangeNotifier {
//   UserProfile? _profile;
//   bool _profileSetupComplete = false;
 
//   UserProfile? get profile => _profile;
//   bool get profileSetupComplete => _profileSetupComplete;
 
//   void setProfile(UserProfile profile) {
//     _profile = profile;
//     _profileSetupComplete = true;
//     notifyListeners();
//   }
 
//   void updateProfile(UserProfile updated) {
//     _profile = updated;
//     notifyListeners();
//   }
 
//   /// Load profile using real Firebase Auth name + email.
//   /// Call this after login instead of loadMockProfile().
//   void loadFromFirebaseAuth(User user) {
//     final name = user.displayName?.trim().isNotEmpty == true
//         ? user.displayName!.trim()
//         : user.email?.split('@').first ?? 'User';
//     final email = user.email ?? '';
 
//     // If a profile already exists (from profile setup), just update name/email
//     if (_profile != null) {
//       _profile = _profile!.copyWith(name: name, email: email);
//     } else {
//       // Create a default profile with real name — user can update rest later
//       _profile = UserProfile(
//         id: user.uid,
//         name: name,
//         email: email,
//         age: 35,
//         gender: Gender.male,
//         weight: 70.0,
//         height: 170.0,
//         healthConditions: [HealthCondition.none],
//         foodPreference: FoodPreference.veg,
//         activityLevel: ActivityLevel.moderate,
//       );
//     }
//     _profileSetupComplete = _profile != null;
//     notifyListeners();
//   }
 
//   // Keep for backward compat but use real name if Firebase is available
//   void loadMockProfile() {
//     _profile = UserProfile.mock;
//     _profileSetupComplete = true;
//     notifyListeners();
//   }
// }
 
// // ═══════════════════════════════════════════════════════════════
// // HABITS PROVIDER
// // ═══════════════════════════════════════════════════════════════
// class HabitsProvider extends ChangeNotifier {
//   List<Habit> _habits = [];
//   int _healthScore = 65;
 
//   List<Habit> get habits => _habits;
//   int get healthScore => _healthScore;
//   int get completedCount => _habits.where((h) => h.isCompleted).length;
//   double get completionPercentage =>
//       _habits.isEmpty ? 0.0 : completedCount / _habits.length;
 
//   void loadHabitsForProfile(UserProfile profile) {
//     _habits = Habit.buildFor(
//       hasDiabetes: profile.hasDiabetes,
//       hasBP: profile.hasBP,
//       hasThyroid: profile.hasThyroid,
//       isVeg: profile.foodPreference == FoodPreference.veg,
//     );
//     _updateHealthScore();
//     notifyListeners();
//   }
 
//   void toggleHabit(String id) {
//     final index = _habits.indexWhere((h) => h.id == id);
//     if (index != -1) {
//       _habits[index] = _habits[index].copyWith(
//         isCompleted: !_habits[index].isCompleted,
//       );
//       _updateHealthScore();
//       notifyListeners();
//     }
//   }
 
//   void resetDaily() {
//     _habits = _habits.map((h) => h.copyWith(isCompleted: false)).toList();
//     _updateHealthScore();
//     notifyListeners();
//   }
 
//   void _updateHealthScore() {
//     if (_habits.isEmpty) return;
//     const base = 40;
//     final bonus = (completionPercentage * 60).round();
//     _healthScore = (base + bonus).clamp(0, 100);
//   }
// }
 
// // ═══════════════════════════════════════════════════════════════
// // MEDICATIONS PROVIDER
// // ═══════════════════════════════════════════════════════════════
// class MedicationsProvider extends ChangeNotifier {
//   List<Medication> _medications = [];
 
//   List<Medication> get medications => _medications;
//   int get totalCount => _medications.length;
//   int get takenToday =>
//       _medications.where((m) => m.status == MedicationStatus.taken).length;
//   double get adherencePercentage =>
//       totalCount == 0 ? 0.0 : (takenToday / totalCount) * 100;
 
//   void loadMedications(List<Medication> meds) {
//     _medications = meds;
//     notifyListeners();
//   }
 
//   void addMedication(Medication med) {
//     _medications.add(med);
//     notifyListeners();
//   }
 
//   void updateMedication(Medication updated) {
//     final index = _medications.indexWhere((m) => m.id == updated.id);
//     if (index != -1) {
//       _medications[index] = updated;
//       notifyListeners();
//     }
//   }
 
//   void updateStatus(String id, MedicationStatus status) {
//     final index = _medications.indexWhere((m) => m.id == id);
//     if (index != -1) {
//       _medications[index] = _medications[index].copyWith(status: status);
//       notifyListeners();
//     }
//   }
 
//   void markTaken(String id) => updateStatus(id, MedicationStatus.taken);
//   void markMissed(String id) => updateStatus(id, MedicationStatus.missed);
 
//   void deleteMedication(String id) {
//     _medications.removeWhere((m) => m.id == id);
//     notifyListeners();
//   }
// }
 
// // ═══════════════════════════════════════════════════════════════
// // CHECKUPS PROVIDER
// // ═══════════════════════════════════════════════════════════════
// class CheckupsProvider extends ChangeNotifier {
//   List<Checkup> _checkups = [];
 
//   List<Checkup> get checkups => _checkups;
//   List<Checkup> get dueCheckups => _checkups.where((c) => c.isDue).toList();
//   List<Checkup> get upcomingCheckups =>
//       _checkups.where((c) => !c.isDue && c.daysUntilDue <= 14).toList();
 
//   void loadCheckups(List<Checkup> checkups) {
//     _checkups = checkups;
//     notifyListeners();
//   }
 
//   /// Load default checkups for a new/returning user
//   void loadDefaultCheckups() {
//     _checkups = Checkup.mockList;
//     notifyListeners();
//   }
 
//   void markDone(String id) {
//     final index = _checkups.indexWhere((c) => c.id == id);
//     if (index != -1) {
//       _checkups[index] = _checkups[index].copyWith(lastDone: DateTime.now());
//       notifyListeners();
//     }
//   }
// }
 
// // ═══════════════════════════════════════════════════════════════
// // LIFESTYLE PROVIDER
// // ═══════════════════════════════════════════════════════════════
// class LifestyleProvider extends ChangeNotifier {
//   List<LifestyleReminder> _reminders = const [
//     LifestyleReminder(id: '1', title: 'Morning Walk',    subtitle: '20 minutes brisk walk',           icon: '🚶', time: '07:00', doneHistory: [1, 1, 0, 1, 1, 1, 0]),
//     LifestyleReminder(id: '2', title: 'Drink Water',     subtitle: '2–3 liters throughout day',       icon: '💧', time: '08:00', doneHistory: [1, 1, 1, 0, 1, 1, 1]),
//     LifestyleReminder(id: '3', title: 'Eat a Fruit',     subtitle: 'Fresh seasonal fruit',            icon: '🍎', time: '10:00', doneHistory: [0, 1, 1, 1, 0, 1, 1]),
//     LifestyleReminder(id: '4', title: 'Stretch Break',   subtitle: '5-minute stretching session',     icon: '🤸', time: '15:00', doneHistory: [1, 0, 0, 1, 1, 0, 1]),
//     LifestyleReminder(id: '5', title: 'Sleep Early',     subtitle: 'Wind down by 10 PM',             icon: '😴', time: '22:00', doneHistory: [1, 1, 0, 0, 1, 1, 1]),
//     LifestyleReminder(id: '6', title: 'Weekly Weigh-in', subtitle: 'Check your weight once a week', icon: '⚖️', time: '08:00', isWeekly: true, doneHistory: [1, 0, 1, 0, 1, 0, 1]),
//   ];
 
//   List<LifestyleReminder> get reminders => _reminders;
//   int get completedToday => _reminders.where((r) => r.isDone).length;
 
//   double get overallConsistency {
//     if (_reminders.isEmpty) return 0.0;
//     return _reminders
//             .map((r) => r.consistencyPercentage)
//             .reduce((a, b) => a + b) /
//         _reminders.length;
//   }
 
//   void toggleDone(String id) {
//     final index = _reminders.indexWhere((r) => r.id == id);
//     if (index != -1) {
//       final updated = List<LifestyleReminder>.from(_reminders);
//       updated[index] = updated[index].copyWith(isDone: !updated[index].isDone);
//       _reminders = updated;
//       notifyListeners();
//     }
//   }
// }
 
// // ═══════════════════════════════════════════════════════════════
// // CHAT PROVIDER  — powered by Groq Llama 3 AI
// // ═══════════════════════════════════════════════════════════════
// class ChatProvider extends ChangeNotifier {
//   final List<ChatMessage> _messages = [];
//   bool _isTyping = false;
//   bool _historyLoaded = false;
 
//   List<ChatMessage> get messages => List.unmodifiable(_messages);
//   bool get isTyping => _isTyping;
//   bool get historyLoaded => _historyLoaded;
 
//   // ── LOAD CHAT HISTORY FROM FIRESTORE ─────────────────────────
//   Future<void> loadHistory() async {
//     if (_historyLoaded) return;
//     _historyLoaded = true;
//     try {
//       final snapshot = await FirestoreService.getChatHistory();
//       if (snapshot.isEmpty) {
//         // New user — show welcome message
//         _messages.add(ChatMessage(
//           content: '👋 Hi! I\'m GreenBot, your AI wellness companion.\n\n'
//               'I can help you with:\n'
//               '• 🥗 Personalised meal suggestions\n'
//               '• 💊 Medicine & nutrition advice\n'
//               '• 🏃 Exercise & lifestyle tips\n'
//               '• 🩺 Basic symptom guidance\n'
//               '• 💪 Wellness motivation\n\n'
//               'How can I help you today?',
//           isUser: false,
//         ));
//       } else {
//         for (final msg in snapshot) {
//           _messages.add(ChatMessage(
//             content: msg['text'] as String,
//             isUser: msg['isUser'] as bool,
//           ));
//         }
//       }
//     } catch (e) {
//       debugPrint('[ChatProvider] Failed to load history: \$e');
//       _messages.add(ChatMessage(
//         content: '👋 Hi! I\'m GreenBot. How can I help you today?',
//         isUser: false,
//       ));
//     }
//     notifyListeners();
//   }
 
//   Future<void> sendMessage(String text) async {
//     final trimmed = text.trim();
//     if (trimmed.isEmpty) return;
 
//     _messages.add(ChatMessage(content: trimmed, isUser: true));
//     _isTyping = true;
//     notifyListeners();
 
//     // ── Save user message to Firestore ────────────────────────
//     await FirestoreService.saveChatMessage(text: trimmed, isUser: true);
 
//     // Build conversation history for Groq context (skip first welcome message)
//     final history = _messages
//         .skip(1)                       // skip welcome message
//         .take(_messages.length - 2)   // exclude message just added
//         .map((m) => {
//               'role': m.isUser ? 'user' : 'assistant',
//               'content': m.content,
//             })
//         .toList();
 
//     final response = await GroqService.chat(trimmed, history: history);
 
//     _messages.add(ChatMessage(content: response, isUser: false));
 
//     // ── Save bot response to Firestore ────────────────────────
//     await FirestoreService.saveChatMessage(text: response, isUser: false);
 
//     _isTyping = false;
//     notifyListeners();
//   }
 
//   void clearChat() {
//     _messages.clear();
//     _messages.add(ChatMessage(
//       content: '👋 Chat cleared. How can I help you today?',
//       isUser: false,
//     ));
//     notifyListeners();
//   }
// }
 
// // ═══════════════════════════════════════════════════════════════
// // ACCESSIBILITY PROVIDER
// // ═══════════════════════════════════════════════════════════════
// class AccessibilityProvider extends ChangeNotifier {
//   bool _accessibilityMode = false;
//   bool _highContrast = false;
//   bool _largeText = false;
//   double _textScale = 1.0;
 
//   bool get accessibilityMode => _accessibilityMode;
//   bool get highContrast => _highContrast;
//   bool get largeText => _largeText;
//   double get textScale => _textScale;
 
//   void toggleAccessibilityMode() {
//     _accessibilityMode = !_accessibilityMode;
//     notifyListeners();
//   }
 
//   void toggleAccessibility() => toggleAccessibilityMode();
 
//   void toggleHighContrast() {
//     _highContrast = !_highContrast;
//     notifyListeners();
//   }
 
//   void toggleLargeText() {
//     _largeText = !_largeText;
//     _textScale = _largeText ? 1.2 : 1.0;
//     notifyListeners();
//   }
 
//   void setTextScale(double scale) {
//     _textScale = scale;
//     notifyListeners();
//   }
// }







































// lib/providers/app_provider.dart
// Central state management using Provider
 
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/services/groq_service.dart';
import '../core/services/firestore_service.dart';
 
import '../models/user_profile.dart';
import '../models/medication.dart';
import '../models/habit.dart';
import '../models/checkup.dart';
import '../models/chat_message.dart';
import '../models/lifestyle_reminder.dart';
import '../core/constants/app_constants.dart';
 
// ═══════════════════════════════════════════════════════════════
// AUTH PROVIDER
// ═══════════════════════════════════════════════════════════════
class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
 
  bool _isLoading = false;
  String? _errorMessage;
 
  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
 
  // Real display name from Firebase Auth (set on signup)
  String get displayName =>
      _auth.currentUser?.displayName?.trim().isNotEmpty == true
          ? _auth.currentUser!.displayName!.trim()
          : _auth.currentUser?.email?.split('@').first ?? 'User';
 
  String get userEmail => _auth.currentUser?.email ?? '';
 
  Future<bool> signup(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      // Save the real name to Firebase Auth profile
      await credential.user?.updateDisplayName(name.trim());
      // Reload so displayName is immediately available
      await _auth.currentUser?.reload();
      // ── Save user document to Firestore on signup ─────────────
      await FirestoreService.initializeNewUser(
        name: name.trim(),
        email: email.trim(),
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _friendlyError(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
 
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      // Reload to get latest displayName
      await _auth.currentUser?.reload();
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _friendlyError(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
 
  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }
 
  // ── DEMO / ANONYMOUS LOGIN ───────────────────────────────────
  Future<bool> loginDemo() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _auth.signInAnonymously();
      await _auth.currentUser?.reload();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Demo login failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
 
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _friendlyError(e.code);
      notifyListeners();
      return false;
    }
  }
 
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
 
  String _friendlyError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Email or password is incorrect.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
 
// ═══════════════════════════════════════════════════════════════
// USER PROFILE PROVIDER
// ═══════════════════════════════════════════════════════════════
class UserProfileProvider extends ChangeNotifier {
  UserProfile? _profile;
  bool _profileSetupComplete = false;
 
  UserProfile? get profile => _profile;
  bool get profileSetupComplete => _profileSetupComplete;
 
  void setProfile(UserProfile profile) {
    _profile = profile;
    _profileSetupComplete = true;
    notifyListeners();
  }
 
  void updateProfile(UserProfile updated) {
    _profile = updated;
    notifyListeners();
  }
 
  /// Load profile using real Firebase Auth name + email.
  /// Call this after login instead of loadMockProfile().
  void loadFromFirebaseAuth(User user) {
    final name = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : user.email?.split('@').first ?? 'User';
    final email = user.email ?? '';
 
    // If a profile already exists (from profile setup), just update name/email
    if (_profile != null) {
      _profile = _profile!.copyWith(name: name, email: email);
    } else {
      // Create a default profile with real name — user can update rest later
      _profile = UserProfile(
        id: user.uid,
        name: name,
        email: email,
        age: 35,
        gender: Gender.male,
        weight: 70.0,
        height: 170.0,
        healthConditions: [HealthCondition.none],
        foodPreference: FoodPreference.veg,
        activityLevel: ActivityLevel.moderate,
      );
    }
    _profileSetupComplete = _profile != null;
    notifyListeners();
  }
 
  // Keep for backward compat but use real name if Firebase is available
  void loadMockProfile() {
    _profile = UserProfile.mock;
    _profileSetupComplete = true;
    notifyListeners();
  }
}
 
// ═══════════════════════════════════════════════════════════════
// HABITS PROVIDER
// ═══════════════════════════════════════════════════════════════
class HabitsProvider extends ChangeNotifier {
  List<Habit> _habits = [];
  int _healthScore = 65;
 
  List<Habit> get habits => _habits;
  int get healthScore => _healthScore;
  int get completedCount => _habits.where((h) => h.isCompleted).length;
  double get completionPercentage =>
      _habits.isEmpty ? 0.0 : completedCount / _habits.length;
 
  void loadHabitsForProfile(UserProfile profile) {
    _habits = Habit.buildFor(
      hasDiabetes: profile.hasDiabetes,
      hasBP: profile.hasBP,
      hasThyroid: profile.hasThyroid,
      isVeg: profile.foodPreference == FoodPreference.veg,
    );
    _updateHealthScore();
    notifyListeners();
  }
 
  void toggleHabit(String id) {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      _habits[index] = _habits[index].copyWith(
        isCompleted: !_habits[index].isCompleted,
      );
      _updateHealthScore();
      notifyListeners();
    }
  }
 
  void resetDaily() {
    _habits = _habits.map((h) => h.copyWith(isCompleted: false)).toList();
    _updateHealthScore();
    notifyListeners();
  }
 
  void _updateHealthScore() {
    if (_habits.isEmpty) return;
    const base = 40;
    final bonus = (completionPercentage * 60).round();
    _healthScore = (base + bonus).clamp(0, 100);
  }
}
 
// ═══════════════════════════════════════════════════════════════
// MEDICATIONS PROVIDER
// ═══════════════════════════════════════════════════════════════
class MedicationsProvider extends ChangeNotifier {
  List<Medication> _medications = [];
 
  List<Medication> get medications => _medications;
  int get totalCount => _medications.length;
  int get takenToday =>
      _medications.where((m) => m.status == MedicationStatus.taken).length;
  double get adherencePercentage =>
      totalCount == 0 ? 0.0 : (takenToday / totalCount) * 100;
 
  void loadMedications(List<Medication> meds) {
    _medications = meds;
    notifyListeners();
  }
 
  void addMedication(Medication med) {
    _medications.add(med);
    notifyListeners();
  }
 
  void updateMedication(Medication updated) {
    final index = _medications.indexWhere((m) => m.id == updated.id);
    if (index != -1) {
      _medications[index] = updated;
      notifyListeners();
    }
  }
 
  void updateStatus(String id, MedicationStatus status) {
    final index = _medications.indexWhere((m) => m.id == id);
    if (index != -1) {
      _medications[index] = _medications[index].copyWith(status: status);
      notifyListeners();
    }
  }
 
  void markTaken(String id) => updateStatus(id, MedicationStatus.taken);
  void markMissed(String id) => updateStatus(id, MedicationStatus.missed);
 
  void deleteMedication(String id) {
    _medications.removeWhere((m) => m.id == id);
    notifyListeners();
  }
}
 
// ═══════════════════════════════════════════════════════════════
// CHECKUPS PROVIDER
// ═══════════════════════════════════════════════════════════════
class CheckupsProvider extends ChangeNotifier {
  List<Checkup> _checkups = [];
 
  List<Checkup> get checkups => _checkups;
  List<Checkup> get dueCheckups => _checkups.where((c) => c.isDue).toList();
  List<Checkup> get upcomingCheckups =>
      _checkups.where((c) => !c.isDue && c.daysUntilDue <= 14).toList();
 
  void loadCheckups(List<Checkup> checkups) {
    _checkups = checkups;
    notifyListeners();
  }
 
  /// Load default checkups for a new/returning user
  void loadDefaultCheckups() {
    _checkups = Checkup.mockList;
    notifyListeners();
  }
 
  void markDone(String id) {
    final index = _checkups.indexWhere((c) => c.id == id);
    if (index != -1) {
      _checkups[index] = _checkups[index].copyWith(lastDone: DateTime.now());
      notifyListeners();
    }
  }
}
 
// ═══════════════════════════════════════════════════════════════
// LIFESTYLE PROVIDER
// ═══════════════════════════════════════════════════════════════
class LifestyleProvider extends ChangeNotifier {
  List<LifestyleReminder> _reminders = const [
    LifestyleReminder(id: '1', title: 'Morning Walk',    subtitle: '20 minutes brisk walk',           icon: '🚶', time: '07:00', doneHistory: [1, 1, 0, 1, 1, 1, 0]),
    LifestyleReminder(id: '2', title: 'Drink Water',     subtitle: '2–3 liters throughout day',       icon: '💧', time: '08:00', doneHistory: [1, 1, 1, 0, 1, 1, 1]),
    LifestyleReminder(id: '3', title: 'Eat a Fruit',     subtitle: 'Fresh seasonal fruit',            icon: '🍎', time: '10:00', doneHistory: [0, 1, 1, 1, 0, 1, 1]),
    LifestyleReminder(id: '4', title: 'Stretch Break',   subtitle: '5-minute stretching session',     icon: '🤸', time: '15:00', doneHistory: [1, 0, 0, 1, 1, 0, 1]),
    LifestyleReminder(id: '5', title: 'Sleep Early',     subtitle: 'Wind down by 10 PM',             icon: '😴', time: '22:00', doneHistory: [1, 1, 0, 0, 1, 1, 1]),
    LifestyleReminder(id: '6', title: 'Weekly Weigh-in', subtitle: 'Check your weight once a week', icon: '⚖️', time: '08:00', isWeekly: true, doneHistory: [1, 0, 1, 0, 1, 0, 1]),
  ];
 
  List<LifestyleReminder> get reminders => _reminders;
  int get completedToday => _reminders.where((r) => r.isDone).length;
 
  double get overallConsistency {
    if (_reminders.isEmpty) return 0.0;
    return _reminders
            .map((r) => r.consistencyPercentage)
            .reduce((a, b) => a + b) /
        _reminders.length;
  }
 
  void toggleDone(String id) {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      final updated = List<LifestyleReminder>.from(_reminders);
      updated[index] = updated[index].copyWith(isDone: !updated[index].isDone);
      _reminders = updated;
      notifyListeners();
    }
  }
}
 
// ═══════════════════════════════════════════════════════════════
// CHAT PROVIDER  — powered by Groq Llama 3 AI
// ═══════════════════════════════════════════════════════════════
class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _historyLoaded = false;
 
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;
  bool get historyLoaded => _historyLoaded;
 
  // ── LOAD CHAT HISTORY FROM FIRESTORE ─────────────────────────
  Future<void> loadHistory() async {
    if (_historyLoaded) return;
    _historyLoaded = true;
    try {
      final snapshot = await FirestoreService.getChatHistory();
      if (snapshot.isEmpty) {
        // New user — show welcome message
        _messages.add(ChatMessage(
          content: '👋 Hi! I\'m GreenBot, your AI wellness companion.\n\n'
              'I can help you with:\n'
              '• 🥗 Personalised meal suggestions\n'
              '• 💊 Medicine & nutrition advice\n'
              '• 🏃 Exercise & lifestyle tips\n'
              '• 🩺 Basic symptom guidance\n'
              '• 💪 Wellness motivation\n\n'
              'How can I help you today?',
          isUser: false,
        ));
      } else {
        for (final msg in snapshot) {
          _messages.add(ChatMessage(
            content: msg['text'] as String,
            isUser: msg['isUser'] as bool,
          ));
        }
      }
    } catch (e) {
      debugPrint('[ChatProvider] Failed to load history: \$e');
      _messages.add(ChatMessage(
        content: '👋 Hi! I\'m GreenBot. How can I help you today?',
        isUser: false,
      ));
    }
    notifyListeners();
  }
 
  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
 
    _messages.add(ChatMessage(content: trimmed, isUser: true));
    _isTyping = true;
    notifyListeners();
 
    // ── Save user message to Firestore ────────────────────────
    await FirestoreService.saveChatMessage(text: trimmed, isUser: true);
 
    // Build conversation history for Groq context (skip first welcome message)
    final history = _messages
        .skip(1)                       // skip welcome message
        .take(_messages.length - 2)   // exclude message just added
        .map((m) => {
              'role': m.isUser ? 'user' : 'assistant',
              'content': m.content,
            })
        .toList();
 
    final response = await GroqService.chat(trimmed, history: history);
 
    _messages.add(ChatMessage(content: response, isUser: false));
 
    // ── Save bot response to Firestore ────────────────────────
    await FirestoreService.saveChatMessage(text: response, isUser: false);
 
    _isTyping = false;
    notifyListeners();
  }
 
  void clearChat() {
    _messages.clear();
    _messages.add(ChatMessage(
      content: '👋 Chat cleared. How can I help you today?',
      isUser: false,
    ));
    notifyListeners();
  }

  // ── SEND MESSAGE RAW (for direct AI responses without history save) ────────
  Future<String> sendMessageRaw(String text, {List<Map<String, String>> history = const []}) async {
    try {
      final response = await GroqService.chat(text, history: history);
      return response;
    } catch (e) {
      return 'Sorry, I couldn\'t connect right now. Please try again.';
    }
  }
}
 
// ═══════════════════════════════════════════════════════════════
// ACCESSIBILITY PROVIDER
// ═══════════════════════════════════════════════════════════════
class AccessibilityProvider extends ChangeNotifier {
  bool _accessibilityMode = false;
  bool _highContrast = false;
  bool _largeText = false;
  double _textScale = 1.0;
 
  bool get accessibilityMode => _accessibilityMode;
  bool get highContrast => _highContrast;
  bool get largeText => _largeText;
  double get textScale => _textScale;
 
  void toggleAccessibilityMode() {
    _accessibilityMode = !_accessibilityMode;
    notifyListeners();
  }
 
  void toggleAccessibility() => toggleAccessibilityMode();
 
  void toggleHighContrast() {
    _highContrast = !_highContrast;
    notifyListeners();
  }
 
  void toggleLargeText() {
    _largeText = !_largeText;
    _textScale = _largeText ? 1.2 : 1.0;
    notifyListeners();
  }
 
  void setTextScale(double scale) {
    _textScale = scale;
    notifyListeners();
  }
}