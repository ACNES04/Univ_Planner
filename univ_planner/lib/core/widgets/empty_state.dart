// [Core/Widget] - 데이터가 없을 때 표시하는 빈 상태 위젯
import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.ctaLabel,
    this.onCta,
  });

  final IconData icon;
  final String title;
  final String? description;
  final String? ctaLabel;
  final VoidCallback? onCta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedHeight = constraints.maxHeight.isFinite;
        final compact = hasBoundedHeight && constraints.maxHeight < 220;
        final verticalPadding = compact ? 12.0 : 40.0;
        final iconSize = compact ? 48.0 : 64.0;
        final titleGap = compact ? 10.0 : 16.0;
        final ctaGap = compact ? 12.0 : 24.0;
        final minHeight = hasBoundedHeight
            ? (constraints.maxHeight - (verticalPadding * 2))
                .clamp(0.0, double.infinity)
                .toDouble()
            : 0.0;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: verticalPadding),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: iconSize,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                  SizedBox(height: titleGap),
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      description!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (ctaLabel != null && onCta != null) ...[
                    SizedBox(height: ctaGap),
                    FilledButton.tonal(
                      onPressed: onCta,
                      child: Text(ctaLabel!),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
