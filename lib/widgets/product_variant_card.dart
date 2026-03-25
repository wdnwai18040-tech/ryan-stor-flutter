// import 'package:flutter/material.dart';
// import 'package:ryaaans_store/core/design/app_radius.dart';
// import 'package:ryaaans_store/core/design/app_spacing.dart';
// import '../models/product.dart';

// class ProductVariantCard extends StatelessWidget {
//   final ProductVariant variant;
//   final bool isSelected;
//   final VoidCallback? onTap;

//   const ProductVariantCard({
//     super.key,
//     required this.variant,
//     required this.isSelected,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isAvailable = variant.isAvailable;
//     final statusColor = isAvailable
//         ? theme.colorScheme.primary
//         : theme.colorScheme.error;

//     return GestureDetector(
//       onTap: isAvailable ? onTap : null,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         margin: const EdgeInsets.symmetric(
//           horizontal: AppSpacing.md,
//           vertical: AppSpacing.sm,
//         ),
//         padding: const EdgeInsets.all(AppSpacing.md),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? theme.colorScheme.primaryContainer.withOpacity(0.35)
//               : theme.colorScheme.surface,
//           borderRadius: AppRadius.card,
//           border: Border.all(
//             color: isSelected ? theme.colorScheme.primary : Colors.transparent,
//             width: isSelected ? 2 : 0,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: theme.colorScheme.primary.withOpacity(
//                 isSelected ? 0.2 : 0.12,
//               ),
//               blurRadius: isSelected ? 16 : 12,
//               offset: const Offset(0, 6),
//             ),
//           ],
//         ),
//         child: Opacity(
//           opacity: isAvailable ? 1.0 : 0.6,
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // صورة الفاريانت
//               Container(
//                 width: 64,
//                 height: 64,
//                 decoration: BoxDecoration(
//                   color: isSelected
//                       ? theme.colorScheme.primary
//                       : theme.colorScheme.primary.withOpacity(0.08),
//                   borderRadius: AppRadius.button,
//                 ),
//                 clipBehavior: Clip.antiAlias,
//                 child: variant.imageUrl != null && variant.imageUrl!.isNotEmpty
//                     ? Image.network(
//                         variant.imageUrl!,
//                         fit: BoxFit.cover,
//                         errorBuilder: (_, _, _) => Padding(
//                           padding: const EdgeInsets.all(8),
//                           child: Image.asset(
//                             'assets/mascot/home_mascot.png',
//                             fit: BoxFit.contain,
//                           ),
//                         ),
//                       )
//                     : Padding(
//                         padding: const EdgeInsets.all(8),
//                         child: Image.asset(
//                           'assets/mascot/home_mascot.png',
//                           fit: BoxFit.contain,
//                         ),
//                       ),
//               ),

//               const SizedBox(width: AppSpacing.md),

//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       variant.name,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: theme.textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.w400,
//                         color: theme.colorScheme.onSurface,
//                       ),
//                     ),
//                     if (variant.description != null &&
//                         variant.description!.isNotEmpty)
//                       Padding(
//                         padding: const EdgeInsets.only(top: AppSpacing.xs),
//                         child: Text(
//                           variant.description!,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: theme.textTheme.bodySmall?.copyWith(
//                             color: theme.colorScheme.onSurfaceVariant,
//                             fontWeight: FontWeight.w400,
//                           ),
//                         ),
//                       ),
//                     const SizedBox(height: AppSpacing.sm),
//                     Wrap(
//                       spacing: AppSpacing.sm,
//                       runSpacing: AppSpacing.xs,
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: AppSpacing.sm,
//                             vertical: AppSpacing.xs,
//                           ),
//                           decoration: BoxDecoration(
//                             color: theme.colorScheme.primary.withOpacity(0.08),
//                             borderRadius: AppRadius.chip,
//                           ),
//                           child: Text(
//                             '${variant.price.toStringAsFixed(2)} جنيه',
//                             style: theme.textTheme.labelLarge?.copyWith(
//                               fontWeight: FontWeight.w400,
//                               color: theme.colorScheme.primary,
//                             ),
//                           ),
//                         ),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: AppSpacing.sm,
//                             vertical: AppSpacing.xs,
//                           ),
//                           decoration: BoxDecoration(
//                             color: statusColor.withOpacity(0.12),
//                             borderRadius: AppRadius.chip,
//                           ),
//                           child: Text(
//                             isAvailable ? 'متوفر' : 'نفذت',
//                             style: theme.textTheme.labelSmall?.copyWith(
//                               color: statusColor,
//                               fontWeight: FontWeight.w400,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               if (isSelected)
//                 Padding(
//                   padding: const EdgeInsets.only(right: AppSpacing.xs),
//                   child: Icon(
//                     Icons.check_circle_rounded,
//                     color: theme.colorScheme.primary,
//                     size: 24,
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
