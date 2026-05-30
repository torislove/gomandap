
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthStateStatus { initial, loading, codeSent, authenticated, error }
class AuthState {
  final AuthStateStatus status;
  final bool isGuest;
  AuthState({this.status = AuthStateStatus.initial, this.isGuest = false});
}
class AuthNotifier extends Notifier<AuthState> {
  String? _currentPhone;

  @override
  AuthState build() => AuthState();

  Future<void> sendOtp(String phone) async {
    state = AuthState(status: AuthStateStatus.loading, isGuest: false);
    try {
      _currentPhone = phone;
      // Depending on Supabase setup, you might need to append country code if missing
      final formattedPhone = phone.startsWith('+') ? phone : '+91$phone';
      await Supabase.instance.client.auth.signInWithOtp(phone: formattedPhone);
      state = AuthState(status: AuthStateStatus.codeSent, isGuest: false);
    } catch (e) {
      state = AuthState(status: AuthStateStatus.error, isGuest: false);
    }
  }

  Future<void> verifyOtp(String code) async {
    if (_currentPhone == null) return;
    state = AuthState(status: AuthStateStatus.loading, isGuest: false);
    try {
      final formattedPhone = _currentPhone!.startsWith('+') ? _currentPhone! : '+91$_currentPhone';
      await Supabase.instance.client.auth.verifyOTP(
        phone: formattedPhone,
        token: code,
        type: OtpType.sms,
      );
      state = AuthState(status: AuthStateStatus.authenticated, isGuest: false);
    } catch (e) {
      state = AuthState(status: AuthStateStatus.error, isGuest: false);
    }
  }

  void loginAsGuest() => state = AuthState(status: AuthStateStatus.authenticated, isGuest: true);
}
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
