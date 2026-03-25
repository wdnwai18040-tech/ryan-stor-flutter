// File: screens/settings/account_settings_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/user_service.dart';
import 'package:ryaaans_store/core/components/layout/app_scaffold.dart';
import 'package:ryaaans_store/core/design/app_colors.dart';
import 'package:ryaaans_store/core/design/app_radius.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;

  bool _isLoading = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
  }

  void _fillFromUser() {
    final user = context.read<UserProvider>().user;
    if (user != null) {
      _usernameController.text = user.username;
      _emailController.text = user.email;
      _phoneController.text = user.phone;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _fillFromUser();
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final token = context.read<AuthProvider>().token!;
      await UserService.updateUser(
        token: token,
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        currentPassword: _passwordController.text,
      );
      await context.read<UserProvider>().refresh(token);
      _fillFromUser();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم تحديث البيانات بنجاح',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          ),
        );
        _passwordController.clear();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // ✅ ظل موحد وناعم يتكيف مع Light/Dark
    final elegantShadow = [
      BoxShadow(
        color: theme.brightness == Brightness.dark 
            ? AppColors.shadowDark 
            : AppColors.shadowLight,
        blurRadius: 20,
        offset: const Offset(0, 6),
        spreadRadius: -2,
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AppScaffold(
        title: 'بيانات الحساب',
        backgroundColor: colorScheme.surface,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 👤 Header Section - تصميم أنيق
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.primary.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.person_outline_rounded,
                          size: 50,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _usernameController.text,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w400, // ✅ عريض ولكن متوازن
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'يمكنك تعديل معلوماتك الشخصية أدناه',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w400, // ✅ نص ثانوي خفيف
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // 📝 Fields Group
                _buildFieldLabel('المعلومات العامة', textTheme, colorScheme),
                const SizedBox(height: 12),
                
                _field(
                  controller: _usernameController,
                  label: 'اسم المستخدم',
                  icon: Icons.alternate_email_rounded,
                  enabled: false,
                  theme: theme,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  shadow: elegantShadow,
                ),
                const SizedBox(height: 16),
                
                _field(
                  controller: _emailController,
                  label: 'البريد الإلكتروني',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v == null || v.isEmpty ? 'البريد مطلوب' : null,
                  theme: theme,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  shadow: elegantShadow,
                ),
                const SizedBox(height: 16),
                
                _field(
                  controller: _phoneController,
                  label: 'رقم الهاتف',
                  icon: Icons.phone_android_rounded,
                  keyboardType: TextInputType.phone,
                  theme: theme,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  shadow: elegantShadow,
                ),

                const SizedBox(height: 32),
                
                _buildFieldLabel('تأكيد التغييرات', textTheme, colorScheme),
                const SizedBox(height: 12),
                
                _field(
                  controller: _passwordController,
                  label: 'كلمة المرور الحالية',
                  icon: Icons.lock_outline_rounded,
                  obscureText: true,
                  validator: (v) => v == null || v.isEmpty ? 'مطلوبة لحفظ التغييرات' : null,
                  theme: theme,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  shadow: elegantShadow,
                ),

                const SizedBox(height: 40),

                // 🚀 Save Button - موحد مع الثيم
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.button, // ✅ موحد
                      ),
                      elevation: 4,
                      shadowColor: colorScheme.primary.withOpacity(0.3),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'حفظ التعديلات',
                            style: textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w400, // ✅ متوازن
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Label موحد مع الثيم
  Widget _buildFieldLabel(String label, TextTheme textTheme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, right: 4),
      child: Text(
        label,
        style: textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w400, // ✅ عنوان قسم
          color: colorScheme.onSurface.withOpacity(0.9),
        ),
      ),
    );
  }

  // ✅ حقل إدخال موحد مع الثيم (Clean Card Style)
  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required List<BoxShadow> shadow,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.card, // ✅ موحد
        boxShadow: enabled ? shadow : null, // ✅ ظل ناعم فقط للحقول النشطة
      ),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        style: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w400, // ✅ مقروء ومريح
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface.withOpacity(0.6), // ✅ باهت للعناوين
          ),
          prefixIcon: Icon(
            icon, 
            size: 22, 
            color: enabled ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.4),
          ),
          filled: true,
          fillColor: enabled 
              ? colorScheme.surface 
              : colorScheme.surfaceContainerHighest.withOpacity(0.3), // ✅ خلفية مختلفة للحقول المعطلة
          border: OutlineInputBorder(
            borderRadius: AppRadius.card,
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.card,
            borderSide: BorderSide(
              color: colorScheme.outline.withOpacity(0.2), // ✅ حد خفيف جداً
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.card,
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppRadius.card,
            borderSide: BorderSide(
              color: AppColors.danger.withOpacity(0.5),
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppRadius.card,
            borderSide: BorderSide(
              color: AppColors.danger,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}