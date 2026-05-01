// lib/features/profile/screens/profile_screen.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _displayName = 'Ikegbune';
  String _username = '@ikegbune';
  String? _avatarUrl;
  Uint8List? _localAvatarBytes;

  final _picker = ImagePicker();

  Future<void> _changeAvatar() async {
    final source = await _showSourceSheet();
    if (source == null) return;

    final XFile? picked = await _picker.pickImage(source: source);
    if (picked == null) return;

    // Crop
    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Profile Picture',
          toolbarColor: ZestColors.slate800,
          toolbarWidgetColor: ZestColors.lemonGreen,
          activeControlsWidgetColor: ZestColors.lemonGreen,
          backgroundColor: ZestColors.void_black,
        ),
        IOSUiSettings(title: 'Crop Profile Picture'),
        WebUiSettings(context: context),
      ],
    );

    if (cropped == null) return;

    final bytes = await cropped.readAsBytes();
    setState(() {
      _localAvatarBytes = bytes;
      _avatarUrl = null;
    });

    // TODO: upload to CDN and call ApiService().updateProfilePicture(...)
    _showSnack('Profile picture updated!');
  }

  void _removeAvatar() {
    setState(() {
      _localAvatarBytes = null;
      _avatarUrl = null;
    });
    // TODO: call ApiService with empty/null image
    _showSnack('Profile picture removed');
  }

  Future<ImageSource?> _showSourceSheet() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ZestColors.slate800,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: ZestColors.glassBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: ZestColors.slate500,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            _SheetTile(
              icon: Icons.photo_library_outlined,
              label: 'Choose from Gallery',
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            if (!kIsWeb)
              _SheetTile(
                icon: Icons.camera_alt_outlined,
                label: 'Take a Photo',
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            if (_localAvatarBytes != null || _avatarUrl != null)
              _SheetTile(
                icon: Icons.delete_outline_rounded,
                label: 'Remove Photo',
                color: ZestColors.error,
                onTap: () {
                  Navigator.pop(context);
                  _removeAvatar();
                },
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ZestColors.slate700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
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
        title: const Text('Profile'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Edit',
              style: TextStyle(color: ZestColors.lemonGreen),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          const SizedBox(height: 16),

          // ── Avatar
          Center(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: _changeAvatar,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [ZestColors.lemonGreen, Color(0xFF52E5E7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: ZestColors.void_black, width: 3),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: CircleAvatar(
                        backgroundColor: ZestColors.slate700,
                        backgroundImage: _localAvatarBytes != null
                            ? MemoryImage(_localAvatarBytes!)
                            : (_avatarUrl != null
                                ? NetworkImage(_avatarUrl!) as ImageProvider
                                : null),
                        child: (_localAvatarBytes == null && _avatarUrl == null)
                            ? Text(
                                _displayName[0].toUpperCase(),
                                style: const TextStyle(
                                  color: ZestColors.lemonGreen,
                                  fontSize: 40,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: _changeAvatar,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: ZestColors.lemonGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          color: ZestColors.void_black, size: 16),
                    ),
                  ),
                ),
              ],
            ),
          ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Text(
                  _displayName,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  _username,
                  style: const TextStyle(
                    color: ZestColors.lemonGreenDim,
                    fontSize: 14,
                    fontFamily: 'JetBrainsMono',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Stats row
          GlassCard(
            padding: EdgeInsets.zero,
            child: Row(
              children: [
                _StatCell(count: '142', label: 'Chats'),
                _Divider(),
                _StatCell(count: '38', label: 'Stories'),
                _Divider(),
                _StatCell(count: '7', label: 'Days Active'),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 16),

          // ── Settings sections
          _SectionHeader('Account'),
          _SettingsTile(icon: Icons.person_outline_rounded, label: 'Display Name', value: _displayName),
          _SettingsTile(icon: Icons.alternate_email_rounded, label: 'Username', value: _username),
          _SettingsTile(icon: Icons.lock_outline_rounded, label: 'Privacy'),

          const SizedBox(height: 8),
          _SectionHeader('Notifications'),
          _SettingsTile(icon: Icons.notifications_outlined, label: 'Push Notifications'),
          _SettingsTile(icon: Icons.do_not_disturb_on_outlined, label: 'Do Not Disturb'),

          const SizedBox(height: 8),
          _SectionHeader('Appearance'),
          _SettingsTile(icon: Icons.palette_outlined, label: 'Theme'),
          _SettingsTile(icon: Icons.chat_bubble_outline_rounded, label: 'Chat Wallpaper'),

          const SizedBox(height: 24),
          _LogoutButton(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String count;
  final String label;
  const _StatCell({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(count,
                style: const TextStyle(
                  color: ZestColors.lemonGreen,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                )),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                  color: ZestColors.textTertiary,
                  fontSize: 11,
                )),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1, height: 40, color: ZestColors.glassBorder);
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 0, 6),
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: ZestColors.textTertiary,
            fontSize: 11,
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  const _SettingsTile({required this.icon, required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: ZestColors.slate800,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ZestColors.glassBorder, width: 1),
      ),
      child: ListTile(
        leading: Icon(icon, color: ZestColors.lemonGreen, size: 22),
        title: Text(label,
            style: const TextStyle(color: ZestColors.textPrimary, fontSize: 14)),
        trailing: value != null
            ? Text(value!,
                style: const TextStyle(
                    color: ZestColors.textSecondary, fontSize: 13))
            : const Icon(Icons.chevron_right_rounded,
                color: ZestColors.textTertiary),
        onTap: () {},
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: ZestColors.error.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: ZestColors.error.withOpacity(0.30), width: 1),
        ),
        child: const Center(
          child: Text(
            'Sign Out',
            style: TextStyle(
              color: ZestColors.error,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _SheetTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? ZestColors.textPrimary),
      title: Text(label,
          style: TextStyle(color: color ?? ZestColors.textPrimary, fontSize: 15)),
      onTap: onTap,
    );
  }
}
