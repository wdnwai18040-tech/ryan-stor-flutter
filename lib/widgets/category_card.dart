import 'package:flutter/material.dart';
import 'package:ryaaans_store/core/widgets/base_card.dart';
import '../models/category.dart';
import '../../core/design/app_spacing.dart';
import '../../core/design/app_radius.dart';
import '../../core/design/app_sizes.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const CategoryCard({super.key, required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BaseCard(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _IconContainer(imageUrl: category.imageUrl),

            SizedBox(height: AppSpacing.sm),

            Flexible(
              child: Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            SizedBox(height: AppSpacing.xs),

            const _IndicatorBar(),
          ],
        ),
      ),
    );
  }
}

class _IconContainer extends StatefulWidget {
  final String? imageUrl;
  static const String _fallbackAsset = 'assets/mascot/home_mascot.webp';

  const _IconContainer({this.imageUrl});

  @override
  State<_IconContainer> createState() => _IconContainerState();
}

class _IconContainerState extends State<_IconContainer> {
  late final List<String> _imageCandidates;
  int _candidateIndex = 0;

  @override
  void initState() {
    super.initState();
    _imageCandidates = _buildImageCandidates(widget.imageUrl);
  }

  List<String> _buildImageCandidates(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return const [];
    final value = rawUrl.trim();

    if (value.startsWith('http://') || value.startsWith('https://')) {
      final candidates = <String>[value];
      if (value.contains('api.ryanstor.com/uploads/')) {
        candidates.add(value.replaceFirst('api.ryanstor.com', 'ryanstor.com'));
      }
      return candidates.toSet().toList();
    }

    final path = value.startsWith('/') ? value : '/$value';
    return [
      'https://api.ryanstor.com$path',
      'https://ryanstor.com$path',
      'http://145.223.34.121:3000$path',
    ];
  }

  void _tryNextCandidate() {
    if (_candidateIndex >= _imageCandidates.length - 1) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _candidateIndex += 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: AppSizes.categoryIconContainer - 8,
      height: AppSizes.categoryIconContainer - 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.primaryContainer,
      ),
      clipBehavior: Clip.antiAlias,
      child: _imageCandidates.isNotEmpty
          ? Image.network(
              _imageCandidates[_candidateIndex],
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                _tryNextCandidate();
                return _buildFallbackImage();
              },
            )
          : _buildFallbackImage(),
    );
  }

  Widget _buildFallbackImage() {
    return ClipOval(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Image.asset(_IconContainer._fallbackAsset, fit: BoxFit.contain),
      ),
    );
  }
}

class _IndicatorBar extends StatelessWidget {
  const _IndicatorBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: AppSizes.categoryIndicatorWidth,
      height: AppSizes.categoryIndicatorHeight,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.2),
        borderRadius: AppRadius.chip,
      ),
    );
  }
}

