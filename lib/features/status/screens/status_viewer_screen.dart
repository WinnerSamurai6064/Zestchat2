// lib/features/status/screens/status_viewer_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/models.dart';
import '../../../shared/widgets/glass_widgets.dart';

// ─── Mock lookup ─────────────────────────────────────────────────────────────
final _mockStatusMap = <String, UserStatus>{
  's0': UserStatus(
    id: 's0',
    author: ZestUser(id: 'u0', username: '@kira', displayName: 'Kira Nova'),
    type: StatusType.image,
    data: 'https://picsum.photos/seed/42/800/1400',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    expiresAt: DateTime.now().add(const Duration(hours: 22)),
  ),
  's2': UserStatus(
    id: 's2',
    author: ZestUser(id: 'u2', username: '@sasha', displayName: 'Sasha V'),
    type: StatusType.voiceStatus,
    data: 'https://example.com/voice.amr',
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    expiresAt: DateTime.now().add(const Duration(hours: 21)),
  ),
};

// ─── Status Viewer Screen ─────────────────────────────────────────────────────
class StatusViewerScreen extends StatefulWidget {
  final String statusId;
  const StatusViewerScreen({super.key, required this.statusId});

  @override
  State<StatusViewerScreen> createState() => _StatusViewerScreenState();
}

class _StatusViewerScreenState extends State<StatusViewerScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  bool _isPlaying = false;
  double _voiceProgress = 0.0;

  // Fake waveform data
  final _waveform = List.generate(
    36,
    (i) => (0.3 + 0.7 * ((i * 13) % 10) / 10).clamp(0.1, 1.0),
  );

  UserStatus? get _status => _mockStatusMap[widget.statusId] ??
      _mockStatusMap.values.first; // fallback

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        setState(() {});
        if (_progressController.isCompleted) {
          context.pop();
        }
      });

    // Auto-play for image statuses
    if (_status?.type == StatusType.image) {
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _toggleVoicePlay() {
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      _progressController.forward();
      // Simulate voice progress
      _simulateVoice();
    } else {
      _progressController.stop();
    }
  }

  void _simulateVoice() async {
    // Fake playback simulation; replace with audioplayers
    for (int i = 0; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 60));
      if (!mounted || !_isPlaying) break;
      setState(() => _voiceProgress = i / 100);
    }
    if (mounted) {
      setState(() {
        _isPlaying = false;
        _voiceProgress = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;
    if (status == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: ZestColors.void_black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background
          _StatusBackground(status: status),

          // ── Progress bar + header
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            right: 12,
            child: Column(
              children: [
                // Progress bar
                LinearProgressIndicator(
                  value: _progressController.value,
                  backgroundColor: Colors.white.withOpacity(0.25),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      ZestColors.lemonGreen),
                  minHeight: 3,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 12),
                // Author row
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: ZestColors.slate600,
                      child: Text(
                        status.author.displayName[0].toUpperCase(),
                        style: const TextStyle(
                          color: ZestColors.lemonGreen,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            status.author.displayName,
                            style: const TextStyle(
                              color: ZestColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _timeAgo(status.createdAt),
                            style: const TextStyle(
                              color: ZestColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: ZestColors.textPrimary),
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),

          // ── Voice banner (only for voice_status)
          if (status.type == StatusType.voiceStatus)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 40,
              left: 0,
              right: 0,
              child: VoiceStatusBanner(
                authorName: status.author.displayName,
                authorAvatarUrl: status.author.avatarUrl,
                duration: const Duration(seconds: 60),
                progress: _voiceProgress,
                isPlaying: _isPlaying,
                onPlayPause: _toggleVoicePlay,
                waveform: _waveform,
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 350.ms)
                  .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),
            ),

          // ── Reply bar
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 10,
            left: 16,
            right: 16,
            child: _ReplyBar(),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ─── Background ───────────────────────────────────────────────────────────────
class _StatusBackground extends StatelessWidget {
  final UserStatus status;
  const _StatusBackground({required this.status});

  @override
  Widget build(BuildContext context) {
    if (status.type == StatusType.image) {
      return Image.network(
        status.data,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: ZestColors.slate900,
          child: const Center(
            child: Icon(Icons.broken_image_outlined,
                color: ZestColors.textTertiary, size: 48),
          ),
        ),
      );
    }

    // Voice status: blurred gradient background
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              colors: [Color(0xFF162B0A), Color(0xFF060608)],
              radius: 1.2,
            ),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: const SizedBox.expand(),
        ),
        // Decorative circles
        Center(
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: ZestColors.lemonGreen.withOpacity(0.08),
                width: 40,
              ),
            ),
          ),
        ),
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ZestColors.lemonGreen.withOpacity(0.06),
            ),
            child: const Icon(
              Icons.mic_rounded,
              color: ZestColors.lemonGreen,
              size: 44,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Reply Bar ────────────────────────────────────────────────────────────────
class _ReplyBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: ZestColors.glassBorder, width: 1),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Reply to status…',
                  style: TextStyle(
                    color: ZestColors.textTertiary,
                    fontSize: 14,
                  ),
                ),
              ),
              const Icon(Icons.emoji_emotions_outlined,
                  color: ZestColors.textTertiary, size: 20),
              const SizedBox(width: 12),
              const Icon(Icons.send_rounded,
                  color: ZestColors.lemonGreen, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
