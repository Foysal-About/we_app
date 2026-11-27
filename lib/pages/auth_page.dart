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
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  int _tab = 0; // 0 login, 1 sign up
  bool _hide = true;
  bool _remember = true;

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

  void _social(String provider) =>
      toast(context, '$provider sign-in is not available in this demo');

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final heroHeight = top + 270;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: heroHeight,
              child: _Hero(isLogin: _isLogin, top: top),
            ),
            Padding(
              padding: EdgeInsets.only(top: heroHeight - 44),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Sp.page),
                child: Column(
                  children: [
                    _FormCard(child: _form(context)),
                    const SizedBox(height: Sp.x6),
                    _footer(context),
                    SizedBox(
                      height: MediaQuery.paddingOf(context).bottom + Sp.x6,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _form(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PillTabs(
          labels: const ['Log In', 'Sign Up'],
          index: _tab,
          background: kPanel,
          onChanged: (i) => setState(() => _tab = i),
        ),
        const SizedBox(height: Sp.x6),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_isLogin) ...[
                _Field(
                  label: 'Full name',
                  hint: 'Your name',
                  controller: _name,
                  icon: Icons.person_outline,
                  action: TextInputAction.next,
                ),
                const SizedBox(height: Sp.x4),
              ],
              _Field(
                label: 'Phone or email',
                hint: 'you@example.com',
                controller: _email,
                icon: Icons.mail_outline,
                keyboard: TextInputType.emailAddress,
                action: TextInputAction.next,
              ),
              const SizedBox(height: Sp.x4),
              _Field(
                label: 'Password',
                hint: 'Enter your password',
                controller: _password,
                icon: Icons.lock_outline,
                obscure: _hide,
                action: _isLogin ? TextInputAction.done : TextInputAction.next,
                suffix: IconButton(
                  tooltip: _hide ? 'Show password' : 'Hide password',
                  onPressed: () => setState(() => _hide = !_hide),
                  icon: Icon(
                    _hide
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: kMuted,
                  ),
                ),
                onSubmitted: _isLogin ? (_) => _submit() : null,
              ),
              if (!_isLogin) ...[
                const SizedBox(height: Sp.x4),
                _Field(
                  label: 'Confirm password',
                  hint: 'Repeat your password',
                  controller: _confirm,
                  icon: Icons.lock_reset_outlined,
                  obscure: _hide,
                  action: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                ),
              ],
            ],
          ),
        ),
        if (_isLogin)
          Padding(
            padding: const EdgeInsets.only(top: Sp.x1),
            child: Row(
              children: [
                Flexible(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(Rd.sm),
                    onTap: () => setState(() => _remember = !_remember),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: Sp.x3),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _remember
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            size: 22,
                            color: _remember ? kBrandGreen : kMuted,
                          ),
                          const SizedBox(width: Sp.x2),
                          Flexible(
                            child: Text(
                              'Remember me',
                              overflow: TextOverflow.ellipsis,
                              style: dm(
                                12,
                                weight: FontWeight.w500,
                                color: kInk,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordPage(),
                    ),
                  ),
                  child: Text(
                    'Forgot password?',
                    style: dm(12, weight: FontWeight.w700, color: kBrandGreen),
                  ),
                ),
              ],
            ),
          )
        else
          const SizedBox(height: Sp.x2),
        const SizedBox(height: Sp.x2),
        PrimaryButton(
          label: _isLogin ? 'Login' : 'Create account',
          color: kBrandGreen,
          width: double.infinity,
          onTap: _submit,
        ),
        if (!_isLogin) ...[
          const SizedBox(height: Sp.x3),
          Text(
            'By creating an account you agree to our Terms and Privacy Policy.',
            textAlign: TextAlign.center,
            style: dm(11, color: kSubtle),
          ),
        ],
        const SizedBox(height: Sp.x6),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Sp.x3),
              child: Text(
                'or continue with',
                style: dm(11, weight: FontWeight.w500, color: kSubtle),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: Sp.x4),
        Row(
          children: [
            _Social(
              label: 'Google',
              glyph: 'G',
              color: const Color(0xFFDB4437),
              onTap: () => _social('Google'),
            ),
            const SizedBox(width: Sp.x3),
            _Social(
              label: 'Facebook',
              glyph: 'f',
              color: kFacebook,
              onTap: () => _social('Facebook'),
            ),
            const SizedBox(width: Sp.x3),
            _Social(
              label: 'X',
              glyph: 'X',
              color: kInk,
              onTap: () => _social('X'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _footer(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _tab = _isLogin ? 1 : 0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Sp.x3),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: _isLogin ? 'New to WE?  ' : 'Already have an account?  ',
                style: dm(14, color: kMuted),
              ),
              TextSpan(
                text: _isLogin ? 'Create an account' : 'Log in',
                style: dm(14, weight: FontWeight.w700, color: kBrandGreen),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.isLogin, required this.top});
  final bool isLogin;
  final double top;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kBeige, kSoftPeach],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(Rd.xxl)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Soft backdrop circle and the hero product.
          Positioned(
            right: -40,
            top: top + 24,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
          ),
          Positioned(
            right: 4,
            top: top + 20,
            child: Image.asset(
              'assets/images/product_opc.png',
              width: 190,
              height: 190,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            left: Sp.page,
            top: top + Sp.x4,
            child: const WeLogo(width: 76),
          ),
          Positioned(
            left: Sp.page,
            bottom: 64,
            right: 150,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Column(
                key: ValueKey(isLogin),
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isLogin ? 'Welcome back' : 'Join WE today',
                    style: urbanist(24, weight: FontWeight.w800, color: kInk),
                  ),
                  const SizedBox(height: Sp.x1),
                  Text(
                    isLogin
                        ? 'Log in to order cement and bricks.'
                        : 'Create an account in a minute.',
                    style: dm(12, color: kMuted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Sp.x5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Rd.xl),
        boxShadow: Elev.raised,
        border: Border.all(color: kBarGrey),
      ),
      child: child,
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.suffix,
    this.obscure = false,
    this.keyboard,
    this.action,
    this.onSubmitted,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final Widget? suffix;
  final bool obscure;
  final TextInputType? keyboard;
  final TextInputAction? action;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: Sp.x2, left: Sp.x1),
          child: Text(
            label,
            style: dm(12, weight: FontWeight.w600, color: kInk),
          ),
        ),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboard,
          textInputAction: action,
          onSubmitted: onSubmitted,
          style: dm(14, weight: FontWeight.w500, color: kInk),
          cursorColor: kBrandGreen,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: dm(14, color: kSubtle),
            filled: true,
            fillColor: kPanel,
            isDense: true,
            constraints: const BoxConstraints(minHeight: Sp.control),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Sp.x4,
              vertical: Sp.x3,
            ),
            prefixIcon: Icon(icon, size: 20, color: kMuted),
            prefixIconConstraints: const BoxConstraints(minWidth: 48),
            suffixIcon: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Rd.lg),
              borderSide: const BorderSide(color: kBarGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Rd.lg),
              borderSide: const BorderSide(color: kBarGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Rd.lg),
              borderSide: const BorderSide(color: kBrandGreen, width: 1.6),
            ),
          ),
        ),
      ],
    );
  }
}

class _Social extends StatelessWidget {
  const _Social({
    required this.label,
    required this.glyph,
    required this.color,
    required this.onTap,
  });
  final String label;
  final String glyph;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        label: 'Continue with $label',
        child: Tappable(
          onTap: onTap,
          child: Container(
            height: Sp.control,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Rd.lg),
              border: Border.all(color: kBarGrey, width: 1.4),
            ),
            child: Text(
              glyph,
              style: dm(20, weight: FontWeight.w800, color: color),
            ),
          ),
        ),
      ),
    );
  }
}
