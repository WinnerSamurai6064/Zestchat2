# ZestChat — Flutter Web

> Hyper-optimized, web-first chat app fusing WhatsApp + Telegram + Instagram.  
> Backend: Rust / Axum at `https://api1.layzur.qzz.io`  
> Deployment: GitHub Pages via GitHub Actions

---

## File Tree

```
zestchat/
├── .github/
│   └── workflows/
│       └── flutter-web.yml          ← CI/CD: build + deploy to gh-pages
│
├── assets/
│   ├── fonts/                       ← Syne + JetBrainsMono (download separately)
│   ├── images/
│   ├── icons/
│   ├── animations/                  ← Lottie JSONs
│   └── wallpapers/                  ← Chat background assets
│
├── lib/
│   ├── main.dart                    ← App entry point (ProviderScope + GoRouter)
│   │
│   ├── core/
│   │   ├── theme/
│   │   │   └── app_theme.dart       ← ZestColors, GlassStyle, AppTheme.dark
│   │   ├── models/
│   │   │   └── models.dart          ← ZestUser, ChatMessage, Conversation, UserStatus
│   │   ├── services/
│   │   │   └── api_service.dart     ← All Rust/Axum endpoints (x-trace-id logging)
│   │   └── router/
│   │       └── app_router.dart      ← GoRouter config (fade + slide transitions)
│   │
│   ├── shared/
│   │   └── widgets/
│   │       └── glass_widgets.dart   ← GlassCard, VoiceStatusBanner, UnreadBadge,
│   │                                   OnlineDot, ZestBottomNavBar
│   │
│   └── features/
│       ├── auth/
│       │   └── screens/
│       │       └── login_screen.dart        ← LoginScreen + RegisterScreen
│       ├── home/
│       │   └── screens/
│       │       └── home_screen.dart         ← ChatsTab (status row + conversation list)
│       │                                       FeedTab (statuses + recommendations grid)
│       ├── chat/
│       │   └── screens/
│       │       └── chat_screen.dart         ← ChatScreen (wallpaper, bubbles, input bar,
│       │                                       self-destruct toast, voice record)
│       ├── status/
│       │   └── screens/
│       │       └── status_viewer_screen.dart ← StatusViewerScreen (image + voice banner)
│       ├── profile/
│       │   └── screens/
│       │       └── profile_screen.dart      ← ProfileScreen (avatar crop/remove,
│       │                                       settings tiles, stats)
│       └── search/
│           └── screens/
│               └── search_screen.dart       ← SearchScreen (@username search, debounce)
│
└── pubspec.yaml
```

---

## API Endpoints Implemented

| Route | Method | Description |
|-------|--------|-------------|
| `/api/auth/register` | POST | Register new user |
| `/api/auth/login` | POST | Login, returns token |
| `/api/profile/update` | POST | Update profile picture (overwrites old) |
| `/api/profile/search` | GET | Search user by @username |
| `/api/content/share` | POST | Post image or voice_status (24h TTL) |
| `/api/content/feed` | GET | Fetch statuses + recommendations |
| `/api/chat/text` | POST | Send text message (7d joke warning) |
| `/api/chat/voice` | POST | Send voice note .amr (48h TTL) |
| `/api/conversations` | GET | List all conversations |
| `/api/chat/history` | GET | Paginated message history |

All responses log `x-trace-id` to the Flutter console via `dart:developer`.

---

## Key Design Decisions

- **Glassmorphism everywhere**: `BackdropFilter` + `ImageFilter.blur` + translucent containers with `glassBorder`.
- **VoiceStatusBanner**: The floating curved translucent banner for voice statuses, used inside `StatusViewerScreen`.
- **Self-destruct toast**: Shown exactly once (first text message sent), dismissible, styled with `GlassCard`.
- **Image cropper**: Triggered on profile picture change. Uses `image_cropper` with 1:1 aspect lock.
- **Wallpaper**: Dot-grid `CustomPainter` over a dark radial gradient in `ChatScreen`.
- **Fonts**: Syne (display/UI) + JetBrainsMono (timestamps, usernames).

---

## Setup


```bash
# Install Flutter 3.22+ then:
flutter pub get

# Download fonts from Google Fonts and place in assets/fonts/
# Required: Syne (Regular/Medium/Bold/ExtraBold), JetBrainsMono (Regular/Medium)

# Run web locally
flutter run -d chrome --web-renderer canvaskit

# Build for production
flutter build web --release --web-renderer canvaskit
```

---

## CI/CD

Push to `main` → GitHub Actions automatically builds and deploys to **gh-pages**.  
Enable GitHub Pages in repo Settings → Pages → Source: `gh-pages` branch.
