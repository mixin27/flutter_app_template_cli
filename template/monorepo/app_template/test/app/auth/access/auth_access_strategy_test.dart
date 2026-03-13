import 'package:flutter_test/flutter_test.dart';
import 'package:__APP_NAME__/app/auth/access/auth_access_strategy.dart';
import 'package:__APP_NAME__/app/auth/access/auth_feature_ids.dart';
import 'package:__APP_NAME__/app/auth/access/auth_feature_registry.dart';
import 'package:__APP_NAME__/app/config/auth_gate_mode.dart';
import 'package:__APP_NAME__/app/router/app_route_paths.dart';

void main() {
  const registry = AuthFeatureRegistry(
    rules: {
      AuthFeatureRule(
        featureId: AuthFeatureIds.tasks,
        routePrefixes: {AppRoutePaths.tasks},
      ),
      AuthFeatureRule(
        featureId: AuthFeatureIds.profile,
        routePrefixes: {AppRoutePaths.profile},
      ),
    },
  );

  test('feature_scoped strategy protects only configured features', () {
    final strategy = AuthAccessStrategyFactory.fromMode(
      AuthGateMode.featureScoped,
      requiredFeatures: const {AuthFeatureIds.tasks},
    );

    expect(
      strategy.requiresAuthenticationForPath('/tasks', registry),
      isTrue,
    );
    expect(
      strategy.requiresAuthenticationForPath('/profile', registry),
      isFalse,
    );
    expect(
      strategy.requiresAuthenticationForPath('/home', registry),
      isFalse,
    );
  });

  test('optional strategy does not protect paths', () {
    final strategy = AuthAccessStrategyFactory.fromMode(AuthGateMode.optional);
    expect(strategy.requiresAuthenticationForPath('/tasks', registry), isFalse);
  });

  test('required strategy protects all non-auth paths', () {
    final strategy = AuthAccessStrategyFactory.fromMode(AuthGateMode.required);
    expect(strategy.requiresAuthenticationForPath('/home', registry), isTrue);
    expect(strategy.requiresAuthenticationForPath('/auth', registry), isFalse);
    expect(
      strategy.requiresAuthenticationForPath('/auth/email', registry),
      isFalse,
    );
  });
}
