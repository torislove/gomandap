import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';

class GomandapFooter extends StatelessWidget {
  final void Function(BuildContext context, String route)? onNavigate;

  const GomandapFooter({super.key, this.onNavigate});

  void _navigate(BuildContext context, String route) {
    if (onNavigate != null) {
      onNavigate!(context, route);
    } else {
      Navigator.of(context).pushNamed(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.sizeOf(context).width > 600;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: GomandapTokens.royalNavy,
        border: Border(
          top: BorderSide(color: GomandapTokens.champagneGoldStart, width: 2),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand Header Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.celebration_rounded, color: GomandapTokens.champagneGoldStart, size: 28),
                        const SizedBox(width: 8),
                        const Text(
                          'GoMandap',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: GomandapTokens.champagneGoldStart.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: GomandapTokens.champagneGoldStart.withValues(alpha: 0.4)),
                          ),
                          child: const Text(
                            'PREMIUM 👑',
                            style: TextStyle(
                              color: GomandapTokens.champagneGoldStart,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Social Interactive Row
                    const Row(
                      children: [
                        _SocialIcon(icon: Icons.facebook_rounded),
                        SizedBox(width: 10),
                        _SocialIcon(icon: Icons.camera_alt_rounded), // Instagram
                        SizedBox(width: 10),
                        _SocialIcon(icon: Icons.play_arrow_rounded), // YouTube
                        SizedBox(width: 10),
                        _SocialIcon(icon: Icons.alternate_email_rounded), // Twitter/X
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Uncompromising luxury wedding experiences anchored by milestone-based escrow safety vaults.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 32),

                // Responsive layout: columns or vertical layouts based on viewport width
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildLinksColumn(context)),
                      Expanded(child: _buildCategoriesColumn(context)),
                      Expanded(child: _buildTrustColumn()),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLinksColumn(context),
                      const SizedBox(height: 32),
                      _buildCategoriesColumn(context),
                      const SizedBox(height: 32),
                      _buildTrustColumn(),
                    ],
                  ),
              ],
            ),
          ),

          // Bottom Bar containing copyright and partner guarantees
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              border: const Border(top: BorderSide(color: Colors.white10)),
            ),
            child: Column(
              children: [
                const Text(
                  '© 2026 GoMandap Technologies Private Limited. All rights reserved.',
                  style: TextStyle(fontSize: 10, color: GomandapTokens.slateGray, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  'Escrow accounts managed securely under licensed partner banking institutions.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 9, color: GomandapTokens.slateGray.withValues(alpha: 0.7), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinksColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Navigation',
          style: TextStyle(
            color: GomandapTokens.champagneGoldStart,
            fontWeight: FontWeight.w800,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        _FooterLink(
          label: 'Home Dashboard',
          onTap: () => _navigate(context, '/home'),
        ),
        _FooterLink(
          label: 'Omni Venue Search',
          onTap: () => _navigate(context, '/search'),
        ),
        _FooterLink(
          label: 'My Secure Bookings',
          onTap: () => _navigate(context, '/bookings'),
        ),
        _FooterLink(
          label: 'Become a Partner Vendor',
          onTap: () => _navigate(context, '/become-vendor'),
        ),
      ],
    );
  }

  Widget _buildCategoriesColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Elite Directory Services',
          style: TextStyle(
            color: GomandapTokens.champagneGoldStart,
            fontWeight: FontWeight.w800,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        _FooterLink(
          label: 'Luxury Banquets & Lawns',
          onTap: () => _navigate(context, '/search'),
        ),
        _FooterLink(
          label: 'Candid & Cinematic Photography',
          onTap: () => _navigate(context, '/search'),
        ),
        _FooterLink(
          label: 'Full Sangeet Event Planners',
          onTap: () => _navigate(context, '/search'),
        ),
        _FooterLink(
          label: 'Bridal Makeovers & Airbrush',
          onTap: () => _navigate(context, '/search'),
        ),
      ],
    );
  }

  Widget _buildTrustColumn() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Escrow & Vault Protections',
          style: TextStyle(
            color: GomandapTokens.champagneGoldStart,
            fontWeight: FontWeight.w800,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.shield_rounded, color: GomandapTokens.emeraldGreen, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                '256-Bit Bank-grade SSL Encryption',
                style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.lock_clock_rounded, color: GomandapTokens.emeraldGreen, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                '100% Release Control via Milestones',
                style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.verified_user_rounded, color: GomandapTokens.emeraldGreen, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Verified Vendor Escrow Protection',
                style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        SizedBox(height: 24),
        
        // Customer Support & Care
        Text(
          'Customer Support & Care',
          style: TextStyle(
            color: GomandapTokens.champagneGoldStart,
            fontWeight: FontWeight.w800,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            _SupportPill(icon: Icons.phone_rounded, label: 'Call Support'),
            SizedBox(width: 8),
            _SupportPill(icon: Icons.chat_bubble_rounded, label: 'WhatsApp', isWhatsApp: true),
          ],
        ),
      ],
    );
  }
}

class _FooterLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _FooterLink({required this.label, required this.onTap});

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 150),
            style: TextStyle(
              fontSize: 12,
              color: _isHovered ? GomandapTokens.champagneGoldStart : Colors.white60,
              fontWeight: _isHovered ? FontWeight.w700 : FontWeight.w600,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: _isHovered ? 6 : 0,
                  height: 6,
                  margin: EdgeInsets.only(right: _isHovered ? 8 : 0),
                  decoration: const BoxDecoration(
                    color: GomandapTokens.champagneGoldStart,
                    shape: BoxShape.circle,
                  ),
                ),
                Text(widget.label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialIcon extends StatefulWidget {
  final IconData icon;

  const _SocialIcon({required this.icon});

  @override
  State<_SocialIcon> createState() => _SocialIconState();
}

class _SocialIconState extends State<_SocialIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => HapticFeedback.lightImpact(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isHovered
                ? GomandapTokens.champagneGoldStart.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.05),
            shape: BoxShape.circle,
            border: Border.all(
              color: _isHovered ? GomandapTokens.champagneGoldStart : Colors.white24,
              width: 1,
            ),
          ),
          child: Icon(
            widget.icon,
            size: 16,
            color: _isHovered ? GomandapTokens.champagneGoldStart : Colors.white70,
          ),
        ),
      ),
    );
  }
}

class _SupportPill extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isWhatsApp;

  const _SupportPill({
    required this.icon,
    required this.label,
    this.isWhatsApp = false,
  });

  @override
  State<_SupportPill> createState() => _SupportPillState();
}

class _SupportPillState extends State<_SupportPill> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.isWhatsApp ? GomandapTokens.emeraldGreen : GomandapTokens.champagneGoldStart;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => HapticFeedback.lightImpact(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _isHovered ? themeColor.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered ? themeColor : Colors.white24,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 13,
                color: _isHovered ? themeColor : Colors.white70,
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _isHovered ? themeColor : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
