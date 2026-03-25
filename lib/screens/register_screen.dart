import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ryaaans_store/core/design/app_radius.dart';
import 'package:ryaaans_store/providers/user_provider.dart';
import 'package:ryaaans_store/providers/wallet_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_wrapper.dart';
import 'package:ryaaans_store/core/components/layout/app_scaffold.dart';
import 'otp_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  InputDecoration _buildInputDecoration(
    BuildContext context, {
    required String label,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.45),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: AppRadius.button,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.button,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.button,
        borderSide: BorderSide(
          color: theme.colorScheme.primary.withOpacity(0.45),
          width: 1.4,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
    _phoneController.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    try {
      final userId = await context.read<AuthProvider>().register(
        context,
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _phoneController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال رمز التحقق إلى بريدك الإلكتروني'),
          backgroundColor: Colors.blue,
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(userId: userId),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = context.select<AuthProvider, bool>((p) => p.isLoading);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AppScaffold(
        title: 'إنشاء حساب جديد',
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'إنشاء حساب',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),

                    const SizedBox(height: 8),
                    Text(
                      'أنشئ حسابك وابدأ باستخدام التطبيق',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),

                    const SizedBox(height: 32),

                    Card(
                      color: theme.cardTheme.color,
                      elevation: theme.cardTheme.elevation,
                      shadowColor:
                          theme.cardTheme.shadowColor ?? theme.shadowColor,
                      shape: theme.cardTheme.shape,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _usernameController,
                              decoration: _buildInputDecoration(
                                context,
                                label: 'اسم المستخدم',
                                icon: Icons.person,
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'يرجى إدخال اسم المستخدم';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: _buildInputDecoration(
                                context,
                                label: 'البريد الإلكتروني',
                                icon: Icons.email,
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'يرجى إدخال البريد الإلكتروني';
                                }
                                // Simple email regex
                                final emailRegex = RegExp(
                                  r'^[\w-.]+@[\w-]+\.[a-zA-Z]{2,}$',
                                );
                                if (!emailRegex.hasMatch(val)) {
                                  return 'يرجى إدخال بريد إلكتروني صحيح';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: _buildInputDecoration(
                                context,
                                label: 'رقم الهاتف',
                                icon: Icons.phone,
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'يرجى إدخال رقم الهاتف';
                                }
                                final phoneRegex = RegExp(r'^0\d{9}$');
                                if (!phoneRegex.hasMatch(val) ||
                                    val.length != 10) {
                                  return 'رقم الهاتف يجب أن يبدأ بــ 0 ويتكون من 10 أرقام فقط';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: _buildInputDecoration(
                                context,
                                label: 'كلمة المرور',
                                icon: Icons.lock,
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'يرجى إدخال كلمة المرور';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),
                            ElevatedButton(
                              onPressed: isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.button,
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'إنشاء الحساب',
                                      style: theme.textTheme.labelLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w400,
                                          ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/login'),
                      child: const Text('لديك حساب بالفعل؟ تسجيل الدخول'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
