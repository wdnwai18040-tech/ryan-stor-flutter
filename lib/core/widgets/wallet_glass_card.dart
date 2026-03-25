import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../design/app_radius.dart';
import '../design/app_spacing.dart';
import '../design/app_shadows.dart';
import '../storage/utils/currency_formatter.dart';
import '../../themes/wallet_card_theme.dart';
import 'base_button.dart';
import '../../providers/wallet_provider.dart';

class WalletGlassCard extends StatelessWidget {
  final VoidCallback onRecharge;

  const WalletGlassCard({super.key, required this.onRecharge});

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final walletTheme = theme.extension<WalletCardTheme>();
    final shadow = AppShadows.card(context);
    final formattedBalance = CurrencyFormatter.format(wallet.balance);

    return ClipRRect(
      borderRadius: AppRadius.card,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                (walletTheme?.backgroundColor ?? const Color(0xFF0D1B3D))
                    .withOpacity(0.98),
                const Color(0xFF1D3E78),
              ],
            ),
            borderRadius: AppRadius.card,
            border: Border.all(
              color: walletTheme?.borderColor ?? const Color(0x5582A6E8),
            ),
            boxShadow: walletTheme == null
                ? shadow
                : [
                    ...shadow,
                    BoxShadow(
                      color: (walletTheme.premiumBadgeFg ?? colors.primary)
                          .withOpacity(0.24),
                      blurRadius: walletTheme.elevation + 10,
                      offset: const Offset(0, 12),
                    ),
                  ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -42,
                right: -24,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (walletTheme?.premiumBadgeFg ?? colors.primary)
                        .withOpacity(0.18),
                  ),
                ),
              ),
              Positioned(
                bottom: -36,
                left: -14,
                child: Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (walletTheme?.premiumBadgeBg ?? Colors.white)
                        .withOpacity(0.24),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "الرصيد المتاح",
                    style: textTheme.bodyMedium?.copyWith(
                      color: (walletTheme?.labelColor ?? Colors.white)
                          .withOpacity(0.85),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    "$formattedBalance جنيه",
                    style: GoogleFonts.ibmPlexSansArabic(
                      textStyle: textTheme.displaySmall,
                      fontWeight: FontWeight.w400,
                      color: walletTheme?.amountColor ?? Colors.white,
                      letterSpacing: 0.2,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  BaseButton(
                    label: "شحن المحفظة",
                    onPressed: onRecharge,
                    variant: ButtonVariant.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
