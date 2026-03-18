import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState());

  final AuthRepository _repository;

  Future<void> initialize() async {
    emit(state.copyWith(status: AuthStatus.loading));
    final session = await _repository.getSession();
    if (session == null) {
      emit(state.copyWith(status: AuthStatus.unauthenticated, session: null));
    } else {
      emit(state.copyWith(status: AuthStatus.authenticated, session: session));
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    final result = await _repository.signIn(email: email, password: password);
    _handleResult(result);
  }

  Future<void> signOut() async {
    await _repository.signOut();
    emit(state.copyWith(status: AuthStatus.unauthenticated, session: null));
  }

  void clearError() {
    if (state.errorMessage != null) {
      emit(state.copyWith(errorMessage: null));
    }
  }

  void _handleResult(Result<AuthSession> result) {
    result.when(
      success: (session) => emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          session: session,
          errorMessage: null,
        ),
      ),
      failure: (failure) => _emitFailure(failure),
    );
  }

  void _emitFailure(Failure failure) {
    emit(
      state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: failure.message,
        session: null,
      ),
    );
  }
}
