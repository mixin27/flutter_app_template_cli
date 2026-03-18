import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/profile_cubit.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (context, state) {
        return AppScaffold(
          title: 'Profile',
          actions: [
            IconButton(
              tooltip: 'Refresh',
              onPressed: () =>
                  context.read<ProfileCubit>().loadProfile(forceRefresh: true),
              icon: const Icon(Icons.refresh),
            ),
          ],
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ProfileState state) {
    if (state.status == ProfileStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.profile == null) {
      return const Center(child: Text('No profile data.'));
    }

    final profile = state.profile!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.isFromCache)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('Offline cache'),
          ),
        const SizedBox(height: 16),
        _ProfileTile(label: 'Name', value: profile.name),
        _ProfileTile(label: 'Email', value: profile.email),
        _ProfileTile(
          label: 'Updated',
          value: profile.updatedAt.toLocal().toString(),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Sign Out',
          onPressed: () => context.read<AuthCubit>().signOut(),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
