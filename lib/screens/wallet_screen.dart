import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import '../api/api_service.dart';
import 'package:ryaaans_store/core/components/layout/app_scaffold.dart';
import 'package:ryaaans_store/core/design/app_colors.dart';
import 'package:ryaaans_store/core/design/app_radius.dart';
import 'package:ryaaans_store/core/storage/auth_storage.dart';
import 'package:ryaaans_store/core/widgets/base_card.dart';
import 'package:ryaaans_store/core/widgets/base_button.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final TextEditingController _amountController = TextEditingController();
  final NumberFormat _numberFormatter = NumberFormat('#,###');

  File? _receiptImage;

  String _selectedMethod = 'Bankak';
  bool _isSubmitting = false;

  final List<Map<String, String>> _methods = [
    {
      'id': 'Bankak',
      'name': 'بنكك',
      'account': '3438958',
      'owner': 'محمد علي نواي',
    },
    {'id': 'MyCash', 'name': 'مايكاشي', 'account': '603326', 'owner': 'أحمد علي'},
    {
      'id': 'Bravo',
      'name': 'برافو',
      'account': '73668923',
      'owner': 'أحمد علي نواي',
    },
  ];

  Map<String, String> get _selectedMethodInfo {
    return _methods.firstWhere(
      (method) => method['id'] == _selectedMethod,
      orElse: () => _methods.first,
    );
  }

  Color _methodColor(String methodName) {
    switch (methodName) {
      case 'Bankak':
        return AppColors.danger;
      case 'MyCash':
        return AppColors.primaryBlue;
      case 'Bravo':
        return const Color(0xFF7C3AED);
      default:
        return Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
    }
  }

  Future<void> _copyAccountNumber() async {
    final theme = Theme.of(context);
    final account = _selectedMethodInfo['account'] ?? '';

    await Clipboard.setData(ClipboardData(text: account));

    if (!mounted) return;

    _showMessage('تم نسخ رقم الحساب', theme.colorScheme.primary);
  }

  Future<File> _ensureJpgFormat(File imageFile) async {
    final lowerPath = imageFile.path.toLowerCase();

    if (lowerPath.endsWith('.jpg') ||
        lowerPath.endsWith('.jpeg') ||
        lowerPath.endsWith('.png')) {
      return imageFile;
    }

    try {
      final bytes = await imageFile.readAsBytes();
      final decoded = img.decodeImage(bytes);

      if (decoded != null) {
        final jpgBytes = img.encodeJpg(decoded, quality: 90);
        final jpgFile = File('${p.withoutExtension(imageFile.path)}.jpg');
        await jpgFile.writeAsBytes(jpgBytes);
        return jpgFile;
      }
    } catch (_) {}

    return imageFile;
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked != null) {
      setState(() => _receiptImage = File(picked.path));
    }
  }

  Future<void> _submitTopup() async {
    final theme = Theme.of(context);
    final amountText = _amountController.text.trim();

    if (amountText.isEmpty) {
      _showMessage('يرجى إدخال المبلغ', theme.colorScheme.error);
      return;
    }

    if (_receiptImage == null) {
      _showMessage('يرجى إرفاق إشعار التحويل', theme.colorScheme.error);
      return;
    }

    final amount = double.tryParse(amountText.replaceAll(',', ''));

    if (amount == null || amount <= 0) {
      _showMessage('يرجى إدخال مبلغ صحيح', theme.colorScheme.error);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final uploadFile = await _ensureJpgFormat(_receiptImage!);
      final token = await AuthStorage.getToken();

      if (token == null) {
        _showMessage(
          'انتهت الجلسة، يرجى تسجيل الدخول مجددًا',
          theme.colorScheme.error,
        );
        return;
      }

      final api = ApiService(token: token);

      await api.postMultipart('/wallet/topup', {
        'method': _selectedMethod,
        'amount': amount.toString(),
      }, uploadFile);

      if (!mounted) return;

      _showMessage('تم إرسال طلب شحن المحفظة بنجاح', theme.colorScheme.primary);

      _amountController.clear();

      setState(() => _receiptImage = null);

      await Future.delayed(const Duration(seconds: 1));

      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;

      _showMessage('فشل إرسال الطلب، حاول مرة أخرى', theme.colorScheme.error);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showMessage(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedMethodInfo = _selectedMethodInfo;
    final selectedMethodColor = _methodColor(_selectedMethod);

    return AppScaffold(
      title: 'إعادة شحن المحفظة',
      backgroundColor: colorScheme.surface,
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 💳 Header Title
              Text(
                'طريقة التحويل',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),

              // 🎡 Method Selection Horizontal List
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _methods.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final method = _methods[index];
                    final isSelected = method['id'] == _selectedMethod;
                    final color = _methodColor(method['id']!);

                    return GestureDetector(
                      onTap: () => setState(() => _selectedMethod = method['id']!),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 120,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withOpacity(0.12)
                              : colorScheme.surface,
                          borderRadius: AppRadius.card,
                          border: Border.all(
                            color: isSelected
                                ? color
                                : colorScheme.outline.withOpacity(0.1),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withOpacity(0.2),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isSelected
                                    ? Icons.check_circle_rounded
                                    : Icons.account_balance_rounded,
                                color: color,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              method['name']!,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w400,
                                color: isSelected
                                    ? color
                                    : colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // 🏦 Bank Details Card
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Container(
                  key: ValueKey(_selectedMethod),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        selectedMethodColor.withOpacity(0.9),
                        selectedMethodColor,
                      ],
                    ),
                    borderRadius: AppRadius.card,
                    boxShadow: [
                      BoxShadow(
                        color: selectedMethodColor.withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedMethodInfo['name']!,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(Icons.qr_code_2_rounded, color: Colors.white),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'رقم الحساب',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedMethodInfo['account']!,
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _copyAccountNumber,
                            icon: const Icon(Icons.copy_rounded, color: Colors.white),
                            tooltip: 'نسخ رقم الحساب',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Colors.white24, height: 1),
                      const SizedBox(height: 12),
                      Text(
                        'صاحب الحساب',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        selectedMethodInfo['owner']!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 💰 Amount Input
              Text(
                'المبلغ المحول',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: AppRadius.card,
                  border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      if (newValue.text.isEmpty) return newValue;
                      int value = int.parse(newValue.text.replaceAll(',', ''));
                      if (value > 10000000) value = 10000000;
                      final formatted = _numberFormatter.format(value);
                      return TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(
                          offset: formatted.length,
                        ),
                      );
                    }),
                  ],
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.2)),
                    border: InputBorder.none,
                    suffixText: 'SDG',
                    suffixStyle: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 📸 Receipt Upload Area
              Text(
                'إرفاق إشعار التحويل',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.04),
                    borderRadius: AppRadius.card,
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.2),
                      style: _receiptImage == null ? BorderStyle.solid : BorderStyle.none,
                      width: 1,
                    ),
                  ),
                  child: _receiptImage != null
                      ? Stack(
                          children: [
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: AppRadius.card,
                                child: Image.file(_receiptImage!, fit: BoxFit.cover),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.black54,
                                radius: 18,
                                child: IconButton(
                                  icon: const Icon(Icons.close, size: 18, color: Colors.white),
                                  onPressed: () => setState(() => _receiptImage = null),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined,
                                size: 48, color: colorScheme.primary.withOpacity(0.5)),
                            const SizedBox(height: 12),
                            Text(
                              'اضغط هنا لرفع صورة الإشعار',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 40),

              // 🚀 Submit Button
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitTopup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                    elevation: 6,
                    shadowColor: colorScheme.primary.withOpacity(0.4),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'تأكيد طلب الشحن',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
