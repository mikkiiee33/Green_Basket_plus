
// lib/screens/chatbot/chatbot_screen.dart
// GreenBot — Chat History Sidebar (like Claude / ChatGPT) + AI chat
// Drop-in replacement for your existing chatbot_screen.dart
 
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../../core/services/voice_service.dart';
// import '../../core/utils/browser_utils.dart';
 
// ─────────────────────────────────────────────────────────────────────────────
// DATA MODEL — Conversation session
// ─────────────────────────────────────────────────────────────────────────────
 
class ConversationSession {
  final String id;
  final String title;
  final DateTime timestamp;
  final List<ChatMessage> messages;
 
  ConversationSession({
    required this.id,
    required this.title,
    required this.timestamp,
    required this.messages,
  });
 
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'timestamp': timestamp.toIso8601String(),
    'messages': messages.map((m) => {
      'content': m.content,
      'isUser': m.isUser,
      'timestamp': m.timestamp.toIso8601String(),
    }).toList(),
  };
 
  factory ConversationSession.fromJson(Map<String, dynamic> json) =>
    ConversationSession(
      id: json['id'],
      title: json['title'],
      timestamp: DateTime.parse(json['timestamp']),
      messages: (json['messages'] as List).map((m) => ChatMessage(
        content: m['content'],
        isUser: m['isUser'],
      )).toList(),
    );
}
 
// ─────────────────────────────────────────────────────────────────────────────
// FIRESTORE HISTORY SERVICE
// ─────────────────────────────────────────────────────────────────────────────
 
class ChatHistoryService {
  static final _db   = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;
 
  static String? get _uid => _auth.currentUser?.uid;
 
  static CollectionReference? get _col {
    if (_uid == null) return null;
    return _db.collection('users').doc(_uid).collection('conversations');
  }
 
  // Save or update a conversation
  static Future<void> saveConversation(ConversationSession session) async {
    try {
      await _col?.doc(session.id).set(session.toJson());
    } catch (e) {
      debugPrint('[ChatHistoryService] Save error: $e');
    }
  }
 
  // Load all conversations ordered by newest first
  static Future<List<ConversationSession>> loadConversations() async {
    try {
      final snap = await _col
          ?.orderBy('timestamp', descending: true)
          .limit(50)
          .get();
      return snap?.docs
          .map((d) => ConversationSession.fromJson(d.data() as Map<String, dynamic>))
          .toList() ?? [];
    } catch (e) {
      debugPrint('[ChatHistoryService] Load error: $e');
      return [];
    }
  }
 
  // Delete a conversation
  static Future<void> deleteConversation(String id) async {
    try {
      await _col?.doc(id).delete();
    } catch (e) {
      debugPrint('[ChatHistoryService] Delete error: $e');
    }
  }
}
 
// ─────────────────────────────────────────────────────────────────────────────
// MAIN CHATBOT SCREEN
// ─────────────────────────────────────────────────────────────────────────────
 
class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});
 
  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}
 
class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _msgCtrl    = TextEditingController();
  final ScrollController       _scrollCtrl = ScrollController();
  final FocusNode              _focusNode  = FocusNode();
 
  // Sidebar state
  List<ConversationSession> _sessions = [];
  bool _sessionsLoading = true;
  String? _activeSessionId;
 
  // Current chat messages
  List<ChatMessage> _messages = [];
  bool _isTyping = false;
 
  // ── VOICE STATE ──────────────────────────────────────────────────────────
  final VoiceService _voice = VoiceService.instance;
  bool _isListening    = false;
  bool _isSpeaking     = false;
  bool _ttsEnabled     = false;
  String _liveTranscript = '';
 
  static const List<String> _quickSuggestions = [
    'I have a headache 🤕',
    'What should I eat today? 🥗',
    'Diabetes diet tips 🩸',
    'How to sleep better 😴',
    'I feel stressed 😰',
    'Water intake tips 💧',
    'Motivate me! 💪',
    'BP management tips 💓',
  ];
 
  @override
  void initState() {
    super.initState();
    _loadSessions();
    _startNewChat(silent: true);
    _voice.initSTT();
    _voice.initTTS();
  }
 
  @override
  void dispose() {
    _voice.stopListening();
    _voice.stopSpeaking();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }
 
  // ── SESSION MANAGEMENT ───────────────────────────────────────────────────
 
  Future<void> _loadSessions() async {
    setState(() => _sessionsLoading = true);
    final sessions = await ChatHistoryService.loadConversations();
    setState(() {
      _sessions = sessions;
      _sessionsLoading = false;
    });
  }
 
  void _startNewChat({bool silent = false}) {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    setState(() {
      _activeSessionId = newId;
      _messages = [
        ChatMessage(
          content: '👋 Hi! I\'m GreenBot, your AI wellness companion powered by Llama 3.\n\n'
              'I can help you with:\n'
              '• 🥗 Personalised meal suggestions\n'
              '• 💊 Medicine & nutrition advice\n'
              '• 🏃 Exercise & lifestyle tips\n'
              '• 🩺 Basic symptom guidance\n'
              '• 💪 Wellness motivation\n\n'
              'How can I help you today?',
          isUser: false,
        ),
      ];
      _isTyping = false;
    });
  }
 
  void _loadSession(ConversationSession session) {
    setState(() {
      _activeSessionId = session.id;
      _messages = List.from(session.messages);
      _isTyping = false;
    });
    _scrollToBottom();
  }
 
  Future<void> _deleteSession(String id) async {
    await ChatHistoryService.deleteConversation(id);
    setState(() => _sessions.removeWhere((s) => s.id == id));
    if (_activeSessionId == id) _startNewChat();
  }
 
  Future<void> _saveCurrentSession() async {
    if (_messages.length <= 1) return; // only welcome message — don't save
    final userMessages = _messages.where((m) => m.isUser).toList();
    if (userMessages.isEmpty) return;
 
    // Generate title from first user message
    final title = userMessages.first.content.length > 40
        ? '${userMessages.first.content.substring(0, 40)}...'
        : userMessages.first.content;
 
    final session = ConversationSession(
      id: _activeSessionId!,
      title: title,
      timestamp: DateTime.now(),
      messages: List.from(_messages),
    );
 
    await ChatHistoryService.saveConversation(session);
 
    // Update local list
    final idx = _sessions.indexWhere((s) => s.id == session.id);
    setState(() {
      if (idx >= 0) {
        _sessions[idx] = session;
      } else {
        _sessions.insert(0, session);
      }
    });
  }
 






// ── VOICE CONTROLS ───────────────────────────────────────────────────────

Future<void> _toggleListening() async {
  if (_isListening) {
    await _voice.stopListening();
    setState(() {
      _isListening = false;
      // Send whatever was transcribed
      if (_liveTranscript.trim().isNotEmpty) {
        final text = _liveTranscript.trim();
        _liveTranscript = '';
        _send(text);
      } else {
        _liveTranscript = '';
      }
    });
  } else {
    final ok = await _voice.initSTT();
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission denied')),
      );
      return;
    }
    setState(() { _isListening = true; _liveTranscript = ''; });
    await _voice.startListening(
      onResult: (text, isFinal) {
        setState(() => _liveTranscript = text);
        if (isFinal && text.trim().isNotEmpty) {
          setState(() { _isListening = false; _liveTranscript = ''; });
          _send(text.trim());
        }
      },
      onDone: () => setState(() { _isListening = false; }),
    );
  }
}













void _toggleTTS() {
  setState(() {
    _ttsEnabled = !_ttsEnabled;
    _voice.setTTSEnabled(_ttsEnabled);
  });
  if (!_ttsEnabled) _voice.stopSpeaking();
}








  // ── MESSAGING ────────────────────────────────────────────────────────────
 
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
 
  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    _msgCtrl.clear();
    _focusNode.unfocus();
 
    setState(() {
      _messages.add(ChatMessage(content: text.trim(), isUser: true));
      _isTyping = true;
    });
    _scrollToBottom();
 
    // Build history for Groq context
    final history = _messages
        .where((m) => !m.content.startsWith('👋 Hi! I\'m GreenBot'))
        .take(_messages.length - 1)
        .map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.content})
        .toList();
 
    final response = await context.read<ChatProvider>().sendMessageRaw(text.trim(), history: history);
 
    setState(() {
      _messages.add(ChatMessage(content: response, isUser: false));
      _isTyping = false;
    });
    _scrollToBottom();
 
    // Speak the response if TTS is enabled
    if (_ttsEnabled) {
      setState(() => _isSpeaking = true);
      await _voice.speak(response);
      if (mounted) setState(() => _isSpeaking = false);
    }
 
    // Auto-save after each exchange
    await _saveCurrentSession();
  }
 
  // ── BUILD ─────────────────────────────────────────────────────────────────
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // Drawer = history sidebar
      drawer: _buildSidebar(),
      appBar: _buildAppBar(),
      body: Column(children: [
        // Disclaimer
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: AppColors.warning.withValues(alpha: 0.08),
          child: Text(
            '⚠️ GreenBot provides general wellness information, not medical advice.',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.warning),
            textAlign: TextAlign.center,
          ),
        ),
 
        // Messages
        Expanded(child: _buildMessageList()),
 
        // Quick suggestions
        if (!_isTyping) _buildQuickSuggestions(),
 
        const SizedBox(height: 8),
 
        // Voice transcript overlay (shown while listening)
        _buildVoiceOverlay(),
 
        // Input row
        _buildInputRow(),
      ]),
    );
  }
 
  // ── APP BAR ──────────────────────────────────────────────────────────────
 
  AppBar _buildAppBar() {
    return AppBar(
      leading: Builder(builder: (ctx) => IconButton(
        icon: const Icon(Icons.menu_rounded),
        tooltip: 'Chat history',
        onPressed: () => Scaffold.of(ctx).openDrawer(),
      )),
      title: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent], begin: Alignment.topLeft, end: Alignment.bottomRight),
            shape: BoxShape.circle,
          ),
          child: const Center(child: Text('🤖', style: TextStyle(fontSize: 18))),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('GreenBot', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          Text(
            _isTyping ? 'typing...' : 'Wellness AI',
            style: TextStyle(
              fontSize: 11,
              color: _isTyping ? AppColors.accent : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ]),
      ]),
      actions: [
        // New chat button
        IconButton(
          icon: const Icon(Icons.add_comment_outlined),
          tooltip: 'New chat',
          onPressed: _startNewChat,
          color: AppColors.primary,
        ),
        // Clear current chat
        IconButton(
          icon: const Icon(Icons.delete_sweep_outlined),
          tooltip: 'Clear chat',
          onPressed: () => showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Clear Chat'),
              content: const Text('Clear current conversation?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () { _startNewChat(); Navigator.pop(context); },
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
          color: AppColors.textSecondary,
        ),
      ],
    );
  }
 
  // ── SIDEBAR ──────────────────────────────────────────────────────────────
 
  Widget _buildSidebar() {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(child: Column(children: [
 
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            const Text('💬', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(child: Text('Chat History',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary))),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 20),
              onPressed: _loadSessions,
              color: AppColors.textSecondary,
            ),
          ]),
        ),
 
        // New chat button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _startNewChat,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
 
        const SizedBox(height: 12),
        const Divider(),
 
        // Sessions list
        Expanded(child: _sessionsLoading
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('💬', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 8),
                Text('No conversations yet', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text('Start chatting with GreenBot!', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
              ]))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: _sessions.length,
                itemBuilder: (ctx, i) {
                  final s = _sessions[i];
                  final isActive = s.id == _activeSessionId;
                  return _SessionTile(
                    session: s,
                    isActive: isActive,
                    onTap: () => _loadSession(s),
                    onDelete: () => _deleteSession(s.id),
                  );
                },
              ),
        ),
 
        const Divider(),
 
        // Footer
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            'Conversations saved securely on cloud',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
      ])),
    );
  }
 
  // ── MESSAGE LIST ─────────────────────────────────────────────────────────
 
  Widget _buildMessageList() {
    final items = _buildItems(_messages, _isTyping);
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        if (item is String) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(item, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
              ),
              const Expanded(child: Divider()),
            ]),
          );
        }
        if (item == 'typing') return _TypingIndicator();
        return _ChatBubble(message: item as ChatMessage);
      },
    );
  }
 
  // ── QUICK SUGGESTIONS ────────────────────────────────────────────────────
 
  Widget _buildQuickSuggestions() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _quickSuggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) => GestureDetector(
          onTap: () => _send(_quickSuggestions[i]),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryLighter.withValues(alpha: 0.5)),
            ),
            child: Text(_quickSuggestions[i],
              style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
 
  // ── INPUT ROW ─────────────────────────────────────────────────────────────
 
 
  Widget _buildVoiceOverlay() {
    if (!_isListening && _liveTranscript.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.primarySurface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(children: [
        _isListening
            ? _PulseDot()
            : const Icon(Icons.mic_off, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _liveTranscript.isEmpty ? 'Listening…' : _liveTranscript,
            style: TextStyle(
              fontSize: 13,
              color: _liveTranscript.isEmpty ? AppColors.textSecondary : AppColors.textPrimary,
              fontStyle: _liveTranscript.isEmpty ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
        if (_liveTranscript.isNotEmpty)
          GestureDetector(
            onTap: () async {
              await _voice.cancelListening();
              setState(() { _isListening = false; _liveTranscript = ''; });
            },
            child: const Icon(Icons.close, size: 16, color: AppColors.textSecondary),
          ),
      ]),
    );
  }
 
  Widget _buildInputRow() {
    return Container(
      padding: EdgeInsets.only(
        left: 16, right: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        top: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        border: const Border(top: BorderSide(color: AppColors.divider)),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: Row(children: [
        // Mic
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(12)),
          child: GestureDetector(
            onTap: _toggleListening,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: _isListening ? AppColors.error : AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: _isListening
                    ? [BoxShadow(color: AppColors.error.withValues(alpha: 0.35), blurRadius: 8, spreadRadius: 1)]
                    : [],
              ),
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_outlined,
                color: _isListening ? Colors.white : AppColors.primary,
                size: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (event) {
              if (event is KeyDownEvent) {
                final isEnter = event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.numpadEnter;
                if (isEnter && !HardwareKeyboard.instance.isShiftPressed) _send(_msgCtrl.text);
              }
            },
            child: TextField(
              controller: _msgCtrl,
              focusNode: _focusNode,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3, minLines: 1,
              decoration: InputDecoration(
                hintText: 'Ask GreenBot anything...',
                filled: true, fillColor: AppColors.primarySurface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                isDense: true,
              ),
              onSubmitted: _send,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Speaker
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(12)),
          child: GestureDetector(
            onTap: _toggleTTS,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: _ttsEnabled ? AppColors.primarySurface : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _ttsEnabled ? AppColors.primary : AppColors.divider,
                ),
              ),
              child: Icon(
                _isSpeaking
                    ? Icons.volume_up
                    : (_ttsEnabled ? Icons.volume_up_outlined : Icons.volume_off_outlined),
                color: _ttsEnabled ? AppColors.primary : AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        // Send
        Container(
          width: 44, height: 44,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent], begin: Alignment.topLeft, end: Alignment.bottomRight),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            onPressed: () => _send(_msgCtrl.text),
          ),
        ),
      ]),
    );
  }
}
 
// ─────────────────────────────────────────────────────────────────────────────
// SESSION TILE (sidebar item)
// ─────────────────────────────────────────────────────────────────────────────
 
class _SessionTile extends StatelessWidget {
  final ConversationSession session;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _SessionTile({required this.session, required this.isActive, required this.onTap, required this.onDelete});
 
  String _timeLabel(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60)  return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)    return '${diff.inHours}h ago';
    if (diff.inDays == 1)     return 'Yesterday';
    if (diff.inDays < 7)      return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
 
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primarySurface : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: isActive ? Border.all(color: AppColors.primaryLighter.withValues(alpha: 0.5)) : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.primarySurface,
            shape: BoxShape.circle,
          ),
          child: Center(child: Text('💬', style: TextStyle(fontSize: isActive ? 14 : 12))),
        ),
        title: Text(
          session.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          _timeLabel(session.timestamp),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 16),
          color: AppColors.textSecondary,
          onPressed: () => showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Delete conversation?'),
              content: Text('Delete "${session.title}"?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () { Navigator.pop(context); onDelete(); },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                  child: const Text('Delete', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
 
// ─────────────────────────────────────────────────────────────────────────────
// HELPER — build items list with date separators
// ─────────────────────────────────────────────────────────────────────────────
 
List<dynamic> _buildItems(List<ChatMessage> messages, bool isTyping) {
  final items = <dynamic>[];
  String? lastDate;
  for (final msg in messages) {
    final dateLabel = _formatDateLabel(msg.timestamp);
    if (dateLabel != lastDate) { items.add(dateLabel); lastDate = dateLabel; }
    items.add(msg);
  }
  if (isTyping) items.add('typing');
  return items;
}
 
String _formatDateLabel(DateTime dt) {
  final now   = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final diff  = today.difference(DateTime(dt.year, dt.month, dt.day)).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  if (diff < 7)  return ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'][dt.weekday - 1];
  return '${dt.day}/${dt.month}/${dt.year}';
}
 
// ─────────────────────────────────────────────────────────────────────────────
// CHAT BUBBLE
// ─────────────────────────────────────────────────────────────────────────────
 
class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const _ChatBubble({required this.message});
 
  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32, height: 32,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent], begin: Alignment.topLeft, end: Alignment.bottomRight),
                shape: BoxShape.circle,
              ),
              child: const Center(child: Text('🤖', style: TextStyle(fontSize: 14))),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : AppColors.cardBg,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18), topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: isUser ? null : Border.all(color: AppColors.divider),
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Text(message.content,
                style: TextStyle(fontSize: 14, color: isUser ? Colors.white : AppColors.textPrimary, height: 1.5)),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32, height: 32,
              decoration: const BoxDecoration(color: AppColors.primarySurface, shape: BoxShape.circle),
              child: const Center(child: Text('👤', style: TextStyle(fontSize: 14))),
            ),
          ],
        ],
      ),
    );
  }
}
 
// ─────────────────────────────────────────────────────────────────────────────
// TYPING INDICATOR
// ─────────────────────────────────────────────────────────────────────────────
 
class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}
 
class _TypingIndicatorState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
 
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }
 
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
 
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Container(
          width: 32, height: 32,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]),
            shape: BoxShape.circle,
          ),
          child: const Center(child: Text('🤖', style: TextStyle(fontSize: 14))),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18), bottomRight: Radius.circular(18), bottomLeft: Radius.circular(4)),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) {
            return AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) {
                final val = ((_ctrl.value - i * 0.2) % 1.0);
                final bounce = val < 0.5 ? val * 2 : (1 - val) * 2;
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 2, vertical: 4 - bounce * 4),
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.4 + bounce * 0.6),
                    shape: BoxShape.circle,
                  ),
                );
              },
            );
          })),
        ),
      ]),
    );
  }
}
 
// ─────────────────────────────────────────────────────────────────────────────
// PULSE DOT — animated recording indicator
// ─────────────────────────────────────────────────────────────────────────────
 
class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}
 
class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
 
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }
 
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
 
  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _anim,
    child: Container(
      width: 8, height: 8,
      decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
    ),
  );
}
 






















































































// // lib/screens/chatbot/chatbot_screen.dart
// // GreenBot — Chat History Sidebar (like Claude / ChatGPT) + AI chat
// // Drop-in replacement for your existing chatbot_screen.dart
 
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../../core/theme/app_theme.dart';
// import '../../providers/app_provider.dart';
// import '../../models/models.dart';
// import '../../core/services/voice_service.dart';
// import '../../core/utils/browser_utils.dart';
 
// // ─────────────────────────────────────────────────────────────────────────────
// // DATA MODEL — Conversation session
// // ─────────────────────────────────────────────────────────────────────────────
 
// class ConversationSession {
//   final String id;
//   final String title;
//   final DateTime timestamp;
//   final List<ChatMessage> messages;
 
//   ConversationSession({
//     required this.id,
//     required this.title,
//     required this.timestamp,
//     required this.messages,
//   });
 
//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'title': title,
//     'timestamp': timestamp.toIso8601String(),
//     'messages': messages.map((m) => {
//       'content': m.content,
//       'isUser': m.isUser,
//       'timestamp': m.timestamp.toIso8601String(),
//     }).toList(),
//   };
 
//   factory ConversationSession.fromJson(Map<String, dynamic> json) =>
//     ConversationSession(
//       id: json['id'],
//       title: json['title'],
//       timestamp: DateTime.parse(json['timestamp']),
//       messages: (json['messages'] as List).map((m) => ChatMessage(
//         content: m['content'],
//         isUser: m['isUser'],
//       )).toList(),
//     );
// }
 
// // ─────────────────────────────────────────────────────────────────────────────
// // FIRESTORE HISTORY SERVICE
// // ─────────────────────────────────────────────────────────────────────────────
 
// class ChatHistoryService {
//   static final _db   = FirebaseFirestore.instance;
//   static final _auth = FirebaseAuth.instance;
 
//   static String? get _uid => _auth.currentUser?.uid;
 
//   static CollectionReference? get _col {
//     if (_uid == null) return null;
//     return _db.collection('users').doc(_uid).collection('conversations');
//   }
 
//   // Save or update a conversation
//   static Future<void> saveConversation(ConversationSession session) async {
//     try {
//       await _col?.doc(session.id).set(session.toJson());
//     } catch (e) {
//       debugPrint('[ChatHistoryService] Save error: $e');
//     }
//   }
 
//   // Load all conversations ordered by newest first
//   static Future<List<ConversationSession>> loadConversations() async {
//     try {
//       final snap = await _col
//           ?.orderBy('timestamp', descending: true)
//           .limit(50)
//           .get();
//       return snap?.docs
//           .map((d) => ConversationSession.fromJson(d.data() as Map<String, dynamic>))
//           .toList() ?? [];
//     } catch (e) {
//       debugPrint('[ChatHistoryService] Load error: $e');
//       return [];
//     }
//   }
 
//   // Delete a conversation
//   static Future<void> deleteConversation(String id) async {
//     try {
//       await _col?.doc(id).delete();
//     } catch (e) {
//       debugPrint('[ChatHistoryService] Delete error: $e');
//     }
//   }
// }
 
// // ─────────────────────────────────────────────────────────────────────────────
// // MAIN CHATBOT SCREEN
// // ─────────────────────────────────────────────────────────────────────────────
 
// class ChatbotScreen extends StatefulWidget {
//   const ChatbotScreen({super.key});
 
//   @override
//   State<ChatbotScreen> createState() => _ChatbotScreenState();
// }
 
// class _ChatbotScreenState extends State<ChatbotScreen> {
//   final TextEditingController _msgCtrl    = TextEditingController();
//   final ScrollController       _scrollCtrl = ScrollController();
//   final FocusNode              _focusNode  = FocusNode();
 
//   // Sidebar state
//   List<ConversationSession> _sessions = [];
//   bool _sessionsLoading = true;
//   String? _activeSessionId;
 
//   // Current chat messages
//   List<ChatMessage> _messages = [];
//   bool _isTyping = false;
 
//   // ── VOICE STATE ──────────────────────────────────────────────────────────
//   final VoiceService _voice = VoiceService.instance;
//   bool _isListening    = false;
//   bool _isSpeaking     = false;
//   bool _ttsEnabled     = false;
//   String _liveTranscript = '';
 
//   static const List<String> _quickSuggestions = [
//     'I have a headache 🤕',
//     'What should I eat today? 🥗',
//     'Diabetes diet tips 🩸',
//     'How to sleep better 😴',
//     'I feel stressed 😰',
//     'Water intake tips 💧',
//     'Motivate me! 💪',
//     'BP management tips 💓',
//   ];
 
//   @override
//   void initState() {
//     super.initState();
//     _loadSessions();
//     _startNewChat(silent: true);
//     _voice.initSTT();
//     _voice.initTTS();
//   }
 
//   @override
//   void dispose() {
//     _voice.stopListening();
//     _voice.stopSpeaking();
//     _msgCtrl.dispose();
//     _scrollCtrl.dispose();
//     _focusNode.dispose();
//     super.dispose();
//   }
 
//   // ── SESSION MANAGEMENT ───────────────────────────────────────────────────
 
//   Future<void> _loadSessions() async {
//     setState(() => _sessionsLoading = true);
//     final sessions = await ChatHistoryService.loadConversations();
//     setState(() {
//       _sessions = sessions;
//       _sessionsLoading = false;
//     });
//   }
 
//   void _startNewChat({bool silent = false}) {
//     final newId = DateTime.now().millisecondsSinceEpoch.toString();
//     setState(() {
//       _activeSessionId = newId;
//       _messages = [
//         ChatMessage(
//           content: '👋 Hi! I\'m GreenBot, your AI wellness companion powered by Llama 3.\n\n'
//               'I can help you with:\n'
//               '• 🥗 Personalised meal suggestions\n'
//               '• 💊 Medicine & nutrition advice\n'
//               '• 🏃 Exercise & lifestyle tips\n'
//               '• 🩺 Basic symptom guidance\n'
//               '• 💪 Wellness motivation\n\n'
//               'How can I help you today?',
//           isUser: false,
//         ),
//       ];
//       _isTyping = false;
//     });
//   }
 
//   void _loadSession(ConversationSession session) {
//     setState(() {
//       _activeSessionId = session.id;
//       _messages = List.from(session.messages);
//       _isTyping = false;
//     });
//     _scrollToBottom();
//   }
 
//   Future<void> _deleteSession(String id) async {
//     await ChatHistoryService.deleteConversation(id);
//     setState(() => _sessions.removeWhere((s) => s.id == id));
//     if (_activeSessionId == id) _startNewChat();
//   }
 
//   Future<void> _saveCurrentSession() async {
//     if (_messages.length <= 1) return; // only welcome message — don't save
//     final userMessages = _messages.where((m) => m.isUser).toList();
//     if (userMessages.isEmpty) return;
 
//     // Generate title from first user message
//     final title = userMessages.first.content.length > 40
//         ? '${userMessages.first.content.substring(0, 40)}...'
//         : userMessages.first.content;
 
//     final session = ConversationSession(
//       id: _activeSessionId!,
//       title: title,
//       timestamp: DateTime.now(),
//       messages: List.from(_messages),
//     );
 
//     await ChatHistoryService.saveConversation(session);
 
//     // Update local list
//     final idx = _sessions.indexWhere((s) => s.id == session.id);
//     setState(() {
//       if (idx >= 0) {
//         _sessions[idx] = session;
//       } else {
//         _sessions.insert(0, session);
//       }
//     });
//   }
 
 
 
 
 
 
 
// // ── VOICE CONTROLS ───────────────────────────────────────────────────────
 
// Future<void> _toggleListening() async {
//   // Block on Edge and unsupported browsers
//   if (kIsWeb && !BrowserUtils.speechSupported) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Row(children: [
//           Text('⚠️ ', style: TextStyle(fontSize: 20)),
//           Text('Browser Not Supported'),
//         ]),
//         content: const Text(
//           'Voice input only works on Google Chrome.\n\nPlease open this app in Chrome to use the microphone.',
//         ),
//         actions: [
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//     return;
//   }
 
//   if (_isListening) {
//     await _voice.stopListening();
//     setState(() {
//       _isListening = false;
//       // Send whatever was transcribed
//       if (_liveTranscript.trim().isNotEmpty) {
//         final text = _liveTranscript.trim();
//         _liveTranscript = '';
//         _send(text);
//       } else {
//         _liveTranscript = '';
//       }
//     });
//   } else {
//     final ok = await _voice.initSTT();
//     if (!ok) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Microphone permission denied')),
//       );
//       return;
//     }
//     setState(() { _isListening = true; _liveTranscript = ''; });
//     await _voice.startListening(
//       onResult: (text, isFinal) {
//         setState(() => _liveTranscript = text);
//         if (isFinal && text.trim().isNotEmpty) {
//           setState(() { _isListening = false; _liveTranscript = ''; });
//           _send(text.trim());
//         }
//       },
//       onDone: () => setState(() { _isListening = false; }),
//     );
//   }
// }
 
 
 
 
 
 
 
 
 
 
 
 
 
// void _toggleTTS() {
//   setState(() {
//     _ttsEnabled = !_ttsEnabled;
//     _voice.setTTSEnabled(_ttsEnabled);
//   });
//   if (!_ttsEnabled) _voice.stopSpeaking();
// }
 
 
 
 
 
 
 
 
//   // ── MESSAGING ────────────────────────────────────────────────────────────
 
//   void _scrollToBottom() {
//     Future.delayed(const Duration(milliseconds: 100), () {
//       if (_scrollCtrl.hasClients) {
//         _scrollCtrl.animateTo(
//           _scrollCtrl.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }
 
//   Future<void> _send(String text) async {
//     if (text.trim().isEmpty) return;
//     _msgCtrl.clear();
//     _focusNode.unfocus();
 
//     setState(() {
//       _messages.add(ChatMessage(content: text.trim(), isUser: true));
//       _isTyping = true;
//     });
//     _scrollToBottom();
 
//     // Build history for Groq context
//     final history = _messages
//         .where((m) => !m.content.startsWith('👋 Hi! I\'m GreenBot'))
//         .take(_messages.length - 1)
//         .map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.content})
//         .toList();
 
//     final response = await context.read<ChatProvider>().sendMessageRaw(text.trim(), history: history);
 
//     setState(() {
//       _messages.add(ChatMessage(content: response, isUser: false));
//       _isTyping = false;
//     });
//     _scrollToBottom();
 
//     // Speak the response if TTS is enabled
//     if (_ttsEnabled) {
//       setState(() => _isSpeaking = true);
//       await _voice.speak(response);
//       if (mounted) setState(() => _isSpeaking = false);
//     }
 
//     // Auto-save after each exchange
//     await _saveCurrentSession();
//   }
 
//   // ── BUILD ─────────────────────────────────────────────────────────────────
 
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       // Drawer = history sidebar
//       drawer: _buildSidebar(),
//       appBar: _buildAppBar(),
//       body: Column(children: [
//         // Disclaimer
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           color: AppColors.warning.withValues(alpha: 0.08),
//           child: Text(
//             '⚠️ GreenBot provides general wellness information, not medical advice.',
//             style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.warning),
//             textAlign: TextAlign.center,
//           ),
//         ),
 
//         // Chrome-only voice banner for unsupported browsers
//         if (kIsWeb && !BrowserUtils.speechSupported)
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
//             color: Colors.orange.withValues(alpha: 0.12),
//             child: const Text(
//               '🎤 Voice input requires Google Chrome — not supported in this browser',
//               style: TextStyle(fontSize: 11, color: Colors.orange),
//               textAlign: TextAlign.center,
//             ),
//           ),
 
//         // Messages
//         Expanded(child: _buildMessageList()),
 
//         // Quick suggestions
//         if (!_isTyping) _buildQuickSuggestions(),
 
//         const SizedBox(height: 8),
 
//         // Voice transcript overlay (shown while listening)
//         _buildVoiceOverlay(),
 
//         // Input row
//         _buildInputRow(),
//       ]),
//     );
//   }
 
//   // ── APP BAR ──────────────────────────────────────────────────────────────
 
//   AppBar _buildAppBar() {
//     return AppBar(
//       leading: Builder(builder: (ctx) => IconButton(
//         icon: const Icon(Icons.menu_rounded),
//         tooltip: 'Chat history',
//         onPressed: () => Scaffold.of(ctx).openDrawer(),
//       )),
//       title: Row(children: [
//         Container(
//           width: 36, height: 36,
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent], begin: Alignment.topLeft, end: Alignment.bottomRight),
//             shape: BoxShape.circle,
//           ),
//           child: const Center(child: Text('🤖', style: TextStyle(fontSize: 18))),
//         ),
//         const SizedBox(width: 10),
//         Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           const Text('GreenBot', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
//           Text(
//             _isTyping ? 'typing...' : 'Wellness AI',
//             style: TextStyle(
//               fontSize: 11,
//               color: _isTyping ? AppColors.accent : AppColors.textSecondary,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ]),
//       ]),
//       actions: [
//         // New chat button
//         IconButton(
//           icon: const Icon(Icons.add_comment_outlined),
//           tooltip: 'New chat',
//           onPressed: _startNewChat,
//           color: AppColors.primary,
//         ),
//         // Clear current chat
//         IconButton(
//           icon: const Icon(Icons.delete_sweep_outlined),
//           tooltip: 'Clear chat',
//           onPressed: () => showDialog(
//             context: context,
//             builder: (_) => AlertDialog(
//               title: const Text('Clear Chat'),
//               content: const Text('Clear current conversation?'),
//               actions: [
//                 TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
//                 ElevatedButton(
//                   onPressed: () { _startNewChat(); Navigator.pop(context); },
//                   child: const Text('Clear'),
//                 ),
//               ],
//             ),
//           ),
//           color: AppColors.textSecondary,
//         ),
//       ],
//     );
//   }
 
//   // ── SIDEBAR ──────────────────────────────────────────────────────────────
 
//   Widget _buildSidebar() {
//     return Drawer(
//       backgroundColor: AppColors.background,
//       child: SafeArea(child: Column(children: [
 
//         // Header
//         Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(children: [
//             const Text('💬', style: TextStyle(fontSize: 20)),
//             const SizedBox(width: 10),
//             Expanded(child: Text('Chat History',
//               style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary))),
//             IconButton(
//               icon: const Icon(Icons.refresh_rounded, size: 20),
//               onPressed: _loadSessions,
//               color: AppColors.textSecondary,
//             ),
//           ]),
//         ),
 
//         // New chat button
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: SizedBox(
//             width: double.infinity,
//             child: ElevatedButton.icon(
//               onPressed: _startNewChat,
//               icon: const Icon(Icons.add, size: 18),
//               label: const Text('New Chat'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primary,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 10),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               ),
//             ),
//           ),
//         ),
 
//         const SizedBox(height: 12),
//         const Divider(),
 
//         // Sessions list
//         Expanded(child: _sessionsLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _sessions.isEmpty
//             ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
//                 const Text('💬', style: TextStyle(fontSize: 40)),
//                 const SizedBox(height: 8),
//                 Text('No conversations yet', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
//                 const SizedBox(height: 4),
//                 Text('Start chatting with GreenBot!', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
//               ]))
//             : ListView.builder(
//                 padding: const EdgeInsets.symmetric(horizontal: 8),
//                 itemCount: _sessions.length,
//                 itemBuilder: (ctx, i) {
//                   final s = _sessions[i];
//                   final isActive = s.id == _activeSessionId;
//                   return _SessionTile(
//                     session: s,
//                     isActive: isActive,
//                     onTap: () => _loadSession(s),
//                     onDelete: () => _deleteSession(s.id),
//                   );
//                 },
//               ),
//         ),
 
//         const Divider(),
 
//         // Footer
//         Padding(
//           padding: const EdgeInsets.all(12),
//           child: Text(
//             'Conversations saved securely on cloud',
//             style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
//             textAlign: TextAlign.center,
//           ),
//         ),
//       ])),
//     );
//   }
 
//   // ── MESSAGE LIST ─────────────────────────────────────────────────────────
 
//   Widget _buildMessageList() {
//     final items = _buildItems(_messages, _isTyping);
//     return ListView.builder(
//       controller: _scrollCtrl,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       itemCount: items.length,
//       itemBuilder: (context, index) {
//         final item = items[index];
//         if (item is String) {
//           return Padding(
//             padding: const EdgeInsets.symmetric(vertical: 16),
//             child: Row(children: [
//               const Expanded(child: Divider()),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 12),
//                 child: Text(item, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
//               ),
//               const Expanded(child: Divider()),
//             ]),
//           );
//         }
//         if (item == 'typing') return _TypingIndicator();
//         return _ChatBubble(message: item as ChatMessage);
//       },
//     );
//   }
 
//   // ── QUICK SUGGESTIONS ────────────────────────────────────────────────────
 
//   Widget _buildQuickSuggestions() {
//     return SizedBox(
//       height: 48,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         itemCount: _quickSuggestions.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 8),
//         itemBuilder: (context, i) => GestureDetector(
//           onTap: () => _send(_quickSuggestions[i]),
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             decoration: BoxDecoration(
//               color: AppColors.primarySurface,
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: AppColors.primaryLighter.withValues(alpha: 0.5)),
//             ),
//             child: Text(_quickSuggestions[i],
//               style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
//           ),
//         ),
//       ),
//     );
//   }
 
//   // ── INPUT ROW ─────────────────────────────────────────────────────────────
 
 
//   Widget _buildVoiceOverlay() {
//     if (!_isListening && _liveTranscript.isEmpty) return const SizedBox.shrink();
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       decoration: const BoxDecoration(
//         color: AppColors.primarySurface,
//         border: Border(top: BorderSide(color: AppColors.divider)),
//       ),
//       child: Row(children: [
//         _isListening
//             ? _PulseDot()
//             : const Icon(Icons.mic_off, size: 14, color: AppColors.textSecondary),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Text(
//             _liveTranscript.isEmpty ? 'Listening…' : _liveTranscript,
//             style: TextStyle(
//               fontSize: 13,
//               color: _liveTranscript.isEmpty ? AppColors.textSecondary : AppColors.textPrimary,
//               fontStyle: _liveTranscript.isEmpty ? FontStyle.italic : FontStyle.normal,
//             ),
//           ),
//         ),
//         if (_liveTranscript.isNotEmpty)
//           GestureDetector(
//             onTap: () async {
//               await _voice.cancelListening();
//               setState(() { _isListening = false; _liveTranscript = ''; });
//             },
//             child: const Icon(Icons.close, size: 16, color: AppColors.textSecondary),
//           ),
//       ]),
//     );
//   }
 
//   Widget _buildInputRow() {
//     return Container(
//       padding: EdgeInsets.only(
//         left: 16, right: 8,
//         bottom: MediaQuery.of(context).viewInsets.bottom + 12,
//         top: 8,
//       ),
//       decoration: BoxDecoration(
//         color: AppColors.cardBg,
//         border: const Border(top: BorderSide(color: AppColors.divider)),
//         boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, -2))],
//       ),
//       child: Row(children: [
//         // Mic
//         Container(
//           width: 44, height: 44,
//           decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(12)),
//           child: GestureDetector(
//             onTap: _toggleListening,
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               width: 44, height: 44,
//               decoration: BoxDecoration(
//                 color: _isListening ? AppColors.error : AppColors.primarySurface,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: _isListening
//                     ? [BoxShadow(color: AppColors.error.withValues(alpha: 0.35), blurRadius: 8, spreadRadius: 1)]
//                     : [],
//               ),
//               child: Icon(
//                 _isListening ? Icons.mic : Icons.mic_outlined,
//                 color: _isListening ? Colors.white : AppColors.primary,
//                 size: 20,
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: KeyboardListener(
//             focusNode: FocusNode(),
//             onKeyEvent: (event) {
//               if (event is KeyDownEvent) {
//                 final isEnter = event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.numpadEnter;
//                 if (isEnter && !HardwareKeyboard.instance.isShiftPressed) _send(_msgCtrl.text);
//               }
//             },
//             child: TextField(
//               controller: _msgCtrl,
//               focusNode: _focusNode,
//               textCapitalization: TextCapitalization.sentences,
//               maxLines: 3, minLines: 1,
//               decoration: InputDecoration(
//                 hintText: 'Ask GreenBot anything...',
//                 filled: true, fillColor: AppColors.primarySurface,
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                 isDense: true,
//               ),
//               onSubmitted: _send,
//             ),
//           ),
//         ),
//         const SizedBox(width: 8),
//         // Speaker
//         Container(
//           width: 44, height: 44,
//           decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(12)),
//           child: GestureDetector(
//             onTap: _toggleTTS,
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               width: 44, height: 44,
//               decoration: BoxDecoration(
//                 color: _ttsEnabled ? AppColors.primarySurface : AppColors.surface,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: _ttsEnabled ? AppColors.primary : AppColors.divider,
//                 ),
//               ),
//               child: Icon(
//                 _isSpeaking
//                     ? Icons.volume_up
//                     : (_ttsEnabled ? Icons.volume_up_outlined : Icons.volume_off_outlined),
//                 color: _ttsEnabled ? AppColors.primary : AppColors.textSecondary,
//                 size: 20,
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(width: 4),
//         // Send
//         Container(
//           width: 44, height: 44,
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent], begin: Alignment.topLeft, end: Alignment.bottomRight),
//             shape: BoxShape.circle,
//           ),
//           child: IconButton(
//             icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
//             onPressed: () => _send(_msgCtrl.text),
//           ),
//         ),
//       ]),
//     );
//   }
// }
 
// // ─────────────────────────────────────────────────────────────────────────────
// // SESSION TILE (sidebar item)
// // ─────────────────────────────────────────────────────────────────────────────
 
// class _SessionTile extends StatelessWidget {
//   final ConversationSession session;
//   final bool isActive;
//   final VoidCallback onTap;
//   final VoidCallback onDelete;
//   const _SessionTile({required this.session, required this.isActive, required this.onTap, required this.onDelete});
 
//   String _timeLabel(DateTime dt) {
//     final now = DateTime.now();
//     final diff = now.difference(dt);
//     if (diff.inMinutes < 60)  return '${diff.inMinutes}m ago';
//     if (diff.inHours < 24)    return '${diff.inHours}h ago';
//     if (diff.inDays == 1)     return 'Yesterday';
//     if (diff.inDays < 7)      return '${diff.inDays}d ago';
//     return '${dt.day}/${dt.month}/${dt.year}';
//   }
 
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 4),
//       decoration: BoxDecoration(
//         color: isActive ? AppColors.primarySurface : Colors.transparent,
//         borderRadius: BorderRadius.circular(10),
//         border: isActive ? Border.all(color: AppColors.primaryLighter.withValues(alpha: 0.5)) : null,
//       ),
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
//         leading: Container(
//           width: 32, height: 32,
//           decoration: BoxDecoration(
//             color: isActive ? AppColors.primary : AppColors.primarySurface,
//             shape: BoxShape.circle,
//           ),
//           child: Center(child: Text('💬', style: TextStyle(fontSize: isActive ? 14 : 12))),
//         ),
//         title: Text(
//           session.title,
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//             fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
//             color: isActive ? AppColors.primary : AppColors.textPrimary,
//           ),
//         ),
//         subtitle: Text(
//           _timeLabel(session.timestamp),
//           style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
//         ),
//         trailing: IconButton(
//           icon: const Icon(Icons.delete_outline, size: 16),
//           color: AppColors.textSecondary,
//           onPressed: () => showDialog(
//             context: context,
//             builder: (_) => AlertDialog(
//               title: const Text('Delete conversation?'),
//               content: Text('Delete "${session.title}"?'),
//               actions: [
//                 TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
//                 ElevatedButton(
//                   onPressed: () { Navigator.pop(context); onDelete(); },
//                   style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
//                   child: const Text('Delete', style: TextStyle(color: Colors.white)),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         onTap: onTap,
//       ),
//     );
//   }
// }
 
// // ─────────────────────────────────────────────────────────────────────────────
// // HELPER — build items list with date separators
// // ─────────────────────────────────────────────────────────────────────────────
 
// List<dynamic> _buildItems(List<ChatMessage> messages, bool isTyping) {
//   final items = <dynamic>[];
//   String? lastDate;
//   for (final msg in messages) {
//     final dateLabel = _formatDateLabel(msg.timestamp);
//     if (dateLabel != lastDate) { items.add(dateLabel); lastDate = dateLabel; }
//     items.add(msg);
//   }
//   if (isTyping) items.add('typing');
//   return items;
// }
 
// String _formatDateLabel(DateTime dt) {
//   final now   = DateTime.now();
//   final today = DateTime(now.year, now.month, now.day);
//   final diff  = today.difference(DateTime(dt.year, dt.month, dt.day)).inDays;
//   if (diff == 0) return 'Today';
//   if (diff == 1) return 'Yesterday';
//   if (diff < 7)  return ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'][dt.weekday - 1];
//   return '${dt.day}/${dt.month}/${dt.year}';
// }
 
// // ─────────────────────────────────────────────────────────────────────────────
// // CHAT BUBBLE
// // ─────────────────────────────────────────────────────────────────────────────
 
// class _ChatBubble extends StatelessWidget {
//   final ChatMessage message;
//   const _ChatBubble({required this.message});
 
//   @override
//   Widget build(BuildContext context) {
//     final isUser = message.isUser;
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           if (!isUser) ...[
//             Container(
//               width: 32, height: 32,
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent], begin: Alignment.topLeft, end: Alignment.bottomRight),
//                 shape: BoxShape.circle,
//               ),
//               child: const Center(child: Text('🤖', style: TextStyle(fontSize: 14))),
//             ),
//             const SizedBox(width: 8),
//           ],
//           Flexible(
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//               decoration: BoxDecoration(
//                 color: isUser ? AppColors.primary : AppColors.cardBg,
//                 borderRadius: BorderRadius.only(
//                   topLeft: const Radius.circular(18), topRight: const Radius.circular(18),
//                   bottomLeft: Radius.circular(isUser ? 18 : 4),
//                   bottomRight: Radius.circular(isUser ? 4 : 18),
//                 ),
//                 border: isUser ? null : Border.all(color: AppColors.divider),
//                 boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))],
//               ),
//               child: Text(message.content,
//                 style: TextStyle(fontSize: 14, color: isUser ? Colors.white : AppColors.textPrimary, height: 1.5)),
//             ),
//           ),
//           if (isUser) ...[
//             const SizedBox(width: 8),
//             Container(
//               width: 32, height: 32,
//               decoration: const BoxDecoration(color: AppColors.primarySurface, shape: BoxShape.circle),
//               child: const Center(child: Text('👤', style: TextStyle(fontSize: 14))),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }
 
// // ─────────────────────────────────────────────────────────────────────────────
// // TYPING INDICATOR
// // ─────────────────────────────────────────────────────────────────────────────
 
// class _TypingIndicator extends StatefulWidget {
//   @override
//   State<_TypingIndicator> createState() => _TypingIndicatorState();
// }
 
// class _TypingIndicatorState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
//   late AnimationController _ctrl;
 
//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
//   }
 
//   @override
//   void dispose() { _ctrl.dispose(); super.dispose(); }
 
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
//         Container(
//           width: 32, height: 32,
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]),
//             shape: BoxShape.circle,
//           ),
//           child: const Center(child: Text('🤖', style: TextStyle(fontSize: 14))),
//         ),
//         const SizedBox(width: 8),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//           decoration: BoxDecoration(
//             color: AppColors.cardBg,
//             borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18), bottomRight: Radius.circular(18), bottomLeft: Radius.circular(4)),
//             border: Border.all(color: AppColors.divider),
//           ),
//           child: Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) {
//             return AnimatedBuilder(
//               animation: _ctrl,
//               builder: (_, __) {
//                 final val = ((_ctrl.value - i * 0.2) % 1.0);
//                 final bounce = val < 0.5 ? val * 2 : (1 - val) * 2;
//                 return Container(
//                   margin: EdgeInsets.symmetric(horizontal: 2, vertical: 4 - bounce * 4),
//                   width: 8, height: 8,
//                   decoration: BoxDecoration(
//                     color: AppColors.primary.withValues(alpha: 0.4 + bounce * 0.6),
//                     shape: BoxShape.circle,
//                   ),
//                 );
//               },
//             );
//           })),
//         ),
//       ]),
//     );
//   }
// }
 
// // ─────────────────────────────────────────────────────────────────────────────
// // PULSE DOT — animated recording indicator
// // ─────────────────────────────────────────────────────────────────────────────
 
// class _PulseDot extends StatefulWidget {
//   @override
//   State<_PulseDot> createState() => _PulseDotState();
// }
 
// class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
//   late AnimationController _ctrl;
//   late Animation<double> _anim;
 
//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
//       ..repeat(reverse: true);
//     _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
//       CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
//     );
//   }
 
//   @override
//   void dispose() { _ctrl.dispose(); super.dispose(); }
 
//   @override
//   Widget build(BuildContext context) => FadeTransition(
//     opacity: _anim,
//     child: Container(
//       width: 8, height: 8,
//       decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
//     ),
//   );
// }
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
