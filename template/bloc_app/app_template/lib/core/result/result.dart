import 'package:equatable/equatable.dart';

import '../errors/failures.dart';

sealed class Result<T> extends Equatable {
  const Result();

  bool get isSuccess;

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  });

  @override
  List<Object?> get props => [];

  static Result<T> success<T>(T data) => Success<T>(data);

  static Result<T> failure<T>(Failure failure) => FailureResult<T>(failure);
}

class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;

  @override
  bool get isSuccess => true;

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    return success(data);
  }

  @override
  List<Object?> get props => [data];
}

class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);

  final Failure failure;

  @override
  bool get isSuccess => false;

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    return failure(this.failure);
  }

  @override
  List<Object?> get props => [failure];
}
