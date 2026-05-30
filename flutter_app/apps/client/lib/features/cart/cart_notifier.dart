import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home/home_notifier.dart';

class CartItem {
  final VendorSummary vendor;
  final int guestCount;
  final double customPrice;

  const CartItem({
    required this.vendor,
    this.guestCount = 200,
    required this.customPrice,
  });

  CartItem copyWith({
    VendorSummary? vendor,
    int? guestCount,
    double? customPrice,
  }) {
    return CartItem(
      vendor: vendor ?? this.vendor,
      guestCount: guestCount ?? this.guestCount,
      customPrice: customPrice ?? this.customPrice,
    );
  }
}

class CartUiState {
  final List<CartItem> items;
  final bool isLoading;

  const CartUiState({
    this.items = const [],
    this.isLoading = false,
  });

  double get subtotal {
    double total = 0;
    for (final item in items) {
      if (item.vendor.category == 'Venue' || item.vendor.category == 'Catering') {
        total += item.guestCount * item.vendor.basePlatePrice;
      } else {
        total += item.vendor.packagePrice;
      }
    }
    return total;
  }

  double get platformFee => subtotal * 0.02; // 2% platform escrow fee
  double get grandTotal => subtotal + platformFee;

  CartUiState copyWith({
    List<CartItem>? items,
    bool? isLoading,
  }) {
    return CartUiState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CartNotifier extends Notifier<CartUiState> {
  @override
  CartUiState build() => const CartUiState(
    items: [
      CartItem(
        vendor: VendorSummary(
          id: 'v1',
          name: 'Elite Heritage Grand Resort',
          locality: 'Jubilee Hills, Hyderabad',
          rating: 4.9,
          reviewCount: 182,
          basePlatePrice: 1600,
          packagePrice: 500000,
          imageUrls: ['https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800'],
          category: 'Venue',
        ),
        guestCount: 250,
        customPrice: 400000,
      ),
      CartItem(
        vendor: VendorSummary(
          id: 'p1',
          name: 'Lux Wedding Cinema & Studios',
          locality: 'Jubilee Hills, Hyderabad',
          rating: 4.9,
          reviewCount: 240,
          basePlatePrice: 80000,
          packagePrice: 80000,
          imageUrls: ['https://images.unsplash.com/photo-1606216794074-735e91aa2c92?w=800'],
          category: 'Photography',
        ),
        customPrice: 80000,
      ),
    ],
  );

  void addItem(VendorSummary vendor) {
    // Avoid duplicates
    if (state.items.any((item) => item.vendor.id == vendor.id)) return;

    final price = vendor.category == 'Venue' || vendor.category == 'Catering'
        ? vendor.basePlatePrice
        : vendor.packagePrice;

    state = state.copyWith(
      items: [
        ...state.items,
        CartItem(vendor: vendor, customPrice: price),
      ],
    );
  }

  void removeItem(String vendorId) {
    state = state.copyWith(
      items: state.items.where((item) => item.vendor.id != vendorId).toList(),
    );
  }

  void updateGuestCount(String vendorId, int count) {
    state = state.copyWith(
      items: state.items.map((item) {
        if (item.vendor.id == vendorId) {
          return item.copyWith(guestCount: count);
        }
        return item;
      }).toList(),
    );
  }

  void clearCart() {
    state = const CartUiState();
  }
}

final cartNotifierProvider = NotifierProvider<CartNotifier, CartUiState>(
  CartNotifier.new,
);
