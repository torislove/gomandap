import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';

class ClientLifecycleTab extends ConsumerStatefulWidget {
  const ClientLifecycleTab({super.key});

  @override
  ConsumerState<ClientLifecycleTab> createState() => _ClientLifecycleTabState();
}

class _ClientLifecycleTabState extends ConsumerState<ClientLifecycleTab> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Client Lifecycle CRM 👥', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy)),
        const SizedBox(height: 6),
        const Text('Monitor client intent, cart abandonment, and trigger promotional campaigns or push notifications.', style: TextStyle(fontSize: 13, color: GomandapTokens.slateGray)),
        const SizedBox(height: 24),
        
        // Stats Row
        Row(
          children: [
            _buildStatCard('124', 'New Signups Today', Icons.person_add_rounded, GomandapTokens.emeraldGreen),
            const SizedBox(width: 16),
            _buildStatCard('38', 'Abandoned Carts', Icons.shopping_cart_checkout_rounded, GomandapTokens.warning),
            const SizedBox(width: 16),
            _buildStatCard('8.5%', 'Conversion Rate', Icons.analytics_rounded, GomandapTokens.champagneGoldStart),
          ],
        ),
        const SizedBox(height: 32),
        
        // High Intent Clients Table
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: GomandapTokens.lightSlate),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('High Intent Clients (Action Required)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
              const SizedBox(height: 16),
              _buildClientRow('Rahul Sharma', 'Cart Abandoned (Grand Palace)', '2 hours ago', true),
              const Divider(height: 32),
              _buildClientRow('Priya Patel', 'Saved 5 Photographers', '1 day ago', false),
            ],
          ),
        ),
        const SizedBox(height: 32),
        
        // Push Notification Tool
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: GomandapTokens.lightSlate),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Direct Push Notification Engine', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Notification Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Notification Body',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Push Notification Sent to targeted users!')));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: GomandapTokens.royalNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.send_rounded, size: 16),
                label: const Text('Send Broadcast', style: TextStyle(fontWeight: FontWeight.w800)),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String val, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: GomandapTokens.lightSlate),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(val, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy)),
                  Text(label, style: const TextStyle(fontSize: 11, color: GomandapTokens.slateGray, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientRow(String name, String intent, String lastActive, bool isUrgent) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: GomandapTokens.softMist,
          child: Text(name[0], style: const TextStyle(color: GomandapTokens.royalNavy, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: GomandapTokens.royalNavy)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.timeline_rounded, size: 12, color: isUrgent ? GomandapTokens.error : GomandapTokens.emeraldGreen),
                  const SizedBox(width: 4),
                  Text(intent, style: TextStyle(fontSize: 12, color: isUrgent ? GomandapTokens.error : GomandapTokens.emeraldGreen, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
        Text(lastActive, style: const TextStyle(fontSize: 11, color: GomandapTokens.slateGray)),
        const SizedBox(width: 24),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: GomandapTokens.champagneGoldStart,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Send 10% Promo', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
