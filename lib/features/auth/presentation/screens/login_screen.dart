import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Admin login screen.
///
/// Provides an [AuthBloc] from the service locator and hosts [LoginView].
/// Login is email/password only for this phase; Google sign-in is shown
/// but not yet available.
class LoginScreen extends StatelessWidget {
  /// Creates a [LoginScreen].
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.instance<AuthBloc>(),
      child: const LoginView(),
    );
  }
}

/// The login form UI.
///
/// A [StatefulWidget] is used only to own the [TextEditingController]s and
/// the password-visibility [ValueNotifier] lifecycle — all business state
/// still flows through [AuthBloc] (no `setState` drives app logic).
class LoginView extends StatefulWidget {
  /// Creates a [LoginView].
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _obscurePassword = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _obscurePassword.dispose();
    super.dispose();
  }

  /// Validates the form and dispatches [LoginRequested] to the bloc.
  void _onLogin(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      context.read<AuthBloc>().add(
        LoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  /// Validator for the email field (required + basic format).
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.emailRequired;
    }
    final pattern = RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w-]{2,4}$');
    if (!pattern.hasMatch(value.trim())) return AppConstants.emailInvalid;
    return null;
  }

  /// Validator for the password field (required + minimum length).
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return AppConstants.passwordRequired;
    if (value.length < 6) return AppConstants.passwordTooShort;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
          } else if (state is Authenticated) {
            _goToDashboard(context);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _LogoHeader(),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildEmailField(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildPasswordField(),
                      const SizedBox(height: AppSpacing.xl),
                      _buildLoginButton(context, isLoading),
                      const SizedBox(height: AppSpacing.lg),
                      const _OrDivider(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildGoogleButton(context, isLoading),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Navigates to the dashboard after a successful login.
  ///
  /// Guarded so it degrades gracefully to a SnackBar if the dashboard
  /// route is not registered yet (router wiring is a separate task).
  void _goToDashboard(BuildContext context) {
    try {
      Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil masuk sebagai admin')),
      );
    }
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      decoration: const InputDecoration(
        labelText: AppConstants.emailLabel,
        prefixIcon: Icon(Icons.email_outlined),
      ),
      validator: _validateEmail,
    );
  }

  Widget _buildPasswordField() {
    return ValueListenableBuilder<bool>(
      valueListenable: _obscurePassword,
      builder: (context, obscure, _) {
        return TextFormField(
          controller: _passwordController,
          obscureText: obscure,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          onFieldSubmitted: (_) => _onLogin(context),
          decoration: InputDecoration(
            labelText: AppConstants.passwordLabel,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () => _obscurePassword.value = !obscure,
              tooltip: obscure
                  ? AppConstants.showPassword
                  : AppConstants.hidePassword,
            ),
          ),
          validator: _validatePassword,
        );
      },
    );
  }

  Widget _buildLoginButton(BuildContext context, bool isLoading) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : () => _onLogin(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary900,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.xlBorder),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Text(AppConstants.loginButton, style: AppTextStyles.button),
      ),
    );
  }

  Widget _buildGoogleButton(BuildContext context, bool isLoading) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: isLoading
            ? null
            : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(AppConstants.googleNotAvailable),
                  ),
                );
              },
        icon: const Icon(
          Icons.g_mobiledata,
          size: 28,
          color: AppColors.accentBlue,
        ),
        label: const Text(
          AppConstants.loginWithGoogle,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.xlBorder),
        ),
      ),
    );
  }
}

/// Brand header with the TamuKu logo mark, name, and login title.
class _LogoHeader extends StatelessWidget {
  const _LogoHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary50,
            borderRadius: AppRadius.xlBorder,
          ),
          child: const Icon(
            Icons.how_to_reg_rounded,
            size: 44,
            color: AppColors.primary700,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text(AppConstants.appName, style: AppTextStyles.h1),
        const SizedBox(height: AppSpacing.xs),
        const Text(AppConstants.loginTitle, style: AppTextStyles.body),
      ],
    );
  }
}

/// A horizontal "atau" divider between login methods.
class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(AppConstants.orDivider, style: AppTextStyles.caption),
        ),
        Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}
