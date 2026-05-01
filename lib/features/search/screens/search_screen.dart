// lib/features/search/screens/search_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/models.dart';
import '../../../shared/widgets/glass_widgets.dart';

// ─── Mock search results ──────────────────────────────────────────────────────
final _allUsers = [
  ZestUser(id: 'u1', username: '@milo_c', displayName: 'Milo Chen', isOnline: true),
  ZestUser(id: 'u2', username: '@sasha_v', displayName: 'Sasha V'),
  ZestUser(id: 'u3', username: '@dex_park', displayName: 'Dex Park', isOnline: true),
  ZestUser(id: 'u4', username: '@zoe_ito', displayName: 'Zoe Ito'),
  ZestUser(id: 'u5', username: '@kai_ryu', displayName: 'Kai Ryu', isOnline: true),
  ZestUser(id: 'u6', username: '@noa_bell', displayName: 'Noa Bell'),
];

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<ZestUser> _results = [];
  bool _loading = false;
  bool _searched = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged() {
    _debounce?.cancel();
    final q = _controller.text.trim();
    if (q.isEmpty) {
      setState(() { _results = []; _searched = false; });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(q));
  }

  Future<void> _search(String q) async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 500)); // Simulated network
    // TODO: call ApiService().searchUser(username: q)
    final lower = q.toLowerCase().replaceFirst('@', '');
    setState(() {
      _results = _allUsers
          .where((u) =>
              u.username.contains(lower) ||
              u.displayName.toLowerCase().contains(lower))
          .toList();
      _loading = false;
      _searched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZestColors.void_black,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: ZestColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: const TextStyle(color: ZestColors.textPrimary, fontSize: 16),
          decoration: const InputDecoration(
            hintText: 'Search by @username or name…',
            hintStyle: TextStyle(color: ZestColors.textTertiary, fontSize: 14),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded,
                  color: ZestColors.textTertiary),
              onPressed: () {
                _controller.clear();
                setState(() { _results = []; _searched = false; });
              },
            ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _loading
            ? const _LoadingShimmer()
            : (!_searched
                ? const _SearchHint()
                : (_results.isEmpty
                    ? const _EmptyState()
                    : _ResultsList(results: _results))),
      ),
    );
  }
}

class _ResultsList extends StatelessWidget {
  final List<ZestUser> results;
  const _ResultsList({required this.results});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      itemCount: results.length,
      itemBuilder: (ctx, i) => _UserTile(user: results[i], index: i),
    );
  }
}

class _UserTile extends StatelessWidget {
  final ZestUser user;
  final int index;
  const _UserTile({required this.user, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(
        '/home/chat/${user.id}',
        extra: {'name': user.displayName},
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: ZestColors.slate800,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ZestColors.glassBorder, width: 1),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: ZestColors.slate600,
                  child: Text(
                    user.displayName[0].toUpperCase(),
                    style: const TextStyle(
                      color: ZestColors.lemonGreen,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
                if (user.isOnline)
                  Positioned(
                    bottom: 0, right: 0,
                    child: OnlineDot(isOnline: user.isOnline),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.displayName,
                      style: const TextStyle(
                        color: ZestColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      )),
                  Text(user.username,
                      style: const TextStyle(
                        color: ZestColors.lemonGreenDim,
                        fontSize: 12,
                        fontFamily: 'JetBrainsMono',
                      )),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: ZestColors.lemonGreen.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: ZestColors.lemonGreen.withOpacity(0.30), width: 1),
              ),
              child: const Text(
                'Message',
                style: TextStyle(
                  color: ZestColors.lemonGreen,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(delay: (index * 50).ms, duration: 250.ms)
          .slideX(begin: 0.04, end: 0),
    );
  }
}

class _SearchHint extends StatelessWidget {
  const _SearchHint();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_rounded,
              size: 56, color: ZestColors.textTertiary.withOpacity(0.4)),
          const SizedBox(height: 12),
          const Text(
            'Find people by @username',
            style: TextStyle(color: ZestColors.textTertiary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🔭', style: TextStyle(fontSize: 48)),
          SizedBox(height: 12),
          Text(
            'No users found',
            style: TextStyle(color: ZestColors.textSecondary, fontSize: 15),
          ),
          SizedBox(height: 4),
          Text(
            'Try a different username or name',
            style: TextStyle(color: ZestColors.textTertiary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _LoadingShimmer extends StatelessWidget {
  const _LoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      itemCount: 5,
      itemBuilder: (_, i) => Container(
        margin: const EdgeInsets.only(bottom: 6),
        height: 72,
        decoration: BoxDecoration(
          color: ZestColors.slate800,
          borderRadius: BorderRadius.circular(16),
        ),
      )
          .animate(onPlay: (c) => c.repeat())
          .shimmer(
            duration: 1200.ms,
            color: ZestColors.slate700,
          ),
    );
  }
}
