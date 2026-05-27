import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:gomandap_common/domain/models/vendor_application.dart';
import 'package:gomandap_common/data/repository_impl/vendor_application_repository.dart';

// ─── Predefined correction fields ────────────────────────────────────────────
const _correctionOptions = [
  'GSTIN format is invalid',
  'Portfolio photos are missing or unclear',
  'Price range appears unrealistic',
  'KYC document is unreadable or expired',
  'Business name mismatch with documents',
  'Category selection is incomplete',
];

// ─── Filter state ─────────────────────────────────────────────────────────────
enum _FilterTab { all, pending, needsCorrection, approved, rejected }

class AdminVendorApprovalScreen extends ConsumerStatefulWidget {
  const AdminVendorApprovalScreen({super.key});

  @override
  ConsumerState<AdminVendorApprovalScreen> createState() =>
      _AdminVendorApprovalScreenState();
}

class _AdminVendorApprovalScreenState
    extends ConsumerState<AdminVendorApprovalScreen> {
  _FilterTab _filter = _FilterTab.pending;
  String? _expandedCardId;        // which card has action buttons open
  String? _correctionCardId;      // which card has correction form expanded
  final Set<String> _selectedCorrections = {};
  final _customNoteCtrl = TextEditingController();
  bool _isActioning = false;

  @override
  void dispose() {
    _customNoteCtrl.dispose();
    super.dispose();
  }

  // ─── Filter helper ─────────────────────────────────────────────────────────

  List<VendorApplication> _applyFilter(List<VendorApplication> all) {
    switch (_filter) {
      case _FilterTab.pending:
        return all.where((a) => a.status == VendorAppStatus.pending).toList();
      case _FilterTab.needsCorrection:
        return all
            .where((a) => a.status == VendorAppStatus.needsCorrection)
            .toList();
      case _FilterTab.approved:
        return all.where((a) => a.status == VendorAppStatus.approved).toList();
      case _FilterTab.rejected:
        return all.where((a) => a.status == VendorAppStatus.rejected).toList();
      case _FilterTab.all:
        return all;
    }
  }

  // ─── Actions ───────────────────────────────────────────────────────────────

  Future<void> _approve(String id) async {
    HapticFeedback.mediumImpact();
    setState(() => _isActioning = true);
    final repo = ref.read(vendorApplicationRepositoryProvider);
    await repo.updateStatus(
        applicationId: id, status: VendorAppStatus.approved);
    setState(() {
      _isActioning = false;
      _expandedCardId = null;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_rounded,
              color: Colors.white, size: 16),
          const SizedBox(width: 8),
          const Text('Vendor Approved & Notified!',
              style: TextStyle(fontWeight: FontWeight.w700)),
        ]),
        backgroundColor: GomandapTokens.emeraldGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _sendCorrection(String id) async {
    final notes = <CorrectionNote>[];
    for (final opt in _selectedCorrections) {
      notes.add(CorrectionNote(field: opt, message: opt));
    }
    if (_customNoteCtrl.text.trim().isNotEmpty) {
      notes.add(CorrectionNote(
          field: 'Custom Note', message: _customNoteCtrl.text.trim()));
    }
    if (notes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Select at least one correction reason.'),
        backgroundColor: GomandapTokens.warning,
      ));
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() => _isActioning = true);
    final repo = ref.read(vendorApplicationRepositoryProvider);
    await repo.updateStatus(
        applicationId: id,
        status: VendorAppStatus.needsCorrection,
        correctionNotes: notes);
    setState(() {
      _isActioning = false;
      _correctionCardId = null;
      _expandedCardId = null;
      _selectedCorrections.clear();
      _customNoteCtrl.clear();
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.send_rounded, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            'Correction request sent (${notes.length} issue${notes.length > 1 ? 's' : ''})',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ]),
        backgroundColor: GomandapTokens.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _reject(String id, String businessName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: GomandapTokens.royalNavyLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Reject Application',
            style: GoogleFonts.outfit(
                color: Colors.white, fontWeight: FontWeight.w900)),
        content: Text(
          'Are you sure you want to reject $businessName?\nThis action can be reversed later.',
          style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: TextStyle(color: Colors.white54,
                    fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: GomandapTokens.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Text('Reject',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    HapticFeedback.heavyImpact();
    setState(() => _isActioning = true);
    final repo = ref.read(vendorApplicationRepositoryProvider);
    await repo.updateStatus(
      applicationId: id,
      status: VendorAppStatus.rejected,
      correctionNotes: [
        const CorrectionNote(field: 'Status', message: 'Application rejected by admin')
      ],
    );
    setState(() {
      _isActioning = false;
      _expandedCardId = null;
    });
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final applicationsAsync = ref.watch(allVendorApplicationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        _buildHeader(applicationsAsync),
        const SizedBox(height: 20),

        // Filter tabs
        _buildFilterTabs(applicationsAsync),
        const SizedBox(height: 24),

        // Applications list
        applicationsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(
                color: GomandapTokens.champagneGoldStart),
          ),
          error: (e, _) => _buildEmptyState(
              'Connection error: $e',
              Icons.wifi_off_rounded),
          data: (apps) {
            final filtered = _applyFilter(apps);
            if (filtered.isEmpty) {
              return _buildEmptyState(
                _filter == _FilterTab.pending
                    ? 'No pending applications 🎉\nAll caught up!'
                    : 'No applications in this category.',
                Icons.check_circle_outline_rounded,
              );
            }
            return Column(
              children: filtered
                  .map((app) => _buildApplicationCard(app))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeader(AsyncValue<List<VendorApplication>> asyncApps) {
    final pendingCount = asyncApps.valueOrNull
        ?.where((a) => a.status == VendorAppStatus.pending)
        .length ?? 0;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Vendor Onboarding 🏆',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: GomandapTokens.royalNavy)),
                  if (pendingCount > 0) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: GomandapTokens.warning,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$pendingCount Pending',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Review, approve, or send back vendor applications. Changes sync in real-time.',
                style: TextStyle(fontSize: 13, color: GomandapTokens.slateGray),
              ),
            ],
          ),
        ),
        // Realtime indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: GomandapTokens.emeraldGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: GomandapTokens.emeraldGreen.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: GomandapTokens.emeraldGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              const Text(
                'Live Sync',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: GomandapTokens.emeraldGreen),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs(AsyncValue<List<VendorApplication>> asyncApps) {
    final apps = asyncApps.valueOrNull ?? [];
    int _count(_FilterTab f) => _applyFilter(apps)
        .where((a) {
          switch (f) {
            case _FilterTab.all:            return true;
            case _FilterTab.pending:        return a.status == VendorAppStatus.pending;
            case _FilterTab.needsCorrection: return a.status == VendorAppStatus.needsCorrection;
            case _FilterTab.approved:       return a.status == VendorAppStatus.approved;
            case _FilterTab.rejected:       return a.status == VendorAppStatus.rejected;
          }
        })
        .length;

    final tabs = [
      (_FilterTab.all,             'All',         null),
      (_FilterTab.pending,         'Pending',     GomandapTokens.warning),
      (_FilterTab.needsCorrection, 'Correction',  GomandapTokens.error),
      (_FilterTab.approved,        'Approved',    GomandapTokens.emeraldGreen),
      (_FilterTab.rejected,        'Rejected',    GomandapTokens.slateGray),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.map((t) {
          final isSelected = _filter == t.$1;
          final count = apps.isEmpty ? 0 :
              apps.where((a) {
                switch (t.$1) {
                  case _FilterTab.all:            return true;
                  case _FilterTab.pending:        return a.status == VendorAppStatus.pending;
                  case _FilterTab.needsCorrection: return a.status == VendorAppStatus.needsCorrection;
                  case _FilterTab.approved:       return a.status == VendorAppStatus.approved;
                  case _FilterTab.rejected:       return a.status == VendorAppStatus.rejected;
                }
              }).length;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _filter = t.$1);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (t.$3 ?? GomandapTokens.royalNavy)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : GomandapTokens.lightSlate,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      t.$2,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : GomandapTokens.slateGray,
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.25)
                              : (t.$3 ?? GomandapTokens.royalNavy)
                                  .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: isSelected
                                ? Colors.white
                                : (t.$3 ?? GomandapTokens.royalNavy),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildApplicationCard(VendorApplication app) {
    final isExpanded = _expandedCardId == app.id;
    final showCorrection = _correctionCardId == app.id;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _statusBorderColor(app.status),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: GomandapTokens.royalNavy.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main card header
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status + time row
                Row(
                  children: [
                    _statusChip(app.status),
                    const Spacer(),
                    Text(
                      _timeAgo(app.submittedAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: GomandapTokens.slateGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Business name + location
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: GomandapTokens.royalNavy.withValues(alpha: 0.07),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          app.businessName.isNotEmpty
                              ? app.businessName[0].toUpperCase()
                              : 'V',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: GomandapTokens.royalNavy,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            app.businessName,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: GomandapTokens.royalNavy,
                            ),
                          ),
                          Text(
                            '${app.ownerName} · ${app.city}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: GomandapTokens.slateGray,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '📞 ${app.phone}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: GomandapTokens.slateGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Category chips
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: app.categories.map((cat) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: GomandapTokens.softMist,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cat,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: GomandapTokens.royalNavy,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),

                // KYC + Price row
                Row(
                  children: [
                    if (app.gstin != null && app.gstin!.isNotEmpty)
                      _infoChip(
                          Icons.receipt_long_rounded,
                          app.gstin!,
                          GomandapTokens.emeraldGreen),
                    const SizedBox(width: 8),
                    _infoChip(
                      Icons.currency_rupee_rounded,
                      '₹${_fmtPrice(app.priceMin)} – ₹${_fmtPrice(app.priceMax)}',
                      GomandapTokens.champagneGoldStart,
                    ),
                    const SizedBox(width: 8),
                    if (app.portfolioUrls.isNotEmpty)
                      _infoChip(
                        Icons.photo_library_rounded,
                        '${app.portfolioUrls.length} photos',
                        GomandapTokens.info,
                      ),
                  ],
                ),

                // KYC doc link
                if (app.kycDocUrl != null) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('KYC Doc: ${app.kycDocUrl}'),
                        behavior: SnackBarBehavior.floating,
                      ));
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.attach_file_rounded,
                            size: 14, color: GomandapTokens.champagneGoldStart),
                        const SizedBox(width: 6),
                        Text(
                          'View KYC Document →',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: GomandapTokens.champagneGoldEnd,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Correction notes (if any)
                if (app.correctionNotes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: GomandapTokens.errorLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Correction Notes Sent:',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: GomandapTokens.error)),
                        const SizedBox(height: 6),
                        ...app.correctionNotes.map((n) => Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Row(
                                children: [
                                  const Icon(Icons.arrow_right_rounded,
                                      size: 14, color: GomandapTokens.error),
                                  Expanded(
                                    child: Text(
                                      n.message,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: GomandapTokens.error),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 14),

                // Action row (only for non-approved/rejected)
                if (app.status != VendorAppStatus.approved &&
                    app.status != VendorAppStatus.rejected)
                  _buildActionRow(app),
              ],
            ),
          ),

          // Expandable correction form
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: showCorrection ? _buildCorrectionForm(app) : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(VendorApplication app) {
    return Row(
      children: [
        // Approve
        Expanded(
          child: GestureDetector(
            onTap: _isActioning ? null : () => _approve(app.id),
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: GomandapTokens.emeraldGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white),
                  const SizedBox(width: 6),
                  Text('Approve',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Send for Correction
        Expanded(
          child: GestureDetector(
            onTap: _isActioning
                ? null
                : () {
                    setState(() {
                      _correctionCardId =
                          _correctionCardId == app.id ? null : app.id;
                      _selectedCorrections.clear();
                      _customNoteCtrl.clear();
                    });
                  },
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: GomandapTokens.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: GomandapTokens.warning.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.edit_note_rounded,
                      size: 14, color: GomandapTokens.warning),
                  const SizedBox(width: 6),
                  Text('Correct',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: GomandapTokens.warning)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Reject
        GestureDetector(
          onTap: _isActioning
              ? null
              : () => _reject(app.id, app.businessName),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: GomandapTokens.errorLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.close_rounded,
                size: 16, color: GomandapTokens.error),
          ),
        ),
      ],
    );
  }

  Widget _buildCorrectionForm(VendorApplication app) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GomandapTokens.warningLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: GomandapTokens.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Correction Issues',
              style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: GomandapTokens.royalNavy)),
          const SizedBox(height: 10),

          // Predefined checkboxes
          ..._correctionOptions.map((opt) {
            final checked = _selectedCorrections.contains(opt);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (checked) {
                    _selectedCorrections.remove(opt);
                  } else {
                    _selectedCorrections.add(opt);
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: checked
                            ? GomandapTokens.warning
                            : Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: checked
                              ? GomandapTokens.warning
                              : GomandapTokens.slateGray
                                  .withValues(alpha: 0.4),
                        ),
                      ),
                      child: checked
                          ? const Icon(Icons.check_rounded,
                              size: 12, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        opt,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: GomandapTokens.royalNavy,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 10),

          // Custom note field
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: GomandapTokens.warning.withValues(alpha: 0.3)),
            ),
            child: TextField(
              controller: _customNoteCtrl,
              maxLines: 2,
              style: const TextStyle(
                  fontSize: 12, color: GomandapTokens.royalNavy),
              decoration: const InputDecoration(
                hintText: 'Additional note to vendor (optional)…',
                hintStyle:
                    TextStyle(fontSize: 12, color: GomandapTokens.slateGray),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(10),
              ),
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _correctionCardId = null;
                      _selectedCorrections.clear();
                      _customNoteCtrl.clear();
                    });
                  },
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('Cancel',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: GomandapTokens.slateGray)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: _isActioning ? null : () => _sendCorrection(app.id),
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: GomandapTokens.warning,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send_rounded,
                            size: 14, color: Colors.white),
                        SizedBox(width: 6),
                        Text('Send Correction Request',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: GomandapTokens.lightSlate),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 14,
                color: GomandapTokens.slateGray,
                fontWeight: FontWeight.w600,
                height: 1.5),
          ),
        ],
      ),
    );
  }

  // ─── Small helpers ──────────────────────────────────────────────────────────

  Widget _statusChip(VendorAppStatus status) {
    final Map<VendorAppStatus, (String, Color)> map = {
      VendorAppStatus.pending: ('● Pending Review', GomandapTokens.warning),
      VendorAppStatus.underReview: ('◎ Under Review', GomandapTokens.info),
      VendorAppStatus.needsCorrection: ('⚠ Needs Correction', GomandapTokens.error),
      VendorAppStatus.approved: ('✓ Approved', GomandapTokens.emeraldGreen),
      VendorAppStatus.rejected: ('✕ Rejected', GomandapTokens.slateGray),
    };
    final (label, color) = map[status]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color)),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }

  Color _statusBorderColor(VendorAppStatus status) {
    switch (status) {
      case VendorAppStatus.pending:        return GomandapTokens.warning.withValues(alpha: 0.3);
      case VendorAppStatus.underReview:    return GomandapTokens.info.withValues(alpha: 0.3);
      case VendorAppStatus.needsCorrection: return GomandapTokens.error.withValues(alpha: 0.3);
      case VendorAppStatus.approved:       return GomandapTokens.emeraldGreen.withValues(alpha: 0.3);
      case VendorAppStatus.rejected:       return GomandapTokens.lightSlate;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  String _fmtPrice(int val) {
    if (val >= 100000) return '${(val / 100000).toStringAsFixed(1)}L';
    if (val >= 1000) return '${(val / 1000).toStringAsFixed(0)}K';
    return '$val';
  }
}
