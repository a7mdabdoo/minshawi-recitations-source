import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

/// Renders the developer's social links (Facebook, LinkedIn, GitHub, Email).
class DeveloperSocialLinks extends StatelessWidget {
  final double iconSize;
  final double spacing;
  final EdgeInsetsGeometry buttonPadding;
  final double borderRadius;
  final Color? iconColor;
  final bool showErrorSnackBar;

  const DeveloperSocialLinks({
    super.key,
    this.iconSize = 16,
    this.spacing = 8,
    this.buttonPadding = const EdgeInsets.all(5),
    this.borderRadius = 10,
    this.iconColor,
    this.showErrorSnackBar = false,
  });

  Future<void> _launch(BuildContext context, String url) async {
    try {
      final launched = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
      if (!launched && showErrorSnackBar && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذّر فتح الرابط'),
            backgroundColor: AppColors.darkError,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (showErrorSnackBar && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذّر فتح الرابط الخارجي'),
            backgroundColor: AppColors.darkError,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedColor = iconColor ??
        (isDark ? AppColors.darkTextSecondary : AppColors.lightIconColor);
    final hex =
        '#${resolvedColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';

    final items = [
      (
        svg: _BrandVectors.facebook(hex),
        tooltip: 'فيسبوك',
        url: AppConstants.devFacebookUrl,
      ),
      (
        svg: _BrandVectors.linkedin(hex),
        tooltip: 'لينكد إن',
        url: AppConstants.devLinkedinUrl,
      ),
      (
        svg: _BrandVectors.github(hex),
        tooltip: 'جيت هب',
        url: AppConstants.devGithubUrl,
      ),
      (
        svg: _BrandVectors.email(hex),
        tooltip: 'البريد الإلكتروني',
        url: AppConstants.devEmail,
      ),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) SizedBox(width: spacing),
          _SocialSvgButton(
            svgString: items[i].svg,
            tooltip: items[i].tooltip,
            iconSize: iconSize,
            padding: buttonPadding,
            borderRadius: borderRadius,
            onTap: () => _launch(context, items[i].url),
          ),
        ],
      ],
    );
  }
}

class _SocialSvgButton extends StatelessWidget {
  final String svgString;
  final String tooltip;
  final double iconSize;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final VoidCallback onTap;

  const _SocialSvgButton({
    required this.svgString,
    required this.tooltip,
    required this.iconSize,
    required this.padding,
    required this.borderRadius,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding,
          child: Tooltip(
            message: tooltip,
            child: SizedBox(
              width: iconSize,
              height: iconSize,
              child: SvgPicture.string(
                svgString,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

abstract class _BrandVectors {
  static String facebook(String color) => '''
<svg viewBox="0 0 24 24">
  <path fill="$color" d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/>
</svg>
''';

  static String linkedin(String color) => '''
<svg viewBox="0 0 24 24">
  <path fill="$color" d="M19 3a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h14m-.5 15.5v-5.3a3.26 3.26 0 0 0-3.26-3.26c-.85 0-1.84.52-2.28 1.3v-1.11h-2.79v8.37h2.79v-4.93c0-.77.62-1.4 1.39-1.4a1.4 1.4 0 0 1 1.4 1.4v4.93h2.75M6.46 10.9v7.6h2.8v-7.6h-2.8M7.86 6.3a1.63 1.63 0 0 0-1.63 1.63c0 .9.73 1.63 1.63 1.63.9 0 1.63-.73 1.63-1.63 0-.9-.73-1.63-1.63-1.63Z"/>
</svg>
''';

  static String github(String color) => '''
<svg viewBox="0 0 24 24">
  <path fill="$color" d="M12 0C5.37 0 0 5.37 0 12c0 5.31 3.435 9.795 8.205 11.385.6.105.825-.255.825-.57 0-.285-.015-1.23-.015-2.235-3.015.555-3.795-.735-4.035-1.41-.135-.345-.72-1.41-1.23-1.695-.42-.225-1.02-.78-.015-.795.945-.015 1.62.87 1.845 1.23 1.08 1.815 2.805 1.305 3.495.99.105-.78.42-1.305.765-1.605-2.67-.3-5.46-1.335-5.46-5.925 0-1.305.465-2.385 1.23-3.225-.12-.3-.54-1.53.12-3.18 0 0 1.005-.315 3.3 1.23.96-.27 1.98-.405 3-.405s2.04.135 3 .405c2.295-1.56 3.3-1.23 3.3-1.23.66 1.65.24 2.88.12 3.18.765.84 1.23 1.905 1.23 3.225 0 4.605-2.805 5.625-5.475 5.925.435.375.81 1.095.81 2.22 0 1.605-.015 2.895-.015 3.3 0 .315.225.69.825.57A12.02 12.02 0 0 0 24 12c0-6.63-5.37-12-12-12z"/>
</svg>
''';

  static String email(String color) => '''
<svg viewBox="0 0 24 24">
  <path fill="$color" d="M20 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z"/>
</svg>
''';
}
