// lib/features/home/screens/home_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/theme/app_theme.dart';
import '../../../core/models/models.dart';
import '../../../shared/widgets/glass_widgets.dart';

// ─── Mock Data (replace with Riverpod providers backed by ApiService) ─────────
final _mockUsers = List.generate(
  8,
  (i) => ZestUser(
    id: 'u$i',
    username: '@user_$i',
    displayName: ['Kira Nova', 'Milo Chen', 'Sasha V', 'Dex Park',
                   'Zoe Ito', 'Kai Ryu', 'Noa Bell', 'Eli Stone'][i],
    isOnline: i.isEven,
  ),
);

final _mockStatuses = List.generate(
  6,
  (i) => UserStatus(
    id: 's$i',
    author: _mockUsers[i],
    type: i == 2 ? StatusType.voiceStatus : StatusType.image,
    data: 'https://picsum.photos/seed/${i * 7}/400/700',
    createdAt: DateTime.now().subtract(Duration(hours: i + 1)),
    expiresAt: DateTime.now().add(Duration(hours: 23 - i)),
    hasSeen: i > 3,
  ),
);

final _mockConversations = List.generate(
  10,
  (i) => Conversation(
    id: 'c$i',
    peer: _mockUsers[i % _mockUsers.length],
    lastMessage: [
      'sounds good, see you then 👋',
      '🎵 Voice message',
      'did you see the drop?',
      'lmaooo okay fair enough',
      'check this out →',
      'on my way',
      '🖼 Photo',
      'totally agreed tbh',
      'what time works for you?',
      'gn!',
    ][i],
    lastMessageTime: DateTime.now().subtract(Duration(minutes: i * 13 + 2)),
    unreadCount: [0, 3, 0, 1, 0, 7, 0, 2, 0, 0][i],
    lastMessageType: i == 1 ? MessageType.voice : (i == 6 ? MessageType.image : MessageType.text),
  ),
);

// ─── Home Screen ─────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZestColors.void_black,
      body: IndexedStack(
        index: _tab,
        children: const [
          _ChatsTab(),
          _FeedTab(),
          _ProfileStub(),
        ],
      ),
      bottomNavigationBar: ZestBottomNavBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// CHATS TAB
// ════════════════════════════════════════════════════════════════════════════
class _ChatsTab extends StatelessWidget {
  const _ChatsTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _ZestAppBar(
          title: 'ZestChat',
          actions: [
            _IconBtn(
              icon: Icons.search_rounded,
              onTap: () => context.go('/home/search'),
            ),
            _IconBtn(icon: Icons.edit_square, onTap: () {}),
          ],
        ),
        // Status row
        SliverToBoxAdapter(
          child: _StatusRow(statuses: _mockStatuses),
        ),
        // Section header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'MESSAGES',
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: ZestColors.textTertiary,
                    letterSpacing: 2,
                  ),
            ),
          ),
        ),
        // Chat list
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) => _ConversationTile(
              conv: _mockConversations[i],
              index: i,
            ),
            childCount: _mockConversations.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }
}

// ─── Status Row ───────────────────────────────────────────────────────────────
class _StatusRow extends StatelessWidget {
  final List<UserStatus> statuses;
  const _StatusRow({required this.statuses});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 102,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: statuses.length + 1, // +1 for "My Status"
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (ctx, i) {
          if (i == 0) return const _MyStatusBubble();
          final s = statuses[i - 1];
          return _StatusBubble(status: s)
              .animate()
              .fadeIn(delay: (i * 60).ms, duration: 300.ms)
              .slideX(begin: 0.2, end: 0);
        },
      ),
    );
  }
}

class _MyStatusBubble extends StatelessWidget {
  const _MyStatusBubble();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {}, // open story composer
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ZestColors.slate700,
                  border: Border.all(color: ZestColors.glassBorder, width: 2),
                ),
                child: const Icon(Icons.person_rounded,
                    color: ZestColors.textTertiary, size: 28),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: ZestColors.lemonGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add_rounded,
                      color: ZestColors.void_black, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'My Status',
            style: TextStyle(color: ZestColors.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _StatusBubble extends StatelessWidget {
  final UserStatus status;
  const _StatusBubble({required this.status});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/home/status/${status.id}'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 62,
            height: 62,
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: status.hasSeen
                  ? null
                  : const LinearGradient(
                      colors: [ZestColors.lemonGreen, Color(0xFF52E5E7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              color: status.hasSeen ? ZestColors.slate600 : null,
            ),
            child: CircleAvatar(
              backgroundColor: ZestColors.slate700,
              backgroundImage: status.type == StatusType.image
                  ? NetworkImage(status.data)
                  : null,
              child: status.type == StatusType.voiceStatus
                  ? const Icon(Icons.mic_rounded,
                      color: ZestColors.lemonGreen, size: 26)
                  : null,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 64,
            child: Text(
              status.author.displayName.split(' ').first,
              style: const TextStyle(
                color: ZestColors.textSecondary,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Conversation Tile ────────────────────────────────────────────────────────
class _ConversationTile extends StatelessWidget {
  final Conversation conv;
  final int index;
  const _ConversationTile({required this.conv, required this.index});

  @override
  Widget build(BuildContext context) {
    final lastMsgIcon = switch (conv.lastMessageType) {
      MessageType.voice => '🎵 ',
      MessageType.image => '🖼 ',
      _ => '',
    };

    return GestureDetector(
      onTap: () => context.go(
        '/home/chat/${conv.peer.id}',
        extra: {'name': conv.peer.displayName},
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.transparent,
        ),
        child: Row(
          children: [
            // Avatar + online dot
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: ZestColors.slate600,
                  backgroundImage:
                      conv.peer.avatarUrl != null
                          ? NetworkImage(conv.peer.avatarUrl!)
                          : null,
                  child: conv.peer.avatarUrl == null
                      ? Text(
                          conv.peer.displayName[0].toUpperCase(),
                          style: const TextStyle(
                            color: ZestColors.lemonGreen,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        )
                      : null,
                ),
                if (conv.peer.isOnline)
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: OnlineDot(isOnline: conv.peer.isOnline),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            // Name + last message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conv.peer.displayName,
                    style: const TextStyle(
                      color: ZestColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$lastMsgIcon${conv.lastMessage}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: conv.unreadCount > 0
                          ? ZestColors.textPrimary
                          : ZestColors.textSecondary,
                      fontSize: 13,
                      fontWeight: conv.unreadCount > 0
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Time + badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeago.format(conv.lastMessageTime, locale: 'en_short'),
                  style: TextStyle(
                    color: conv.unreadCount > 0
                        ? ZestColors.lemonGreen
                        : ZestColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 5),
                UnreadBadge(count: conv.unreadCount),
              ],
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(delay: (index * 40).ms, duration: 250.ms)
          .slideX(begin: 0.05, end: 0),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// FEED TAB
// ════════════════════════════════════════════════════════════════════════════
class _FeedTab extends StatelessWidget {
  const _FeedTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _ZestAppBar(title: 'Discover', actions: [
          _IconBtn(icon: Icons.tune_rounded, onTap: () {}),
        ]),
        // Statuses horizontal strip
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                child: Text(
                  'LIVE UPDATES',
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: ZestColors.textTertiary,
                        letterSpacing: 2,
                      ),
                ),
              ),
              _StatusRow(statuses: _mockStatuses),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Text(
                  'PEOPLE YOU MAY KNOW',
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: ZestColors.textTertiary,
                        letterSpacing: 2,
                      ),
                ),
              ),
            ],
          ),
        ),
        // Recommendations grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _RecommendationCard(user: _mockUsers[i % _mockUsers.length], index: i),
              childCount: 12,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.78,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final ZestUser user;
  final int index;
  const _RecommendationCard({required this.user, required this.index});

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFF1A2B0D),
      const Color(0xFF0D1A2B),
      const Color(0xFF1A0D2B),
      const Color(0xFF2B0D1A),
    ];

    return GestureDetector(
      onTap: () => context.go(
        '/home/chat/${user.id}',
        extra: {'name': user.displayName},
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            decoration: BoxDecoration(
              color: colors[index % colors.length].withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ZestColors.glassBorder, width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [ZestColors.lemonGreenDim, Color(0xFF1A8080)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: ZestColors.slate600,
                      child: Text(
                        user.displayName[0].toUpperCase(),
                        style: const TextStyle(
                          color: ZestColors.lemonGreen,
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    if (user.isOnline)
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: OnlineDot(isOnline: user.isOnline),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  user.displayName,
                  style: const TextStyle(
                    color: ZestColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  user.username,
                  style: const TextStyle(
                    color: ZestColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 12),
                _AddButton(onTap: () {}),
              ],
            ),
          ),
        ),
      )
          .animate()
          .fadeIn(delay: (index * 50).ms, duration: 300.ms)
          .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        decoration: BoxDecoration(
          color: ZestColors.lemonGreen.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: ZestColors.lemonGreen.withOpacity(0.40), width: 1),
        ),
        child: const Text(
          'Add',
          style: TextStyle(
            color: ZestColors.lemonGreen,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// ─── Stub Profile ─────────────────────────────────────────────────────────────
class _ProfileStub extends StatelessWidget {
  const _ProfileStub();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Profile Screen',
        style: TextStyle(color: ZestColors.textSecondary),
      ),
    );
  }
}

// ─── Shared App Bar ───────────────────────────────────────────────────────────
class _ZestAppBar extends StatelessWidget {
  final String title;
  final List<Widget> actions;

  const _ZestAppBar({required this.title, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: ZestColors.void_black,
      expandedHeight: 64,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(20, 0, 16, 14),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: ZestColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            ...actions,
          ],
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.only(left: 6),
        decoration: BoxDecoration(
          color: ZestColors.slate700,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ZestColors.glassBorder, width: 1),
        ),
        child: Icon(icon, color: ZestColors.textSecondary, size: 18),
      ),
    );
  }
}
