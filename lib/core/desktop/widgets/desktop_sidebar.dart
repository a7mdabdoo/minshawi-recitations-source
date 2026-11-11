import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../../core/widgets/developer_social_links.dart';
import '../../../features/player/presentation/cubit/audio_player_cubit.dart';
import '../../../features/player/presentation/cubit/audio_player_state.dart';

class DesktopSidebar extends StatelessWidget {
  final String currentPath;
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;

  const DesktopSidebar({
    super.key,
    required this.currentPath,
    required this.isCollapsed,
    required this.onToggleCollapse,
  });

  void _safeNavigate(BuildContext context, String path) {
    if (currentPath == path) return;
    context.go(path);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldPrimary : AppColors.goldDark;
    final bg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final sidebarWidth = isCollapsed ? 76.0 : 260.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOutCubic,
      width: sidebarWidth,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          left: BorderSide(color: border, width: 1.0),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = isCollapsed || constraints.maxWidth < 200;

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  isCompact ? 8 : 12,
                  16,
                  isCompact ? 8 : 12,
                  12,
                ),
                child: isCompact
                    ? Column(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: gold, width: 1.5),
                              image: const DecorationImage(
                                image: ResizeImage(
                                  AssetImage('assets/images/minshawi_portrait.jpg'),
                                  width: 76,
                                  height: 76,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            tooltip: 'توسيع القائمة الجانبية',
                            icon: Icon(
                              Icons.menu_rounded,
                              color: gold,
                              size: 22,
                            ),
                            onPressed: onToggleCollapse,
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            tooltip: isDark ? 'الوضع النهاري' : 'الوضع الليلي',
                            icon: Icon(
                              isDark
                                  ? Icons.light_mode_rounded
                                  : Icons.dark_mode_rounded,
                              color: gold,
                              size: 18,
                            ),
                            onPressed: () => context.read<ThemeCubit>().toggle(),
                          ),
                        ],
                      )
                    : ClipRect(
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: gold, width: 1.5),
                                image: const DecorationImage(
                                  image: ResizeImage(
                                    AssetImage('assets/images/minshawi_portrait.jpg'),
                                    width: 76,
                                    height: 76,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'تلاوات المنشاوي',
                                    style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: gold,
                                      height: 1.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'الشيخ محمد صديق المنشاوي',
                                    style: GoogleFonts.cairo(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: textSecondary,
                                      height: 1.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              tooltip: isDark ? 'الوضع النهاري' : 'الوضع الليلي',
                              icon: Icon(
                                isDark
                                    ? Icons.light_mode_rounded
                                    : Icons.dark_mode_rounded,
                                color: gold,
                                size: 18,
                              ),
                              onPressed: () => context.read<ThemeCubit>().toggle(),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              tooltip: 'طي القائمة الجانبية',
                              icon: Icon(
                                Icons.menu_open_rounded,
                                color: gold,
                                size: 20,
                              ),
                              onPressed: onToggleCollapse,
                            ),
                          ],
                        ),
                      ),
              ),
              Divider(color: border, height: 1),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 6 : 10,
                    vertical: 8,
                  ),
                  children: [
                    if (!isCompact)
                      _buildSectionHeader('المصاحف والتلاوات', textSecondary),
                    _SidebarItem(
                      icon: Icons.home_rounded,
                      title: 'الرئيسية',
                      route: '/',
                      currentPath: currentPath,
                      isCollapsed: isCompact,
                      onTap: () => _safeNavigate(context, '/'),
                    ),
                    _SidebarItem(
                      icon: Icons.auto_stories_rounded,
                      title: 'المصحف المرتل',
                      badgeText: '١١٤',
                      route: '/recitations/complete_murattal',
                      currentPath: currentPath,
                      isCollapsed: isCompact,
                      onTap: () =>
                          _safeNavigate(context, '/recitations/complete_murattal'),
                    ),
                    _SidebarItem(
                      icon: Icons.menu_book_rounded,
                      title: 'المصحف المجود',
                      badgeText: '١١٤',
                      route: '/recitations/mojawad',
                      currentPath: currentPath,
                      isCollapsed: isCompact,
                      onTap: () => _safeNavigate(context, '/recitations/mojawad'),
                    ),
                    _SidebarItem(
                      icon: Icons.star_rounded,
                      title: AppConstants.rare1387Title,
                      badgeText: '٢٦',
                      route: '/recitations/rare_1387',
                      currentPath: currentPath,
                      isCollapsed: isCompact,
                      onTap: () => _safeNavigate(context, '/recitations/rare_1387'),
                    ),
                    _SidebarItem(
                      icon: Icons.graphic_eq_rounded,
                      title: AppConstants.mahafilTitle,
                      badgeText: AppConstants.mahafilCountAr,
                      route: '/recitations/nahawand',
                      currentPath: currentPath,
                      isCollapsed: isCompact,
                      onTap: () => _safeNavigate(context, '/recitations/nahawand'),
                    ),
                    BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
                      builder: (context, playerState) {
                        final isRadioPlaying = playerState is AudioPlayerReady &&
                            playerState.recitation.isRadio &&
                            playerState.isPlaying;
                        return _RadioSidebarItem(
                          isCollapsed: isCompact,
                          isPlaying: isRadioPlaying,
                          onTap: () {
                            final cubit = context.read<AudioPlayerCubit>();
                            if (isRadioPlaying) {
                              cubit.pause();
                            } else {
                              cubit.play(AppConstants.minshawiRadio);
                            }
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    if (!isCompact)
                      _buildSectionHeader('مكتبتي الخاصة', textSecondary),
                    _SidebarItem(
                      icon: Icons.download_done_rounded,
                      title: 'التلاوات المحملة',
                      route: '/downloads',
                      currentPath: currentPath,
                      isCollapsed: isCompact,
                      onTap: () => _safeNavigate(context, '/downloads'),
                    ),
                    _SidebarItem(
                      icon: Icons.favorite_rounded,
                      title: 'المفضلة',
                      route: '/favorites',
                      currentPath: currentPath,
                      isCollapsed: isCompact,
                      onTap: () => _safeNavigate(context, '/favorites'),
                    ),
                    _SidebarItem(
                      icon: Icons.playlist_play_rounded,
                      title: 'قوائم التشغيل',
                      route: '/playlists',
                      currentPath: currentPath,
                      isCollapsed: isCompact,
                      onTap: () => _safeNavigate(context, '/playlists'),
                    ),
                  ],
                ),
              ),
              Divider(color: border, height: 1),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 6 : 14,
                  vertical: 10,
                ),
                child: isCompact
                    ? Tooltip(
                        message:
                            'تطوير: ${AppConstants.devNameAr}\n\nالإصدار v1.2.2',
                        child: Center(
                          child: Icon(
                            Icons.verified_user_rounded,
                            size: 20,
                            color: gold.withAlpha(180),
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'تطوير: ${AppConstants.devNameAr}',
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: DeveloperSocialLinks(
                              iconSize: 15,
                              spacing: 6,
                              buttonPadding: EdgeInsets.all(4),
                              borderRadius: 8,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'الإصدار v1.2.2 • ويندوز وويب',
                            style: GoogleFonts.cairo(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: gold.withAlpha(190),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color.withAlpha(200),
        ),
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? badgeText;
  final String route;
  final String currentPath;
  final bool isCollapsed;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.title,
    this.badgeText,
    required this.route,
    required this.currentPath,
    required this.isCollapsed,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  bool get _isActive {
    if (widget.route == '/') {
      return widget.currentPath == '/';
    }
    return widget.currentPath.startsWith(widget.route);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldPrimary : AppColors.goldDark;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final isActive = _isActive;

    final itemBg = isActive
        ? gold.withAlpha(isDark ? 36 : 28)
        : (_isHovered
            ? (isDark ? Colors.white.withAlpha(12) : Colors.black.withAlpha(8))
            : Colors.transparent);

    final itemColor = isActive
        ? gold
        : (_isHovered ? textPrimary : textSecondary);

    final itemWidget = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(vertical: 2.5),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isCollapsed ? 0 : 12,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: itemBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive
                  ? gold.withAlpha(isDark ? 90 : 70)
                  : Colors.transparent,
              width: 1.0,
            ),
          ),
          child: widget.isCollapsed
              ? Center(
                  child: Icon(
                    widget.icon,
                    size: 21,
                    color: itemColor,
                  ),
                )
              : ClipRect(
                  child: Row(
                  children: [
                    Icon(
                      widget.icon,
                      size: 20,
                      color: itemColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: GoogleFonts.cairo(
                          fontSize: 12.5,
                          height: 1.25,
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w600,
                          color: itemColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.badgeText != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: isActive
                              ? gold.withAlpha(isDark ? 70 : 45)
                              : (isDark
                                  ? Colors.white.withAlpha(16)
                                  : Colors.black.withAlpha(10)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          widget.badgeText!,
                          style: GoogleFonts.cairo(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: itemColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
        ),
      ),
    );

    if (widget.isCollapsed) {
      return Tooltip(
        message: widget.badgeText != null
            ? '${widget.title} (${widget.badgeText})'
            : widget.title,
        child: itemWidget,
      );
    }

    return itemWidget;
  }
}

class _RadioSidebarItem extends StatefulWidget {
  final bool isCollapsed;
  final bool isPlaying;
  final VoidCallback onTap;

  const _RadioSidebarItem({
    required this.isCollapsed,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  State<_RadioSidebarItem> createState() => _RadioSidebarItemState();
}

class _RadioSidebarItemState extends State<_RadioSidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.goldPrimary : AppColors.goldDark;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final isPlaying = widget.isPlaying;

    final itemBg = isPlaying
        ? gold.withAlpha(isDark ? 42 : 32)
        : (_isHovered
            ? (isDark ? Colors.white.withAlpha(12) : Colors.black.withAlpha(8))
            : Colors.transparent);

    final itemColor =
        isPlaying ? gold : (_isHovered ? textPrimary : textSecondary);

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.symmetric(vertical: 2.5),
      padding: EdgeInsets.symmetric(
        horizontal: widget.isCollapsed ? 0 : 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: itemBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isPlaying
              ? gold.withAlpha(isDark ? 100 : 80)
              : Colors.transparent,
          width: 1.0,
        ),
      ),
      child: widget.isCollapsed
          ? Center(
              child: Icon(
                isPlaying ? Icons.radio_rounded : Icons.radio_outlined,
                size: 21,
                color: itemColor,
              ),
            )
          : ClipRect(
              child: Row(
                children: [
                  Icon(
                    isPlaying ? Icons.radio_rounded : Icons.radio_outlined,
                    size: 20,
                    color: itemColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'إذاعة القرآن الكريم',
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight:
                            isPlaying ? FontWeight.w700 : FontWeight.w600,
                        color: itemColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: isPlaying
                          ? gold
                          : (isDark
                              ? Colors.white.withAlpha(16)
                              : Colors.black.withAlpha(10)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isPlaying ? 'يعمل' : 'مباشر',
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isPlaying
                            ? (isDark ? AppColors.darkBackground : Colors.white)
                            : itemColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );

    if (widget.isCollapsed) {
      return Tooltip(
        message: isPlaying
            ? 'إيقاف إذاعة القرآن الكريم'
            : 'إذاعة القرآن الكريم (بث مباشر)',
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.onTap,
            child: content,
          ),
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: content,
      ),
    );
  }
}
