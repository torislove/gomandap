import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';

class GomandapFooter extends StatelessWidget {
  const GomandapFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.sizeOf(context).width > 600;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: GomandapTokens.royalNavy,
        border: const Border(
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
                // Brand Header with Dynamic Sparkles Motif
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
          onTap: () => context.go('/home'),
        ),
        _FooterLink(
          label: 'Omni Venue Search',
          onTap: () => context.go('/search'),
        ),
        _FooterLink(
          label: 'My Secure Bookings',
          onTap: () => context.go('/bookings'),
        ),
        _FooterLink(
          label: 'Become a Partner Vendor',
          onTap: () => context.push('/become-vendor'),
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
          onTap: () => context.push('/search'),
        ),
        _FooterLink(
          label: 'Candid & Cinematic Photography',
          onTap: () => context.push('/search'),
        ),
        _FooterLink(
          label: 'Full Sangeet Event Planners',
          onTap: () => context.push('/search'),
        ),
        _FooterLink(
          label: 'Bridal Makeovers & Airbrush',
          onTap: () => context.push('/search'),
        ),
      ],
    );
  }

  Widget _buildTrustColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Escrow & Vault Protections',
          style: TextStyle(
            color: GomandapTokens.champagneGoldStart,
            fontWeight: FontWeight.w800,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        const Row(
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
        const SizedBox(height: 12),
        const Row(
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
        const SizedBox(height: 12),
        const Row(
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
