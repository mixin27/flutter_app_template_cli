import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/auth/access/auth_access_strategy.dart';
import '../../../../app/auth/access/auth_feature_registry.dart';
import '../../../../app/di/injection_container.dart';
import '../../../../app/router/app_route_paths.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

class AuthEntryPage extends StatelessWidget {
  const AuthEntryPage({super.key, this.from});

  final String? from;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final strategy = getIt<AuthAccessStrategy>();
    final featureRegistry = getIt<AuthFeatureRegistry>();
    final isBusy = authState.status == AuthStatus.authenticating;
    final errorMessage = authState.status == AuthStatus.failure
        ? authState.errorMessage
        : null;
    final guestDestination = _guestDestination(
      strategy: strategy,
      registry: featureRegistry,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sign in to unlock your tasks and personal workspace.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (errorMessage != null) ...[
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    errorMessage,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            FilledButton.icon(
              onPressed: isBusy
                  ? null
                  : () => context.push(_withFrom(AppRoutePaths.authPhone)),
              icon: const Icon(Icons.phone_android),
              label: const Text('Continue with phone OTP'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: isBusy
                  ? null
                  : () => context.push(_withFrom(AppRoutePaths.authEmail)),
              icon: const Icon(Icons.alternate_email),
              label: const Text('Continue with email/password'),
            ),
            const SizedBox(height: 16),
            Text(
              'Other methods like Google/Apple/Facebook can use MethodLoginRequested in AuthBloc.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (strategy.allowsGuestAccess) ...[
              const SizedBox(height: 24),
              TextButton(
                onPressed: isBusy ? null : () => context.go(guestDestination),
                child: const Text('Continue as guest'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _withFrom(String path) {
    if (from == null || from!.isEmpty) {
      return path;
    }

    return Uri(
      path: path,
      queryParameters: <String, String>{'from': from!},
    ).toString();
  }

  String _guestDestination({
    required AuthAccessStrategy strategy,
    required AuthFeatureRegistry registry,
  }) {
    if (from == null || from!.isEmpty) {
      return AppRoutePaths.home;
    }

    try {
      final path = Uri.parse(from!).path;
      final requiresAuthentication = strategy.requiresAuthenticationForPath(
        path,
        registry,
      );
      if (requiresAuthentication) {
        return AppRoutePaths.home;
      }

      return from!;
    } catch (_) {
      return AppRoutePaths.home;
    }
  }
}
