
import 'package:flutter_riverpod/flutter_riverpod.dart';
enum AuthStateStatus { initial, loading, codeSent, authenticated, error }
class AuthState {
  final AuthStateStatus status;
  AuthState({this.status = AuthStateStatus.initial});
}
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());
  void sendOtp(String phone) => state = AuthState(status: AuthStateStatus.codeSent);
  void verifyOtp(String code) => state = AuthState(status: AuthStateStatus.authenticated);
}
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());
