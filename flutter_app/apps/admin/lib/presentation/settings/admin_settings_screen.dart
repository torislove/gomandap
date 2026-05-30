import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomandap_common/core/supabase/supabase_client.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/admin_login_screen.dart';

class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy)),
        content: const Text('Are you sure you want to sign out of the admin panel?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: GomandapTokens.error, foregroundColor: Colors.white),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      HapticFeedback.mediumImpact();
      final client = ref.read(supabaseClientProvider);
      if (client != null) {
        await client.auth.signOut();
      }
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
          (_) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e'), backgroundColor: GomandapTokens.error),
        );
      }
    }
  }

  void _showChangePasswordSheet() {
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    bool isLoading = false;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (sheetCtx, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(sheetCtx).viewInsets.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Change Password',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy),
                  ),
                  const SizedBox(height: 6),
                  const Text('Enter your new admin password below.', style: TextStyle(fontSize: 13, color: GomandapTokens.slateGray)),
                  const SizedBox(height: 24),
                  TextField(
                    controller: newPassCtrl,
                    obscureText: obscureNew,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: GomandapTokens.slateGray),
                      suffixIcon: IconButton(
                        icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility, size: 18),
                        onPressed: () => setModalState(() => obscureNew = !obscureNew),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: GomandapTokens.royalNavy, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: confirmPassCtrl,
                    obscureText: obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: GomandapTokens.slateGray),
                      suffixIcon: IconButton(
                        icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility, size: 18),
                        onPressed: () => setModalState(() => obscureConfirm = !obscureConfirm),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: GomandapTokens.royalNavy, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (newPassCtrl.text.isEmpty || newPassCtrl.text != confirmPassCtrl.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Passwords do not match'), backgroundColor: GomandapTokens.error),
                              );
                              return;
                            }
                            setModalState(() => isLoading = true);
                            try {
                              final client = ref.read(supabaseClientProvider);
                              if (client != null) {
                                await client.auth.updateUser(UserAttributes(password: newPassCtrl.text));
                              }
                              if (sheetCtx.mounted && mounted) {
                                Navigator.pop(sheetCtx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Password updated successfully! ✅'),
                                    backgroundColor: GomandapTokens.emeraldGreen,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e'), backgroundColor: GomandapTokens.error),
                                );
                              }
                            } finally {
                              if (mounted) setModalState(() => isLoading = false);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GomandapTokens.royalNavy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isLoading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Update Password', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final client = ref.watch(supabaseClientProvider);
    final isConnected = client != null;
    final userEmail = client?.auth.currentUser?.email ?? 'admin@gomandap.com';

    return Scaffold(
      backgroundColor: GomandapTokens.pearlWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Account Section ─────────────────────────────────────────
              _SectionHeader(title: 'Account'),
              const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.email_outlined,
                iconColor: GomandapTokens.royalNavy,
                title: 'Admin Email',
                subtitle: userEmail,
                trailing: const Icon(Icons.lock_outline_rounded, size: 16, color: GomandapTokens.slateGray),
              ),
              const SizedBox(height: 10),
              _SettingsTile(
                icon: Icons.key_rounded,
                iconColor: GomandapTokens.champagneGoldEnd,
                title: 'Change Password',
                subtitle: 'Update your admin panel password',
                trailing: const Icon(Icons.chevron_right_rounded, color: GomandapTokens.slateGray),
                onTap: _showChangePasswordSheet,
              ),

              const SizedBox(height: 28),

              // ─── Database Section ────────────────────────────────────────
              _SectionHeader(title: 'Database'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: GomandapTokens.lightSlate),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isConnected
                                ? GomandapTokens.emeraldGreen.withValues(alpha: 0.1)
                                : GomandapTokens.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isConnected ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                            color: isConnected ? GomandapTokens.emeraldGreen : GomandapTokens.warning,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isConnected ? 'Connected to Supabase' : 'Offline Mode Active',
                                style: const TextStyle(fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy),
                              ),
                              Text(
                                isConnected ? 'Real-time sync is active' : 'Using local cache data',
                                style: const TextStyle(fontSize: 12, color: GomandapTokens.slateGray),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: isConnected ? GomandapTokens.emeraldGreen : GomandapTokens.warning,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    if (isConnected) ...[
                      const Divider(height: 24),
                      _InfoRow(label: 'Provider', value: 'Supabase PostgreSQL'),
                      const SizedBox(height: 6),
                      _InfoRow(label: 'Status', value: 'Realtime Enabled ✅'),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ─── About Section ───────────────────────────────────────────
              _SectionHeader(title: 'About'),
              const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.celebration_rounded,
                iconColor: GomandapTokens.champagneGoldStart,
                title: 'GoMandap Admin',
                subtitle: 'Version 2.0.0 · Build 2026',
              ),

              const SizedBox(height: 28),

              // ─── Danger Zone ─────────────────────────────────────────────
              _SectionHeader(title: 'Danger Zone', isRed: true),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _handleLogout,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Sign Out of Admin Panel', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: GomandapTokens.error,
                    side: const BorderSide(color: GomandapTokens.error, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isRed;
  const _SectionHeader({required this.title, this.isRed = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: isRed ? GomandapTokens.error : GomandapTokens.slateGray,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: GomandapTokens.lightSlate),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: GomandapTokens.slateGray)),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: GomandapTokens.slateGray)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: GomandapTokens.royalNavy)),
      ],
    );
  }
}
