import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/config/app_colors.dart';
import 'package:mosa/config/app_config.dart';
import 'package:mosa/router/app_routes.dart';
import 'package:mosa/utils/app_icons.dart';
import 'package:mosa/utils/google_sign_in_supabase.dart';
import 'package:mosa/utils/toast.dart';
import 'package:mosa/widgets/common_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoadingGoogle = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Xử lý đăng nhập email/password
    }
  }

  Future<void> _handleGoogleLogin() async {
    if (_isLoadingGoogle) return;

    setState(() {
      _isLoadingGoogle = true;
    });

    try {
      await nativeGoogleSignIn();
      if (mounted) {
        showResultToast('Đăng nhập thành công');
        context.go(AppRoutes.overview);
      }
    } catch (e) {
      if (mounted) {
        appConfig.printLog('e', e.toString());
        showResultToast('Đăng nhập thất bại: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingGoogle = false;
        });
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && _obscurePassword,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(prefixIcon, color: AppColors.primary),
        suffixIcon:
            isPassword
                ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
                : null,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderLighter, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập $label';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold.single(
      title: const Text('Đăng nhập', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
      centerTitle: true,
      appBarBackgroundColor: Theme.of(context).colorScheme.surface,
      elevation: false,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // App Logo or Welcome Graphic can go here
                // Center(
                //   child: Container(
                //     width: 100,
                //     height: 100,
                //     decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                //     child: const Icon(Icons.account_balance_wallet_rounded, size: 50, color: AppColors.primary),
                //   ),
                // ),
                // const SizedBox(height: 32),
                Center(
                  child: Text(
                    'Chào Mừng Trở Lại!',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Vui lòng đăng nhập để tiếp tục',
                    style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 48),

                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Nhập email của bạn',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  controller: _passwordController,
                  label: 'Mật khẩu',
                  hint: 'Nhập mật khẩu',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                ),
                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Navigate to forgot password
                    },
                    style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                    child: const Text('Quên mật khẩu?', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Đăng nhập', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.borderLighter, thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Hoặc', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                    ),
                    const Expanded(child: Divider(color: AppColors.borderLighter, thickness: 1)),
                  ],
                ),
                const SizedBox(height: 24),

                OutlinedButton.icon(
                  onPressed: _isLoadingGoogle ? null : _handleGoogleLogin,
                  icon:
                      _isLoadingGoogle
                          ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                          )
                          : Image.asset(AppIcons.google, height: 24),
                  label: Text(
                    _isLoadingGoogle ? 'Đang đăng nhập...' : 'Đăng nhập với Google',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.borderLight),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 48),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Chưa có tài khoản?', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                    TextButton(
                      onPressed: () {
                        // TODO: Navigate to registration
                      },
                      child: const Text(
                        'Đăng ký ngay',
                        style: TextStyle(color: AppColors.primary, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
