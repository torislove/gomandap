import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:gomandap_common/data/repository_impl/vendor_application_repository.dart';

class AdminVendorsScreen extends ConsumerWidget {
  const AdminVendorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendorsAsync = ref.watch(allVendorApplicationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Vendors', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: vendorsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (vendors) {
          if (vendors.isEmpty) {
            return const Center(child: Text('No vendors found.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vendors.length,
            itemBuilder: (context, idx) {
              final v = vendors[idx];
              return Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: GomandapTokens.lightSlate),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(v.businessName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Owner: ${v.ownerName}\nStatus: ${v.status.name}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
