import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:gig_task_manager/providers/auth_provider.dart' as app_auth;
import 'package:gig_task_manager/screens/auth/login_screen.dart';
import 'package:gig_task_manager/services/auth_service.dart';

class _FakeAuthService implements AuthService {
  final _controller = StreamController<User?>.broadcast();

  @override
  Stream<User?> authStateChanges() => _controller.stream;

  @override
  User? get currentUser => null;

  @override
  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<UserCredential> login({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<void> logout() => throw UnimplementedError();
}

void main() {
  testWidgets('Login screen builds', (WidgetTester tester) async {
    final fake = _FakeAuthService();
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => app_auth.AuthProvider(fake),
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    expect(find.text('Welcome back'), findsOneWidget);
    await fake._controller.close();
  });
}
