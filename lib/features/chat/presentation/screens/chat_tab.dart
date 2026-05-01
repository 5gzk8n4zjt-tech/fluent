import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/supabase_client.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../providers/chat_providers.dart';

// Predefined conversation topics
const _topics = [
  'Ordering food at a restaurant',
  'At the doctor\'s office',
  'Shopping at a store',
  'Asking for directions',
  'Making a hotel reservation',
  'Job interview',
];

class ChatTab extends ConsumerStatefulWidget {
  const ChatTab({super.key});

  @override
  ConsumerState<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends ConsumerState<ChatTab> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _speech = SpeechToText();

  bool _speechAvailable = false;
  bool _isListening = false;
  String _pendingVoiceText = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startSession());
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    final ok = await _speech.initialize(
      onError: (_) => setState(() => _isListening = false),
    );
    if (mounted) setState(() => _speechAvailable = ok);
  }

  Future<void> _startSession() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    await ref
        .read(chatNotifierProvider.notifier)
        .initSession(userId, topic: _topics.first);
  }

  Future<void> _sendText() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    _scrollToBottom();

    final userId = supabase.auth.currentUser?.id ?? '';
    final words = ref
            .read(learnedWordsProvider(userId))
            .valueOrNull ??
        const [];
    await ref.read(chatNotifierProvider.notifier).sendMessage(text, words);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _toggleListening() async {
    if (!_speechAvailable) return;

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      if (_pendingVoiceText.isNotEmpty) {
        _controller.text = _pendingVoiceText;
        _pendingVoiceText = '';
        await _sendText();
      }
      return;
    }

    setState(() {
      _isListening = true;
      _pendingVoiceText = '';
    });

    await _speech.listen(
      localeId: 'en_US',
      onResult: (result) {
        setState(() => _pendingVoiceText = result.recognizedWords);
        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          _speech.stop();
          setState(() => _isListening = false);
          _controller.text = result.recognizedWords;
          _pendingVoiceText = '';
          _sendText();
        }
      },
    );
  }

  Future<void> _changeTopic(String topic) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    await ref
        .read(chatNotifierProvider.notifier)
        .initSession(userId, topic: topic);
  }

  void _showTopicPicker() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text('Choose a topic',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            ),
            for (final t in _topics)
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                title: Text(t,
                    style: const TextStyle(fontSize: 15, height: 1.3)),
                onTap: () {
                  Navigator.pop(ctx);
                  _changeTopic(t);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(chatNotifierProvider);
    final userId = supabase.auth.currentUser?.id ?? '';
    ref.watch(learnedWordsProvider(userId)); // preload

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopicHeader(
              topic: session.topic,
              onTap: _showTopicPicker,
            ),
            Expanded(
              child: _buildBody(session),
            ),
            _InputBar(
              controller: _controller,
              isSending: session.isSending,
              isListening: _isListening,
              speechAvailable: _speechAvailable,
              pendingVoiceText: _pendingVoiceText,
              onSend: _sendText,
              onMic: _toggleListening,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ChatState session) {
    if (!session.isReady) {
      if (session.error != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.textSecondary, size: 40),
                const SizedBox(height: 12),
                Text(session.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _startSession,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                        color: AppColors.textPrimary,
                        borderRadius: BorderRadius.circular(20)),
                    child: const Text('Retry',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return const Center(child: CircularProgressIndicator());
    }

    final messages = session.messages;

    if (messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💬',
                  style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                'Start practicing "${session.topic}"',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.2),
              ),
              const SizedBox(height: 6),
              const Text('Type or speak your first message.',
                  style: TextStyle(
                      fontSize: 14, color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      itemCount: messages.length + (session.isSending ? 1 : 0),
      itemBuilder: (ctx, i) {
        if (i == messages.length) {
          return const _TypingIndicator();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _MessageBubble(message: messages[i]),
        );
      },
    );
  }
}

// ── Topic header ────────────────────────────────────────────────────────────

class _TopicHeader extends StatelessWidget {
  const _TopicHeader({required this.topic, required this.onTap});

  final String topic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF0F0EC)))),
      child: Row(
        children: [
          const SizedBox(width: 20),
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('●',
                          style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textPrimary)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          topic,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down,
                          size: 16, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }
}

// ── Message bubble ──────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessageEntity message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
        decoration: BoxDecoration(
          color:
              isUser ? AppColors.textPrimary : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 6),
            bottomRight: Radius.circular(isUser ? 6 : 18),
          ),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            fontSize: 15,
            color: isUser ? Colors.white : AppColors.textPrimary,
            height: 1.45,
            letterSpacing: -0.1,
          ),
        ),
      ),
    );
  }
}

// ── Typing indicator ────────────────────────────────────────────────────────

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(6),
          ),
        ),
        child: const SizedBox(
          width: 36,
          child: _DotsAnimation(),
        ),
      ),
    );
  }
}

class _DotsAnimation extends StatefulWidget {
  const _DotsAnimation();

  @override
  State<_DotsAnimation> createState() => _DotsAnimationState();
}

class _DotsAnimationState extends State<_DotsAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(3, (i) {
            final phase = (_ctrl.value * 3 - i).clamp(0.0, 1.0);
            final opacity = (phase < 0.5 ? phase : 1.0 - phase) * 2;
            return Opacity(
              opacity: opacity.clamp(0.2, 1.0),
              child: const CircleAvatar(
                  radius: 4, backgroundColor: AppColors.textSecondary),
            );
          }),
        );
      },
    );
  }
}

// ── Input bar ───────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.isSending,
    required this.isListening,
    required this.speechAvailable,
    required this.pendingVoiceText,
    required this.onSend,
    required this.onMic,
  });

  final TextEditingController controller;
  final bool isSending;
  final bool isListening;
  final bool speechAvailable;
  final String pendingVoiceText;
  final VoidCallback onSend;
  final VoidCallback onMic;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isListening && pendingVoiceText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '🎤 "$pendingVoiceText"',
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  enabled: !isSending && !isListening,
                  decoration: InputDecoration(
                    hintText:
                        isListening ? 'Listening…' : 'Type in English…',
                    hintStyle: const TextStyle(
                        fontSize: 15, color: AppColors.textSecondary),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 11),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              if (speechAvailable)
                GestureDetector(
                  onTap: isSending ? null : onMic,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isListening
                          ? AppColors.textPrimary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isListening
                            ? AppColors.textPrimary
                            : AppColors.border,
                      ),
                    ),
                    child: Icon(
                      isListening ? Icons.mic : Icons.mic_none,
                      color: isListening
                          ? Colors.white
                          : AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: isSending || isListening ? null : onSend,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSending
                        ? AppColors.border
                        : AppColors.textPrimary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: isSending
                      ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.arrow_forward,
                          color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
