import '../../config/auth_gate_mode.dart';
import '../../router/app_route_paths.dart';
import 'auth_feature_registry.dart';

abstract class AuthAccessStrategy {
  AuthGateMode get mode;

  bool get allowsGuestAccess;

  bool requiresAuthenticationForFeature(String featureId);

  bool requiresAuthenticationForPath(String path, AuthFeatureRegistry registry);
}

class AuthAccessStrategyFactory {
  const AuthAccessStrategyFactory._();

  static AuthAccessStrategy fromMode(
    AuthGateMode mode, {
    Set<String> requiredFeatures = const <String>{},
  }) {
    switch (mode) {
      case AuthGateMode.optional:
        return const OptionalAuthAccessStrategy();
      case AuthGateMode.featureScoped:
        return FeatureScopedAuthAccessStrategy(
          requiredFeatures: requiredFeatures,
        );
      case AuthGateMode.required:
        return const RequiredAuthAccessStrategy();
    }
  }
}

class OptionalAuthAccessStrategy implements AuthAccessStrategy {
  const OptionalAuthAccessStrategy();

  @override
  AuthGateMode get mode => AuthGateMode.optional;

  @override
  bool get allowsGuestAccess => true;

  @override
  bool requiresAuthenticationForFeature(String featureId) => false;

  @override
  bool requiresAuthenticationForPath(
    String path,
    AuthFeatureRegistry registry,
  ) {
    return false;
  }
}

class FeatureScopedAuthAccessStrategy implements AuthAccessStrategy {
  const FeatureScopedAuthAccessStrategy({required this.requiredFeatures});

  @override
  AuthGateMode get mode => AuthGateMode.featureScoped;

  @override
  bool get allowsGuestAccess => true;

  final Set<String> requiredFeatures;

  @override
  bool requiresAuthenticationForFeature(String featureId) {
    return requiredFeatures.contains(featureId);
  }

  @override
  bool requiresAuthenticationForPath(
    String path,
    AuthFeatureRegistry registry,
  ) {
    final featureIds = registry.resolveFeatureIdsForPath(path);
    for (final featureId in featureIds) {
      if (requiresAuthenticationForFeature(featureId)) {
        return true;
      }
    }

    return false;
  }
}

class RequiredAuthAccessStrategy implements AuthAccessStrategy {
  const RequiredAuthAccessStrategy();

  @override
  AuthGateMode get mode => AuthGateMode.required;

  @override
  bool get allowsGuestAccess => false;

  @override
  bool requiresAuthenticationForFeature(String featureId) => true;

  @override
  bool requiresAuthenticationForPath(
    String path,
    AuthFeatureRegistry registry,
  ) {
    return !_isAuthPath(path);
  }

  bool _isAuthPath(String path) {
    return path == AppRoutePaths.auth ||
        path.startsWith('${AppRoutePaths.auth}/');
  }
}
