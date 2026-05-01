// lib/core/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/status/screens/status_viewer_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/search/screens/search_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (ctx, state) => _fade(const LoginScreen(), state),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder: (ctx, state) => _fade(const RegisterScreen(), state),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        pageBuilder: (ctx, state) => _fade(const HomeScreen(), state),
        routes: [
          GoRoute(
            path: 'search',
            name: 'search',
            pageBuilder: (ctx, state) =>
                _slide(const SearchScreen(), state),
          ),
          GoRoute(
            path: 'chat/:peerId',
            name: 'chat',
            pageBuilder: (ctx, state) {
              final peerId = state.pathParameters['peerId']!;
              final peerName =
                  state.uri.queryParameters['name'] ?? 'Chat';
              return _slide(
                ChatScreen(peerId: peerId, peerDisplayName: peerName),
                state,
              );
            },
          ),
          GoRoute(
            path: 'status/:statusId',
            name: 'status',
            pageBuilder: (ctx, state) {
              final statusId = state.pathParameters['statusId']!;
              return _fade(
                StatusViewerScreen(statusId: statusId),
                state,
              );
            },
          ),
          GoRoute(
            path: 'profile',
            name: 'profile',
            pageBuilder: (ctx, state) => _slide(const ProfileScreen(), state),
          ),
        ],
      ),
    ],
    errorBuilder: (ctx, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.uri}'),
      ),
    ),
  );
});

CustomTransitionPage<void> _fade(Widget child, GoRouterState state) =>
    CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (ctx, anim, _, c) =>
          FadeTransition(opacity: anim, child: c),
    );

CustomTransitionPage<void> _slide(Widget child, GoRouterState state) =>
    CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 320),
      transitionsBuilder: (ctx, anim, _, c) {
        final tween = Tween(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(position: anim.drive(tween), child: c);
      },
    );
