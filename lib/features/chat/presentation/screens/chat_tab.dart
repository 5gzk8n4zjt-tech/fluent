import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ChatTab extends StatelessWidget {
  const ChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF0F0EC)))),
              child: Row(
                children: [
                  const SizedBox(width: 20),
                  Expanded(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text('●', style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                            SizedBox(width: 8),
                            Text('Ordering food', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            SizedBox(width: 4),
                            Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
            ),
            // Messages
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                children: [
                  const Center(
                    child: Text('TODAY · 9:41', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, letterSpacing: 0.5)),
                  ),
                  const SizedBox(height: 12),
                  for (final msg in _messages) ...[
                    _MessageBubble(message: msg),
                    const SizedBox(height: 12),
                  ],
                  // Vocabulary tooltip
                  Container(
                    margin: const EdgeInsets.only(left: 12, top: -4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    constraints: const BoxConstraints(maxWidth: 220),
                    decoration: BoxDecoration(color: AppColors.textPrimary, borderRadius: BorderRadius.circular(8)),
                    child: const Text(
                      'Underlined words come from your decks. Tap to review.',
                      style: TextStyle(fontSize: 12, color: Colors.white, letterSpacing: -0.1, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            // Input bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24)),
                      child: const Text('Write or speak…', style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
                    child: const Icon(Icons.mic_none, color: AppColors.textPrimary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: AppColors.textPrimary, borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Data ─────────────────────────────────────────────────────────────────────

class _Message {
  const _Message({required this.role, required this.text, this.highlights = const []});
  final String role;
  final String text;
  final List<String> highlights;
}

const _messages = [
  _Message(role: 'ai', text: "Welcome! Let's practice ordering food. Imagine you've just sat down at a cozy Italian restaurant. I'm your waiter — what can I get you?"),
  _Message(role: 'user', text: "Hi, could I see the menu please?"),
  _Message(role: 'ai', text: "Of course. Here you are. Today our special is homemade gnocchi with sage butter. Do you have any allergies I should know about?", highlights: ['allergies']),
  _Message(role: 'user', text: "Yes, I'm allergic to nuts."),
  _Message(role: 'ai', text: "Thank you for letting me know — I'll make sure the chef is aware.", highlights: ['allergic']),
];

// ─── Bubble ───────────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final _Message message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
        decoration: BoxDecoration(
          color: isUser ? AppColors.textPrimary : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 6),
            bottomRight: Radius.circular(isUser ? 6 : 18),
          ),
        ),
        child: _buildContent(isUser),
      ),
    );
  }

  Widget _buildContent(bool isUser) {
    final baseStyle = TextStyle(fontSize: 15, color: isUser ? Colors.white : AppColors.textPrimary, height: 1.45, letterSpacing: -0.1);

    if (message.highlights.isEmpty) {
      return Text(message.text, style: baseStyle);
    }

    final spans = <TextSpan>[];
    final pattern = RegExp(message.highlights.map(RegExp.escape).join('|'), caseSensitive: false);

    message.text.splitMapJoin(
      pattern,
      onMatch: (m) {
        spans.add(TextSpan(
          text: m.group(0),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            decorationStyle: TextDecorationStyle.dotted,
            decorationColor: AppColors.textSecondary,
          ),
        ));
        return '';
      },
      onNonMatch: (s) {
        if (s.isNotEmpty) spans.add(TextSpan(text: s));
        return '';
      },
    );

    return RichText(text: TextSpan(style: baseStyle, children: spans));
  }
}
