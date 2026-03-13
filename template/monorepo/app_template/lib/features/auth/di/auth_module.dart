import 'package:app_logger/app_logger.dart';
import 'package:app_network/app_network.dart';
import 'package:get_it/get_it.dart';

import '../../../app/di/modules/dependency_module.dart';
import '../../../app/di/modules/get_it_extensions.dart';
import '../data/datasources/auth_local_data_source.dart';
import '../data/datasources/auth_remote_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/get_current_session_use_case.dart';
import '../domain/usecases/login_with_method_use_case.dart';
import '../domain/usecases/login_with_password_use_case.dart';
import '../domain/usecases/logout_use_case.dart';
import '../domain/usecases/refresh_session_use_case.dart';
import '../domain/usecases/request_phone_otp_use_case.dart';
import '../domain/usecases/verify_phone_otp_use_case.dart';
import '../presentation/bloc/auth_bloc.dart';

class AuthModule implements DependencyModule {
  const AuthModule();

  @override
  void register(GetIt getIt) {
    getIt
      ..putLazySingletonIfAbsent<AuthLocalDataSource>(
        () => AuthLocalDataSourceImpl(getIt<AuthTokenStore>()),
      )
      ..putLazySingletonIfAbsent<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(getIt<ApiClient>()),
      )
      ..putLazySingletonIfAbsent<AuthRepository>(
        () => AuthRepositoryImpl(
          getIt<AuthRemoteDataSource>(),
          localDataSource: getIt<AuthLocalDataSource>(),
          logger: getIt<AppLogger>(),
        ),
      )
      ..putLazySingletonIfAbsent<GetCurrentSessionUseCase>(
        () => GetCurrentSessionUseCase(getIt<AuthRepository>()),
      )
      ..putLazySingletonIfAbsent<RequestPhoneOtpUseCase>(
        () => RequestPhoneOtpUseCase(getIt<AuthRepository>()),
      )
      ..putLazySingletonIfAbsent<VerifyPhoneOtpUseCase>(
        () => VerifyPhoneOtpUseCase(getIt<AuthRepository>()),
      )
      ..putLazySingletonIfAbsent<LoginWithPasswordUseCase>(
        () => LoginWithPasswordUseCase(getIt<AuthRepository>()),
      )
      ..putLazySingletonIfAbsent<LoginWithMethodUseCase>(
        () => LoginWithMethodUseCase(getIt<AuthRepository>()),
      )
      ..putLazySingletonIfAbsent<LogoutUseCase>(
        () => LogoutUseCase(getIt<AuthRepository>()),
      )
      ..putLazySingletonIfAbsent<RefreshSessionUseCase>(
        () => RefreshSessionUseCase(getIt<AuthRepository>()),
      )
      ..putLazySingletonIfAbsent<AuthBloc>(
        () => AuthBloc(
          getIt<GetCurrentSessionUseCase>(),
          getIt<LogoutUseCase>(),
          getIt<RequestPhoneOtpUseCase>(),
          getIt<VerifyPhoneOtpUseCase>(),
          getIt<LoginWithPasswordUseCase>(),
          getIt<LoginWithMethodUseCase>(),
          logger: getIt<AppLogger>(),
        ),
      );
  }
}
