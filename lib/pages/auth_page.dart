import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import 'forgot_password_page.dart';
import 'shell_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  int _tab = 0; // 0 login, 1 sign up
  bool _hide = true;
  bool _remember = false;

  bool get _isLogin => _tab == 0;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    app.signIn(email: _email.text.trim(), name: _isLogin ? null : _name.text);
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const ShellPage()));
  }

  void _social(String provider) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$provider sign-in is not available in this demo'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, top + 16, 16, 24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: BoxDecoration(
                color: kBarGrey,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PillTabs(
                      labels: const ['Log In', 'Sign Up'],
                      index: _tab,
                      background: const Color(0xFFFAFAF8),
                      onChanged: (i) => setState(() => _tab = i),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        _isLogin ? 'Welcome back!' : 'Create your account',
                        style: dm(12, color: Colors.black54),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _isLogin ? 'Login' : 'Sign Up',
                            style: urbanist(32, weight: FontWeight.w700),
                          ),
                          const WeLogo(width: 76),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (!_isLogin) ...[
                      _Field(
                        label: 'Full Name',
                        controller: _name,
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 14),
                    ],
                    _Field(
                      label: 'Your Phone/Email',
                      controller: _email,
                      icon: Icons.mail_outline,
                      keyboard: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),
                    _Field(
                      label: 'Your Password',
                      controller: _password,
                      obscure: _hide,
                      icon: _hide
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      onIcon: () => setState(() => _hide = !_hide),
                    ),
                    if (!_isLogin) ...[
                      const SizedBox(height: 14),
                      _Field(
                        label: 'Confirm Password',
                        controller: _confirm,
                        obscure: _hide,
                        icon: Icons.lock_outline,
                      ),
                    ],
                    const SizedBox(height: 10),
                    if (_isLogin)
                      Row(
                        children: [
                          SizedBox(
                            width: 28,
                            child: Checkbox(
                              value: _remember,
                              visualDensity: VisualDensity.compact,
                              side: const BorderSide(color: Colors.black87),
                              onChanged: (v) =>
                                  setState(() => _remember = v ?? false),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Remember me',
                              style: dm(13, weight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ForgotPasswordPage(),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                'Forgot Password?',
                                style: dm(13, weight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 18),
                    GestureDetector(
                      onTap: _submit,
                      child: Container(
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: kBrandGreen,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isLogin ? 'Login' : 'Create account',
                              style: dm(
                                15,
                                weight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.arrow_right_alt,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
              decoration: BoxDecoration(
                color: kDarkGreen,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Continue with:',
                    style: urbanist(22, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      for (final p in const ['G', 'f', 'X']) ...[
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _social(switch (p) {
                              'G' => 'Google',
                              'f' => 'Facebook',
                              _ => 'X',
                            }),
                            child: Container(
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD6E6D3),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                p,
                                style: dm(
                                  20,
                                  weight: FontWeight.w700,
                                  color: kInk,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (p != 'X') const SizedBox(width: 12),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    required this.icon,
    this.onIcon,
    this.obscure = false,
    this.keyboard,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final VoidCallback? onIcon;
  final bool obscure;
  final TextInputType? keyboard;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      style: dm(14, weight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: dm(12, color: Colors.black54),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        suffixIcon: IconButton(
          onPressed: onIcon,
          icon: Icon(icon, color: kInk),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
