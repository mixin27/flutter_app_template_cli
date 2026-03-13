import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/phone_otp_challenge.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class OtpVerifyPage extends StatefulWidget {
  const OtpVerifyPage({
    required this.phoneNumber,
    required this.purpose,
    super.key,
    this.challengeId,
    this.from,
  });

  final String phoneNumber;
  final PhoneOtpPurpose purpose;
  final String? challengeId;
  final String? from;

  @override
  State<OtpVerifyPage> createState() => _OtpVerifyPageState();
}

class _OtpVerifyPageState extends State<OtpVerifyPage> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) {
        return previous.status != current.status ||
            previous.errorMessage != current.errorMessage;
      },
      listener: (context, state) {
        if (state.status == AuthStatus.failure &&
            state.errorMessage != null &&
            state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Verify OTP')),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isBusy = state.status == AuthStatus.authenticating;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Phone: ${widget.phoneNumber}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('Purpose: ${widget.purpose.value}'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'OTP code'),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: isBusy ? null : _verifyOtp,
                    child: Text(isBusy ? 'Verifying...' : 'Verify and sign in'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _verifyOtp() {
    final otpCode = _otpController.text.trim();
    if (otpCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the OTP code.')),
      );
      return;
    }

    context.read<AuthBloc>().add(
      PhoneOtpVerified(
        phoneNumber: widget.phoneNumber,
        otpCode: otpCode,
        purpose: widget.purpose,
        challengeId: widget.challengeId,
      ),
    );
  }
}
