// lib/features/chat/screens/chat_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/models.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/widgets/glass_widgets.dart';

// ─── Mock data ────────────────────────────────────────────────────────────────
final _mockMessages = <ChatMessage>[
  _msg('0', 'Hello! How's everything?', isMine: false, minsAgo: 22),
  _msg('1', 'all good! just shipped a new build 🚀', isMine: true, minsAgo: 20),
  _msg('2', 'Nice! What stack?', isMine: false, minsAgo: 19),
  _msg('3', 'Rust on the backend, Flutter web up front', isMine: true, minsAgo: 17),
  _msg('4', 'oh wait you're that person 😂', isMine: false, minsAgo: 15),
  _msg('5', 'lol yes, ephemeral data and all', isMine: true, minsAgo: 14),
  _msg('6', 'sounds wild but cool. send me the link?', isMine: false, minsAgo: 10),
  _msg('7', 'will do once it goes live tonight', isMine: true, minsAgo: 5),
];

ChatMessage _msg(String id, String text, {required bool isMine, required int minsAgo}) =>
    ChatMessage(
      id: id,
      senderId: isMine ? 'me' : 'them',
      recipientId: isMine ? 'them' : 'me',
      type: MessageType.text,
      content: text,
      timestamp: DateTime.now().subtract(Duration(minutes: minsAgo)),
      status: MessageStatus.read,
      isMine: isMine,
    );

// ─── Chat Screen ─────────────────────────────────────────────────────────────
class ChatScreen extends StatefulWidget {
  final String peerId;
  final String peerDisplayName;

  const ChatScreen({
    super.key,
    required this.peerId,
    required this.peerDisplayName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <ChatMessage>[..._mockMessages];
  bool _showSelfDestructToast = false;
  bool _firstMessageSent = false;
  bool _isRecording = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendText() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'me',
        recipientId: widget.peerId,
        type: MessageType.text,
        content: text,
        timestamp: DateTime.now(),
        status: MessageStatus.sending,
        isMine: true,
      ));
      _controller.clear();
    });

    // Show self-destruct toast on first message
    if (!_firstMessageSent) {
      _firstMessageSent = true;
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          setState(() => _showSelfDestructToast = true);
          Future.delayed(const Duration(seconds: 6), () {
            if (mounted) setState(() => _showSelfDestructToast = false);
          });
        }
      });
    }

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 80), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // TODO: call ApiService().sendTextMessage(...)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZestColors.void_black,
      body: Stack(
        children: [
          // ── Wallpaper
          Positioned.fill(child: _ChatWallpaper()),

          // ── Main content
          Column(
            children: [
              _ChatAppBar(
                peerName: widget.peerDisplayName,
                peerId: widget.peerId,
                onBack: () => context.pop(),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: _messages.length,
                  itemBuilder: (ctx, i) {
                    final msg = _messages[i];
                    final showDate = i == 0 ||
                        !_sameDay(_messages[i - 1].timestamp, msg.timestamp);
                    return Column(
                      children: [
                        if (showDate) _DateDivider(date: msg.timestamp),
                        _MessageBubble(message: msg, index: i),
                      ],
                    );
                  },
                ),
              ),
              _InputBar(
                controller: _controller,
                isRecording: _isRecording,
                onSend: _sendText,
                onStartRecording: () => setState(() => _isRecording = true),
                onStopRecording: () => setState(() => _isRecording = false),
              ),
            ],
          ),

          // ── Self-destruct toast
          if (_showSelfDestructToast)
            Positioned(
              bottom: 88,
              left: 20,
              right: 20,
              child: _SelfDestructToast(
                onDismiss: () => setState(() => _showSelfDestructToast = false),
              ),
            ),
        ],
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ─── Wallpaper ────────────────────────────────────────────────────────────────
class _ChatWallpaper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.5, -0.2),
          radius: 1.4,
          colors: [
            Color(0xFF0B1A08),
            Color(0xFF060608),
            Color(0xFF06080F),
          ],
        ),
      ),
      child: CustomPaint(painter: _DotGridPainter()),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ZestColors.lemonGreen.withOpacity(0.03)
      ..strokeWidth = 1;
    const spacing = 24.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── App Bar ─────────────────────────────────────────────────────────────────
class _ChatAppBar extends StatelessWidget {
  final String peerName;
  final String peerId;
  final VoidCallback onBack;

  const _ChatAppBar({
    required this.peerName,
    required this.peerId,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            bottom: 10,
            left: 8,
            right: 16,
          ),
          decoration: const BoxDecoration(
            color: Color(0xCC0D0F14),
            border: Border(
              bottom: BorderSide(color: ZestColors.glassBorder, width: 1),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: ZestColors.textPrimary, size: 18),
                onPressed: onBack,
              ),
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: ZestColors.slate600,
                    child: Text(
                      peerName[0].toUpperCase(),
                      style: const TextStyle(
                        color: ZestColors.lemonGreen,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: OnlineDot(isOnline: true),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      peerName,
                      style: const TextStyle(
                        color: ZestColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      'online',
                      style: TextStyle(
                        color: ZestColors.online,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.videocam_outlined,
                    color: ZestColors.textSecondary),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.more_vert_rounded,
                    color: ZestColors.textSecondary),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Message Bubble ───────────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final int index;
  const _MessageBubble({required this.message, required this.index});

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        child: Container(
          margin: EdgeInsets.only(
            bottom: 4,
            left: isMine ? 48 : 0,
            right: isMine ? 0 : 48,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: isMine ? ZestColors.bubbleSent : ZestColors.bubbleReceived,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isMine ? 18 : 4),
              bottomRight: Radius.circular(isMine ? 4 : 18),
            ),
            border: Border.all(
              color: isMine
                  ? ZestColors.bubbleSentBorder
                  : ZestColors.bubbleReceivedBorder,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                message.content,
                style: const TextStyle(
                  color: ZestColors.textPrimary,
                  fontSize: 14.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('HH:mm').format(message.timestamp),
                    style: const TextStyle(
                      color: ZestColors.textTertiary,
                      fontSize: 10,
                      fontFamily: 'JetBrainsMono',
                    ),
                  ),
                  if (isMine) ...[
                    const SizedBox(width: 4),
                    _StatusIcon(status: message.status),
                  ],
                ],
              ),
            ],
          ),
        ).animate().fadeIn(
              delay: (index * 20).ms,
              duration: 200.ms,
            ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final MessageStatus status;
  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      MessageStatus.sending  => const SizedBox(
          width: 12, height: 12,
          child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: ZestColors.textTertiary)),
      MessageStatus.sent     => const Icon(Icons.check_rounded,
          size: 13, color: ZestColors.textTertiary),
      MessageStatus.delivered => const Icon(Icons.done_all_rounded,
          size: 13, color: ZestColors.textTertiary),
      MessageStatus.read     => const Icon(Icons.done_all_rounded,
          size: 13, color: ZestColors.lemonGreen),
      MessageStatus.failed   => const Icon(Icons.error_outline_rounded,
          size: 13, color: ZestColors.error),
    };
  }
}

// ─── Date Divider ─────────────────────────────────────────────────────────────
class _DateDivider extends StatelessWidget {
  final DateTime date;
  const _DateDivider({required this.date});

  @override
  Widget build(BuildContext context) {
    final label = _label(date);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          const Expanded(child: Divider(color: ZestColors.glassBorder)),
          const SizedBox(width: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: ZestColors.slate700.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: ZestColors.glassBorder),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: ZestColors.textTertiary,
                    fontSize: 11,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(child: Divider(color: ZestColors.glassBorder)),
        ],
      ),
    );
  }

  String _label(DateTime d) {
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return 'Today';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (d.year == yesterday.year &&
        d.month == yesterday.month &&
        d.day == yesterday.day) {
      return 'Yesterday';
    }
    return DateFormat('MMM d, yyyy').format(d);
  }
}

// ─── Input Bar ────────────────────────────────────────────────────────────────
class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isRecording;
  final VoidCallback onSend;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;

  const _InputBar({
    required this.controller,
    required this.isRecording,
    required this.onSend,
    required this.onStartRecording,
    required this.onStopRecording,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            12,
            10,
            12,
            10 + MediaQuery.of(context).padding.bottom,
          ),
          decoration: const BoxDecoration(
            color: Color(0xCC0D0F14),
            border: Border(
              top: BorderSide(color: ZestColors.glassBorder, width: 1),
            ),
          ),
          child: Row(
            children: [
              // Emoji
              _CircleIconBtn(
                icon: Icons.emoji_emotions_outlined,
                onTap: () {},
              ),
              const SizedBox(width: 8),
              // Text field
              Expanded(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(
                    color: ZestColors.textPrimary,
                    fontSize: 15,
                  ),
                  maxLines: 4,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: isRecording ? 'Recording…' : 'Message',
                    hintStyle: const TextStyle(color: ZestColors.textTertiary),
                    filled: true,
                    fillColor: ZestColors.slate700,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: const BorderSide(
                          color: ZestColors.glassBorder, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: const BorderSide(
                          color: ZestColors.lemonGreen, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.attach_file_rounded,
                          color: ZestColors.textTertiary, size: 20),
                      onPressed: () {},
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Mic / Send
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: controller.text.isNotEmpty
                    ? _SendBtn(onTap: onSend)
                    : _MicBtn(
                        isRecording: isRecording,
                        onStart: onStartRecording,
                        onStop: onStopRecording,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: ZestColors.slate700,
            shape: BoxShape.circle,
            border: Border.all(color: ZestColors.glassBorder, width: 1),
          ),
          child: Icon(icon, color: ZestColors.textSecondary, size: 20),
        ),
      );
}

class _SendBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _SendBtn({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        key: const ValueKey('send'),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: ZestColors.lemonGreen,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.send_rounded,
              color: ZestColors.void_black, size: 20),
        ),
      );
}

class _MicBtn extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onStart;
  final VoidCallback onStop;
  const _MicBtn({
    required this.isRecording,
    required this.onStart,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        key: const ValueKey('mic'),
        onLongPressStart: (_) => onStart(),
        onLongPressEnd: (_) => onStop(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isRecording
                ? ZestColors.error.withOpacity(0.2)
                : ZestColors.slate700,
            shape: BoxShape.circle,
            border: Border.all(
              color: isRecording ? ZestColors.error : ZestColors.glassBorder,
              width: 1,
            ),
          ),
          child: Icon(
            isRecording ? Icons.stop_rounded : Icons.mic_none_rounded,
            color: isRecording ? ZestColors.error : ZestColors.textSecondary,
            size: 22,
          ),
        ),
      );
}

// ─── Self-Destruct Toast ──────────────────────────────────────────────────────
class _SelfDestructToast extends StatelessWidget {
  final VoidCallback onDismiss;
  const _SelfDestructToast({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      borderRadius: 16,
      opacity: 0.14,
      child: Row(
        children: [
          const Text('💥', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'WARNING: Due to extreme server congestion, this chat will completely self-destruct in 7 days… We totally don\'t keep this forever.',
              style: TextStyle(
                color: ZestColors.textSecondary,
                fontSize: 11.5,
                height: 1.4,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded,
                color: ZestColors.textTertiary, size: 16),
            onPressed: onDismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic);
  }
}
