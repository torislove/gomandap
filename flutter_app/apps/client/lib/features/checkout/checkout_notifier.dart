import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      'Premium Decor': false,
      'Valet Valet Parking': true,
      'Pre-wedding Shoot': false,
      'Sound & Laser DJ': false,
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

class CheckoutNotifier extends StateNotifier<CheckoutUiState> {
  CheckoutNotifier() : super(const CheckoutUiState());

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

  Future<void> submitPayment() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 2000));
    state = state.copyWith(
      isLoading: false,
      isSuccess: true,
    );
  }

  void reset() {
    state = const CheckoutUiState();
  }
}

final checkoutNotifierProvider = StateNotifierProvider<CheckoutNotifier, CheckoutUiState>(
  (ref) => CheckoutNotifier(),
);
