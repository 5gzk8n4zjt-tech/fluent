import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/fluent_button.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/auth_provider.dart';

class OnboardingAccountScreen extends ConsumerStatefulWidget {
  const OnboardingAccountScreen({super.key});

  @override
  ConsumerState<OnboardingAccountScreen> createState() =>
      _OnboardingAccountScreenState();
}

class _OnboardingAccountScreenState
    extends ConsumerState<OnboardingAccountScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isSignIn = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (email.isEmpty || password.isEmpty) return;

    final notifier = ref.read(authNotifierProvider.notifier);
    final success = _isSignIn
        ? await notifier.signIn(email, password)
        : await notifier.signUp(email, password);

    if (!success || !mounted) return;

    final authState = ref.read(authNotifierProvider);
    if (authState is AuthSuccess) {
      final user = authState.user;
      if (_isSignIn && user.level != null) {
        context.go(user.role == Role.admin ? '/admin' : '/home');
      } else {
        context.go('/onboarding/level');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthLoading;
    String? errorMsg;
    if (authState is AuthError) errorMsg = authState.message;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StepIndicator(filled: 2, total: 3),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () => context.go('/onboarding'),
                child: const Icon(Icons.arrow_back_ios,
                    size: 20, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 32),
              Text(
                _isSignIn ? 'Inicia sesión' : 'Crea tu cuenta',
                style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.6,
                    height: 1.15),
              ),
              const SizedBox(height: 6),
              Text(
                _isSignIn
                    ? 'Accede a tu progreso guardado.'
                    : 'Recordaremos tu progreso en todos tus dispositivos.',
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 40),
              _LabeledField(
                label: 'Correo electrónico',
                hint: 'alex@fluent.app',
                keyboardType: TextInputType.emailAddress,
                controller: _emailCtrl,
              ),
              const SizedBox(height: 28),
              _LabeledField(
                label: 'Contraseña',
                hint: '••••••••',
                obscure: true,
                controller: _passwordCtrl,
              ),
              if (errorMsg != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F0),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFFCCCC)),
                  ),
                  child: Text(
                    errorMsg,
                    style:
                        const TextStyle(fontSize: 13, color: Color(0xFFCC3333)),
                  ),
                ),
              ],
              const Spacer(),
              FluentButton(
                label: isLoading
                    ? 'Cargando...'
                    : (_isSignIn ? 'Iniciar sesión' : 'Crear cuenta'),
                onPressed: isLoading ? null : _submit,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => context.go('/onboarding'),
                child: Center(
                  child: Text(
                    _isSignIn
                        ? '¿No tienes cuenta? Regístrate'
                        : '¿Ya tienes cuenta? Inicia sesión',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.5),
                    children: [
                      TextSpan(text: 'Al continuar, aceptas los '),
                      TextSpan(
                          text: 'Términos',
                          style: TextStyle(color: AppColors.textPrimary)),
                      TextSpan(text: ' y la '),
                      TextSpan(
                          text: 'Política de privacidad',
                          style: TextStyle(color: AppColors.textPrimary)),
                      TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.obscure = false,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.1)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                color: obscure
                    ? const Color(0xFFC0C0BA)
                    : AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.filled, required this.total});
  final int filled;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
          total,
          (i) => Expanded(
                child: Container(
                  height: 3,
                  margin: i < total - 1
                      ? const EdgeInsets.only(right: 6)
                      : EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: i < filled
                        ? AppColors.textPrimary
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              )),
    );
  }
}
