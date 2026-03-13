import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/home_metric_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HomeBloc>()..add(const HomeRequested()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state.status == HomeStatus.failure) {
          return _HomeError(message: state.errorMessage);
        }

        final summary = state.summary;
        if (summary == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<HomeBloc>().add(const HomeRequested());
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                summary.greeting,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(summary.focus, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 16),
              HomeMetricCard(
                title: 'Open tasks',
                value: summary.openTasks.toString(),
                subtitle: 'Tasks waiting for your attention',
              ),
              HomeMetricCard(
                title: 'Completed today',
                value: summary.completedToday.toString(),
                subtitle: 'Momentum you built today',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HomeError extends StatelessWidget {
  const _HomeError({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message ?? 'Unable to load the home summary',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                context.read<HomeBloc>().add(const HomeRequested());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
