// lib/shared/widgets/glass_widgets.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../lib/core/theme/app_theme.dart';

// ─── Glass Card ───────────────────────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blurAmount;
  final double opacity;
  final Color? tint;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 20,
    this.blurAmount = 12,
    this.opacity = 0.10,
    this.tint,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: width,
            height: height,
            padding: padding,
            decoration: GlassStyle.card(
              opacity: opacity,
              radius: borderRadius,
              tint: tint,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ─── Voice Status Banner ──────────────────────────────────────────────────────
/// The floating, curved, translucent rectangular banner for voice statuses.
class VoiceStatusBanner extends StatelessWidget {
  final String authorName;
  final String? authorAvatarUrl;
  final Duration duration;
  final double progress; // 0.0 – 1.0
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final List<double> waveform; // normalized 0-1 amplitude values

  const VoiceStatusBanner({
    super.key,
    required this.authorName,
    this.authorAvatarUrl,
    required this.duration,
    required this.progress,
    required this.isPlaying,
    required this.onPlayPause,
    required this.waveform,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.11),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: ZestColors.lemonGreen.withOpacity(0.30),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                // Avatar
                _Avatar(url: authorAvatarUrl, name: authorName),
                const SizedBox(width: 14),
                // Waveform + name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        authorName,
                        style: const TextStyle(
                          color: ZestColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _WaveformBar(
                        waveform: waveform,
                        progress: progress,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _fmt(duration * progress),
                        style: const TextStyle(
                          color: ZestColors.textSecondary,
                          fontSize: 11,
                          fontFamily: 'JetBrainsMono',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // Play/pause
                GestureDetector(
                  onTap: onPlayPause,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: ZestColors.lemonGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: ZestColors.void_black,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _Avatar extends StatelessWidget {
  final String? url;
  final String name;
  const _Avatar({this.url, required this.name});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: ZestColors.slate600,
      backgroundImage: url != null ? NetworkImage(url!) : null,
      child: url == null
          ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: ZestColors.lemonGreen,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            )
          : null,
    );
  }
}

class _WaveformBar extends StatelessWidget {
  final List<double> waveform;
  final double progress;

  const _WaveformBar({required this.waveform, required this.progress});

  @override
  Widget build(BuildContext context) {
    final playedBars = (waveform.length * progress).round();
    return SizedBox(
      height: 28,
      child: Row(
        children: List.generate(waveform.length, (i) {
          final amp = waveform[i];
          final played = i < playedBars;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 80),
                height: 6 + amp * 22,
                decoration: BoxDecoration(
                  color: played
                      ? ZestColors.lemonGreen
                      : ZestColors.textTertiary.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Lemon Badge ──────────────────────────────────────────────────────────────
class UnreadBadge extends StatelessWidget {
  final int count;
  const UnreadBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: ZestColors.lemonGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: const TextStyle(
          color: ZestColors.void_black,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ─── Online Dot ───────────────────────────────────────────────────────────────
class OnlineDot extends StatelessWidget {
  final bool isOnline;
  const OnlineDot({super.key, this.isOnline = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 11,
      height: 11,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isOnline ? ZestColors.online : ZestColors.textTertiary,
        border: Border.all(color: ZestColors.void_black, width: 2),
      ),
    );
  }
}

// ─── Zest Bottom Nav Bar ──────────────────────────────────────────────────────
class ZestBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const ZestBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    (icon: Icons.chat_bubble_outline_rounded, label: 'Chats'),
    (icon: Icons.explore_outlined, label: 'Feed'),
    (icon: Icons.person_outline_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: ZestColors.slate900.withOpacity(0.85),
            border: const Border(
              top: BorderSide(color: ZestColors.glassBorder, width: 1),
            ),
          ),
          child: Row(
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final selected = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: selected
                              ? ZestColors.lemonGreen.withOpacity(0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item.icon,
                          color: selected
                              ? ZestColors.lemonGreen
                              : ZestColors.textTertiary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                          color: selected
                              ? ZestColors.lemonGreen
                              : ZestColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
