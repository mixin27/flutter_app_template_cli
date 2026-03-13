import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_route_paths.dart';
import '../../domain/entities/phone_otp_challenge.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class PhoneAuthPage extends StatefulWidget {
  const PhoneAuthPage({super.key, this.from});

  final String? from;

  @override
  State<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  final _phoneController = TextEditingController();
  PhoneOtpPurpose _purpose = PhoneOtpPurpose.login;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) {
        return previous.status != current.status ||
            previous.otpChallenge != current.otpChallenge ||
            previous.errorMessage != current.errorMessage;
      },
      listener: (context, state) {
        if (state.status == AuthStatus.otpRequested &&
            state.otpChallenge != null) {
          final challenge = state.otpChallenge!;
          context.push(
            Uri(
              path: AppRoutePaths.authOtp,
              queryParameters: <String, String>{
                'phone': challenge.phoneNumber,
                'purpose': challenge.purpose.value,
                if (challenge.challengeId != null &&
                    challenge.challengeId!.isNotEmpty)
                  'challengeId': challenge.challengeId!,
                if (widget.from != null && widget.from!.isNotEmpty)
                  'from': widget.from!,
              },
            ).toString(),
          );
        }

        if (state.status == AuthStatus.failure &&
            state.errorMessage != null &&
            state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Phone OTP')),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isBusy = state.status == AuthStatus.authenticating;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone number',
                      hintText: '+959123456789',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<PhoneOtpPurpose>(
                    initialValue: _purpose,
                    decoration: const InputDecoration(labelText: 'Purpose'),
                    items: const [
                      DropdownMenuItem(
                        value: PhoneOtpPurpose.login,
                        child: Text('Login'),
                      ),
                      DropdownMenuItem(
                        value: PhoneOtpPurpose.registration,
                        child: Text('Register'),
                      ),
                    ],
                    onChanged: isBusy
                        ? null
                        : (value) {
                            if (value == null) {
                              return;
                            }

                            setState(() => _purpose = value);
                          },
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: isBusy ? null : _requestOtp,
                    child: Text(isBusy ? 'Requesting...' : 'Request OTP'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _requestOtp() {
    final phoneNumber = _phoneController.text.trim();
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number.')),
      );
      return;
    }

    context.read<AuthBloc>().add(
      PhoneOtpRequested(phoneNumber: phoneNumber, purpose: _purpose),
    );
  }
}
