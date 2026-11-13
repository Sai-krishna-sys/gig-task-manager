import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gig_task_manager/providers/auth_provider.dart' as app_auth;
import 'package:gig_task_manager/services/auth_service.dart';

class _FakeAuthService implements AuthService {
  final _controller = StreamController<User?>.broadcast();
  Exception? registerError;
  Exception? loginError;
  bool logoutThrows = false;

  @override
  Stream<User?> authStateChanges() => _controller.stream;

  @override
  User? get currentUser => null;

  @override
  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (registerError != null) throw registerError!;
    return _FakeUserCredential();
  }

  @override
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    if (loginError != null) throw loginError!;
    return _FakeUserCredential();
  }

  @override
  Future<void> logout() async {
    if (logoutThrows) throw Exception('logout failed');
  }

  void emit(User? user) => _controller.add(user);
}

class _FakeUserCredential implements UserCredential {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  test('AuthProvider maps login failure to friendly message', () async {
    final fake = _FakeAuthService();
    final provider = app_auth.AuthProvider(fake);
    fake.loginError = FirebaseAuthException(code: 'wrong-password');
    final result = await provider.login(email: 'a@b.com', password: 'secret');
    expect(result, isFalse);
    expect(provider.errorMessage, 'Incorrect email or password.');
  });

  test('AuthProvider logout sets error on failure', () async {
    final fake = _FakeAuthService();
    final provider = app_auth.AuthProvider(fake);
    fake.logoutThrows = true;
    await provider.logout();
    expect(provider.errorMessage, 'Logout failed. Please try again.');
  });
}
