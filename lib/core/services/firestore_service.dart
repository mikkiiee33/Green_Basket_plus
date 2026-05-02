

// lib/core/services/firestore_service.dart
//
// ═══════════════════════════════════════════════════════════════
// WHAT IS THIS FILE?
// ═══════════════════════════════════════════════════════════════
// This is the ONLY file that talks to Firestore in your app.
// Every other file (providers, screens) calls THIS file.
// Think of it as the "translator" between your Flutter app
// and Firebase's database.
//
// GOLDEN RULE OF FIRESTORE:
// ─────────────────────────
// Every user's data lives at:
//   users/{uid}/...
//
// {uid} is the unique ID Firebase gave the user when they
// signed up. You saw it in Firebase Console → Authentication
// → Users → "EbC2kb98UjhAurpC..."
//
// This means Ayisha's data and Ravi's data are COMPLETELY
// separate. One user can NEVER see another's data.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  // ── THE DATABASE INSTANCE ────────────────────────────────────
  // FirebaseFirestore.instance is like opening a connection to
  // the database. It's a singleton — same object everywhere.
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── GET CURRENT USER'S UID ───────────────────────────────────
  // This is the key we use to find THIS user's data.
  // If null, the user is not logged in.
  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // ── SHORTCUT TO THIS USER'S DOCUMENT ────────────────────────
  // Instead of writing _db.collection('users').doc(_uid)
  // everywhere, we make a shortcut called _userDoc.
  //
  // HOW TO READ THIS:
  //   _db                      → the Firestore database
  //   .collection('users')     → go into the 'users' collection
  //   .doc(_uid)               → find the document with this UID
  //
  // This points to ONE specific document — the logged-in user's.
  static DocumentReference get _userDoc =>
      _db.collection('users').doc(_uid);

  // ═══════════════════════════════════════════════════════════════
  // PROFILE
  // ═══════════════════════════════════════════════════════════════
  //
  // HOW set() WORKS:
  // ─────────────────
  // .set({...}) writes a Map to the document.
  // If the document doesn't exist → creates it.
  // If it already exists → OVERWRITES it completely.
  //
  // .set({...}, SetOptions(merge: true)) → only updates the
  // fields you provide, keeps everything else untouched.

  static Future<void> saveProfile(Map<String, dynamic> data) async {
    if (_uid == null) return;

    // merge: true means "update only these fields, don't delete
    // other fields that already exist in the document"
    await _userDoc.set({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
      // FieldValue.serverTimestamp() is special — Firebase fills
      // this with the server's current time, not your phone's time.
      // This is important for accuracy across timezones.
    }, SetOptions(merge: true));
  }

  // HOW get() WORKS:
  // ─────────────────
  // .get() fetches the document ONCE from Firebase.
  // Returns a DocumentSnapshot — you call .data() to get the Map.
  // If the document doesn't exist, snapshot.exists == false.

  static Future<Map<String, dynamic>?> getProfile() async {
    if (_uid == null) return null;

    final snapshot = await _userDoc.get();

    // snapshot.exists tells you if this document has been created.
    // A new user won't have a profile document yet.
    if (!snapshot.exists) return null;

    // snapshot.data() returns Map<String, dynamic>? — the fields.
    return snapshot.data() as Map<String, dynamic>?;
  }

  // ═══════════════════════════════════════════════════════════════
  // MEDICATIONS
  // ═══════════════════════════════════════════════════════════════
  //
  // Medications are a SUB-COLLECTION under the user's document:
  //   users/{uid}/medications/{medicationId}
  //
  // WHY a sub-collection instead of a field?
  // → Because the user can have MANY medications.
  //   You can't put a list of 50 medications as a field —
  //   it becomes unmanageable. Sub-collections scale perfectly.
  //
  // HOW add() vs set() WORKS:
  // ──────────────────────────
  // .add({...})        → Firebase generates a random ID for you
  // .doc(id).set({})   → YOU provide the ID (use this when you
  //                       already have an ID like from your model)

  static CollectionReference get _medsCollection =>
      _userDoc.collection('medications');

  static Future<void> saveMedication(
      String id, Map<String, dynamic> data) async {
    if (_uid == null) return;

    // .doc(id) → use our own ID (from uuid package in your app)
    // .set()   → create or overwrite this medication document
    await _medsCollection.doc(id).set({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // HOW snapshots() WORKS (real-time stream):
  // ──────────────────────────────────────────
  // .snapshots() returns a Stream — it emits a new value
  // EVERY TIME the data changes in Firebase.
  //
  // This means if you add a medication on your phone,
  // it appears instantly on your tablet too — no refresh needed.
  // This is one of Firestore's most powerful features.
  //
  // In Flutter, you use StreamBuilder to listen to this stream.

  static Stream<QuerySnapshot> getMedicationsStream() {
    if (_uid == null) return const Stream.empty();

    // orderBy sorts by the field 'createdAt' in ascending order
    return _medsCollection.orderBy('createdAt', descending: false).snapshots();
  }

  // For a one-time fetch (not real-time):
  static Future<List<Map<String, dynamic>>> getMedications() async {
    if (_uid == null) return [];

    final snapshot = await _medsCollection
        .orderBy('createdAt', descending: false)
        .get();

    // .docs gives you a List of DocumentSnapshot
    // We map each one to its data Map
    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  static Future<void> deleteMedication(String id) async {
    if (_uid == null) return;
    // .delete() removes the document completely
    await _medsCollection.doc(id).delete();
  }

  static Future<void> updateMedicationStatus(
      String id, String status) async {
    if (_uid == null) return;

    // .update() only changes the fields you specify.
    // Unlike .set(merge:true), .update() FAILS if the doc
    // doesn't exist. Use it when you're sure the doc exists.
    await _medsCollection.doc(id).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // HABITS (stored per day)
  // ═══════════════════════════════════════════════════════════════
  //
  // Structure:
  //   users/{uid}/habits/2026-04-04  ← one document per day
  //
  // WHY store habits per day?
  // → Habits reset every day. Storing per-day lets you show
  //   history ("last Tuesday you completed 6/8 habits").
  //   The document ID IS the date string — simple and queryable.

  static CollectionReference get _habitsCollection =>
      _userDoc.collection('habits');

  static Future<void> saveHabitsForDay({
    required String dateKey,      // e.g. "2026-04-04"
    required List<String> completedIds,
    required int totalHabits,
    required int healthScore,
  }) async {
    if (_uid == null) return;

    // Using the date as the document ID is a common Firestore
    // pattern. It makes fetching a specific day's data trivial:
    // just .doc('2026-04-04').get()
    await _habitsCollection.doc(dateKey).set({
      'completedIds': completedIds,
      'totalHabits': totalHabits,
      'healthScore': healthScore,
      'dateKey': dateKey,
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<Map<String, dynamic>?> getHabitsForDay(
      String dateKey) async {
    if (_uid == null) return null;

    final snapshot = await _habitsCollection.doc(dateKey).get();
    if (!snapshot.exists) return null;
    return snapshot.data() as Map<String, dynamic>?;
  }

  // Get last 7 days of habit data for the health score chart
  static Future<List<Map<String, dynamic>>> getRecentHabits(
      int days) async {
    if (_uid == null) return [];

    // .orderBy + .limit is how you paginate in Firestore.
    // This fetches the most recent N days only — efficient.
    final snapshot = await _habitsCollection
        .orderBy('dateKey', descending: true)
        .limit(days)
        .get();

    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  // ═══════════════════════════════════════════════════════════════
  // CHECKUPS
  // ═══════════════════════════════════════════════════════════════

  static CollectionReference get _checkupsCollection =>
      _userDoc.collection('checkups');

  static Future<void> saveCheckup(
      String id, Map<String, dynamic> data) async {
    if (_uid == null) return;
    await _checkupsCollection.doc(id).set({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<List<Map<String, dynamic>>> getCheckups() async {
    if (_uid == null) return [];

    final snapshot = await _checkupsCollection.get();
    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  static Future<void> markCheckupDone(String id) async {
    if (_uid == null) return;
    await _checkupsCollection.doc(id).update({
      'lastDoneDate': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // CHAT HISTORY
  // ═══════════════════════════════════════════════════════════════
  //
  // Structure:
  //   users/{uid}/chatHistory/{messageId}
  //
  // Each message is its own document.
  // We use .add() here — Firebase auto-generates the message ID.

  static CollectionReference get _chatCollection =>
      _userDoc.collection('chatHistory');

  static Future<void> saveChatMessage({
    required String text,
    required bool isUser,         // true = user, false = GreenBot
  }) async {
    if (_uid == null) return;

    // .add() auto-generates a unique document ID.
    // Great for messages where you don't care about the ID.
    await _chatCollection.add({
      'text': text,
      'isUser': isUser,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Real-time stream of chat messages — newest last
  static Stream<QuerySnapshot> getChatStream() {
    if (_uid == null) return const Stream.empty();

    return _chatCollection
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // One-time fetch of all chat messages (for loading history on startup)
  static Future<List<Map<String, dynamic>>> getChatHistory() async {
    if (_uid == null) return [];
    final snapshot = await _chatCollection
        .orderBy('timestamp', descending: false)
        .get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  static Future<void> clearChatHistory() async {
    if (_uid == null) return;

    // Firestore doesn't have a "delete collection" method.
    // You must fetch all docs and delete each one individually.
    // This is a known Firestore pattern.
    final snapshot = await _chatCollection.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // INITIALIZE NEW USER
  // ═══════════════════════════════════════════════════════════════
  // Call this RIGHT AFTER signup — creates the user's document
  // in Firestore with basic info from their auth account.

  static Future<void> initializeNewUser({
    required String name,
    required String email,
  }) async {
    if (_uid == null) return;

    // Check if user document already exists (avoid overwriting)
    final existing = await _userDoc.get();
    if (existing.exists) return;

    await _userDoc.set({
      'uid': _uid,
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'profileComplete': false,
      // When you see this user's document in Firebase Console,
      // you'll see all these fields listed there.
    });
  }
}