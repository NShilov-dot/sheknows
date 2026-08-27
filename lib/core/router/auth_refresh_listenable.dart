import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sheknows/features/auth/presentation/bloc/auth_state.dart';

enum _AuthRouteStatus { pending, authenticated, unauthenticated }

class AuthRefreshListenable extends ChangeNotifier {
  AuthRefreshListenable(this._authBloc) {
    _subscription = _authBloc.stream.listen(_onAuthStateChanged);
  }

  final AuthBloc _authBloc;
  late final StreamSubscription<AuthState> _subscription;
  _AuthRouteStatus _status = _AuthRouteStatus.pending;

  void _onAuthStateChanged(AuthState state) {
    if (state is AuthInitial || state is AuthLoading) {
      return;
    }

    final nextStatus = state is AuthAuthenticated
        ? _AuthRouteStatus.authenticated
        : _AuthRouteStatus.unauthenticated;

    if (_status == nextStatus) {
      return;
    }

    _status = nextStatus;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
