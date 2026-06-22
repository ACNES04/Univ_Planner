// [Core/Widget] - 앱 전체에서 재사용하는 카드 위젯
// ignore_for_file: use_null_aware_elements
import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.leading,
    this.trailing,
    this.title,
    this.subtitle,
    this.backgroundColor,
  });

  final Widget? child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Widget? leading;
  final Widget? trailing;
  final Widget? title;
  final Widget? subtitle;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = _buildContent(theme);

    if (onTap != null) {
      return _buildContainer(
        theme,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: content,
        ),
      );
    }

    return _buildContainer(theme, child: content);
  }

  Widget _buildContainer(ThemeData theme, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  Widget _buildContent(ThemeData theme) {
    // child가 있으면 직접 렌더링
    if (child != null) {
      return Padding(padding: padding, child: child);
    }

    // title/subtitle/leading/trailing 조합
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 12)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) title!,
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  DefaultTextStyle(
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    child: subtitle!,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );
  }
}
