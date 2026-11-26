import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../widgets/common.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _email = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const PageHeader(showLogo: true),
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: kBarGrey,
                borderRadius: BorderRadius.circular(32),
              ),
              child: SingleChildScrollView(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _sent ? _done(context) : _form(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _form(BuildContext context) => Column(
    key: const ValueKey('form'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Forgot password?', style: urbanist(30, weight: FontWeight.w700)),
      const SizedBox(height: 8),
      Text(
        'Enter your phone or email and we will send you a link to reset your password.',
        style: dm(14, color: Colors.black54, height: 1.4),
      ),
      const SizedBox(height: 24),
      WeTextField(
        label: 'Your Phone/Email',
        controller: _email,
        keyboard: TextInputType.emailAddress,
      ),
      const SizedBox(height: 24),
      PrimaryButton(
        label: 'Send reset link',
        color: kBrandGreen,
        width: double.infinity,
        onTap: () => setState(() => _sent = true),
      ),
    ],
  );

  Widget _done(BuildContext context) => Column(
    key: const ValueKey('done'),
    children: [
      const SizedBox(height: 24),
      const CircleAvatar(
        radius: 36,
        backgroundColor: kBrandGreen,
        child: Icon(
          Icons.mark_email_read_outlined,
          color: Colors.white,
          size: 34,
        ),
      ),
      const SizedBox(height: 20),
      Text('Check your inbox', style: urbanist(24, weight: FontWeight.w700)),
      const SizedBox(height: 8),
      Text(
        'If an account exists for ${_email.text.isEmpty ? 'that address' : _email.text}, a reset link is on its way.\n(Demo app — nothing is actually sent.)',
        textAlign: TextAlign.center,
        style: dm(14, color: Colors.black54, height: 1.4),
      ),
      const SizedBox(height: 28),
      PrimaryButton(
        label: 'Back to login',
        width: double.infinity,
        onTap: () => Navigator.of(context).pop(),
      ),
    ],
  );
}
