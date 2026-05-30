import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomandap_common/core/supabase/supabase_client.dart';
import 'package:gomandap_common/domain/models/escrow.dart';
import 'package:gomandap_common/data/repository_impl/escrow_repository_impl.dart';
import '../cart/cart_notifier.dart';

class EscrowMilestone {
  final String title;
  final double percentage;
  final double amount;
  final String trigger;
  final String status; // 'Released', 'Locked', 'Held'

  const EscrowMilestone({
    required this.title,
    required this.percentage,
    required this.amount,
    required this.trigger,
    required this.status,
  });
}

class CheckoutUiState {
  final int currentStage; // 0: Date, 1: Customizer, 2: Escrow, 3: Payment
  final DateTime? selectedDate;
  final int guestCount;
  final double basePlatePrice;
  final Map<String, bool> customOptions; // optionId -> enabled
  final bool isLoading;
  final bool isSuccess;

  const CheckoutUiState({
    this.currentStage = 0,
    this.selectedDate,
    this.guestCount = 200,
    this.basePlatePrice = 1200,
    this.customOptions = const {
      'Premium Decor': true,
      'Valet Valet Parking': true,
      'Pre-wedding Shoot': false,
      'Sound & Laser DJ': true,
    },
    this.isLoading = false,
    this.isSuccess = false,
  });

  double get optionsTotal {
    double total = 0;
    if (customOptions['Premium Decor'] == true) total += 60000;
    if (customOptions['Pre-wedding Shoot'] == true) total += 25000;
    if (customOptions['Sound & Laser DJ'] == true) total += 35000;
    return total;
  }

  double get subtotal => (guestCount * basePlatePrice) + optionsTotal;
  double get platformFee => subtotal * 0.02; // 2% GoMandap Escrow fee
  double get grandTotal => subtotal + platformFee;

  List<EscrowMilestone> get milestones {
    final total = grandTotal;
    return [
      EscrowMilestone(
        title: 'Milestone 1: Advance Secure Deposit 🟢',
        percentage: 25.0,
        amount: total * 0.25,
        trigger: 'Released immediately upon booking confirmation',
        status: 'Released',
      ),
      EscrowMilestone(
        title: 'Milestone 2: Pre-Event Verification 🟡',
        percentage: 50.0,
        amount: total * 0.50,
        trigger: 'Locked in Escrow. Released on event morning',
        status: 'Held',
      ),
      EscrowMilestone(
        title: 'Milestone 3: Post-Event Completion 🔴',
        percentage: 25.0,
        amount: total * 0.25,
        trigger: 'Locked in Escrow. Released after client verification',
        status: 'Locked',
      ),
    ];
  }

  CheckoutUiState copyWith({
    int? currentStage,
    DateTime? selectedDate,
    int? guestCount,
    double? basePlatePrice,
    Map<String, bool>? customOptions,
    bool? isLoading,
    bool? isSuccess,
  }) {
    return CheckoutUiState(
      currentStage: currentStage ?? this.currentStage,
      selectedDate: selectedDate ?? this.selectedDate,
      guestCount: guestCount ?? this.guestCount,
      basePlatePrice: basePlatePrice ?? this.basePlatePrice,
      customOptions: customOptions ?? this.customOptions,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class CheckoutNotifier extends Notifier<CheckoutUiState> {
  @override
  CheckoutUiState build() => const CheckoutUiState();

  void setStage(int stage) {
    state = state.copyWith(currentStage: stage);
  }

  void nextStage() {
    if (state.currentStage < 3) {
      state = state.copyWith(currentStage: state.currentStage + 1);
    }
  }

  void prevStage() {
    if (state.currentStage > 0) {
      state = state.copyWith(currentStage: state.currentStage - 1);
    }
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void updateGuestCount(int count) {
    if (count >= 50) {
      state = state.copyWith(guestCount: count);
    }
  }

  void toggleOption(String optionId) {
    final updated = Map<String, bool>.from(state.customOptions);
    updated[optionId] = !(updated[optionId] ?? false);
    state = state.copyWith(customOptions: updated);
  }

  Future<void> submitPayment(List<CartItem> cartItems) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final client = ref.read(supabaseClientProvider);
      final userId = client?.auth.currentUser?.id;
      if (userId != null && client != null) {
        final repo = ref.read(bookingRepositoryProvider);
        
        for (final item in cartItems) {
          final draft = Booking(
            id: '', // Supabase generates this
            clientId: userId,
            vendorId: item.vendor.id,
            vendorName: item.vendor.name,
            vendorCategory: item.vendor.category,
            vendorImageUrl: item.vendor.imageUrls.isNotEmpty ? item.vendor.imageUrls[0] : null,
            eventDate: state.selectedDate ?? DateTime.now().add(const Duration(days: 30)),
            guestCount: item.guestCount,
            totalAmount: state.grandTotal, // Simplified for single vendor checkout
            status: 'confirmed',
            createdAt: DateTime.now(),
          );
          await repo.createBooking(draft);
        }
      }
    } catch (e) {
      debugPrint('Supabase Booking Error: $e');
    }

    await Future.delayed(const Duration(milliseconds: 1500));
    state = state.copyWith(
      isLoading: false,
      isSuccess: true,
    );
  }
}

final checkoutNotifierProvider = NotifierProvider<CheckoutNotifier, CheckoutUiState>(
  CheckoutNotifier.new,
);
