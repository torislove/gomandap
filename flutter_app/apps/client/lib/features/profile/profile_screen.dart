import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:gomandap_common/auth/auth_notifier.dart';
import '../../core/i18n/i18n_notifier.dart';
import 'package:gomandap_common/presentation/widgets/gomandap_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GomandapScreen(
      backgroundColor: GomandapTokens.pearlWhite,
      useHorizontalPadding: false,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: GomandapTokens.royalNavy,
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [GomandapTokens.royalNavy, Color(0xFF1E3A5F)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // Decorative circle
                  Positioned(
                    top: -60, right: -40,
                    child: Container(
                      width: 200, height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Profile content
                  Positioned(
                    bottom: 24, left: 20, right: 20,
                    child: Consumer(
                      builder: (context, ref, _) {
                        final isGuest = ref.watch(authNotifierProvider).isGuest;
                        // For a real user, we could pull the phone number from Supabase
                        // final client = ref.watch(supabaseClientProvider);
                        // final phone = client?.auth.currentUser?.phone;
                        
                        final displayName = isGuest ? 'Guest User' : 'Gomandap User';
                        final displayPhone = isGuest ? 'Login to unlock features' : '+91 XXXXXXXX';
                        final initial = isGuest ? 'G' : 'U';

                        return Row(
                          children: [
                            Container(
                              width: 72, height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [GomandapTokens.champagneGoldStart, GomandapTokens.champagneGoldEnd],
                                ),
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Center(
                                child: Text(initial, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(displayName,
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                                  const SizedBox(height: 4),
                                  Text(displayPhone,
                                    style: const TextStyle(fontSize: 13, color: Colors.white70)),
                                  const SizedBox(height: 8),
                                  if (!isGuest)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: GomandapTokens.champagneGoldStart.withValues(alpha: 0.25),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: GomandapTokens.champagneGoldStart.withValues(alpha: 0.5)),
                                      ),
                                      child: const Text('Planning Wedding 👑',
                                        style: TextStyle(fontSize: 11, color: GomandapTokens.champagneGoldStart, fontWeight: FontWeight.w700)),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),

          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),
              // Quick stats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _QuickStat('3', ref.t('profile.bookings')),
                    const SizedBox(width: 12),
                    _QuickStat('8', ref.t('profile.wishlisted')),
                    const SizedBox(width: 12),
                    _QuickStat('₹6.3L', ref.t('profile.total_spent')),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Gold Gradient Vendor Onboarding Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () {
                    context.push('/become-vendor');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          GomandapTokens.champagneGoldStart,
                          GomandapTokens.champagneGoldEnd,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: GomandapTokens.champagneGoldStart.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.storefront_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ref.t('profile.become_vendor'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ref.t('profile.become_vendor_sub'),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Menu sections
              _MenuSection(
                title: ref.t('profile.my_activity'),
                items: [
                  _MenuItem(icon: Icons.favorite_rounded, iconColor: const Color(0xFFE11D48), label: ref.t('profile.my_wishlist'), onTap: () => context.push('/wishlist')),
                  _MenuItem(icon: Icons.receipt_long_rounded, iconColor: GomandapTokens.royalNavy, label: ref.t('profile.my_bookings'), onTap: () => context.go('/bookings')),
                  _MenuItem(icon: Icons.chat_bubble_rounded, iconColor: GomandapTokens.emeraldGreen, label: ref.t('profile.messages'), badge: '2', onTap: () {}),
                ],
              ),
              const SizedBox(height: 16),

              _MenuSection(
                title: ref.t('profile.account'),
                items: [
                  _MenuItem(icon: Icons.person_outline_rounded, iconColor: GomandapTokens.royalNavy, label: ref.t('profile.edit_profile'), onTap: () {}),
                  _MenuItem(icon: Icons.notifications_none_rounded, iconColor: GomandapTokens.warning, label: ref.t('profile.notifications'), onTap: () {}),
                  _MenuItem(icon: Icons.location_on_outlined, iconColor: const Color(0xFF3B82F6), label: ref.t('profile.saved_addresses'), onTap: () {}),
                ],
              ),
              const SizedBox(height: 16),

              _MenuSection(
                title: ref.t('profile.help_support'),
                items: [
                  _MenuItem(icon: Icons.help_outline_rounded, iconColor: GomandapTokens.slateGray, label: ref.t('profile.help_center'), onTap: () {}),
                  _MenuItem(icon: Icons.privacy_tip_outlined, iconColor: GomandapTokens.slateGray, label: ref.t('profile.privacy_policy'), onTap: () {}),
                  _MenuItem(icon: Icons.star_border_rounded, iconColor: GomandapTokens.champagneGoldStart, label: ref.t('profile.rate_app'), onTap: () {}),
                ],
              ),
              const SizedBox(height: 16),

              // Logout
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),                  child: GestureDetector(
                  onTap: () => context.go('/login'),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: GomandapTokens.errorLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout_rounded, color: GomandapTokens.error, size: 18),
                        const SizedBox(width: 8),
                        Text(ref.t('profile.sign_out'), style: const TextStyle(color: GomandapTokens.error, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // App version
              Center(
                child: Text(ref.t('profile.app_version'), style: const TextStyle(fontSize: 11, color: GomandapTokens.slateGray)),
              ),
              const SizedBox(height: 120),
            ]),
          ),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String value, label;
  const _QuickStat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: GomandapTokens.lightSlate),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: GomandapTokens.slateGray)),
          ],
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: GomandapTokens.slateGray, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GomandapTokens.lightSlate),
            ),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                final isLast = i == items.length - 1;
                return Column(
                  children: [
                    item.buildTile(context),
                    if (!isLast) const Divider(height: 1, color: GomandapTokens.lightSlate, indent: 56),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? badge;
  final VoidCallback onTap;

  const _MenuItem({required this.icon, required this.iconColor, required this.label, this.badge, required this.onTap});

  Widget buildTile(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: GomandapTokens.royalNavy, fontSize: 14)),
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: const BoxDecoration(color: Color(0xFFE11D48), borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Text(badge!, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
            )
          : const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: GomandapTokens.slateGray),
    );
  }
}

