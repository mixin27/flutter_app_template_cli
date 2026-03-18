import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repository) : super(const ProfileState());

  final ProfileRepository _repository;

  Future<void> loadProfile({bool forceRefresh = false}) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    final result = await _repository.fetchProfile(forceRefresh: forceRefresh);
    _handleResult(result);
  }

  void _handleResult(Result<ProfileResult> result) {
    result.when(
      success: (payload) => emit(
        state.copyWith(
          status: ProfileStatus.ready,
          profile: payload.profile,
          isFromCache: payload.isFromCache,
          errorMessage: null,
        ),
      ),
      failure: (failure) => _emitFailure(failure),
    );
  }

  void _emitFailure(Failure failure) {
    emit(
      state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: failure.message,
      ),
    );
  }
}
