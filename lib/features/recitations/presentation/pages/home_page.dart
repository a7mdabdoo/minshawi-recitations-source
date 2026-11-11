import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/settings/settings_cubit.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/utils/formatters.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../favorites/presentation/cubit/favorites_state.dart';
import '../../../playlists/presentation/widgets/add_to_playlist_bottom_sheet.dart';
import '../../../player/presentation/cubit/audio_player_cubit.dart';
import '../../../player/presentation/cubit/audio_player_state.dart';
import '../../../player/presentation/widgets/mini_player.dart';
import '../../data/models/nahawand_recitation_model.dart';
import '../../domain/entities/recitation.dart';
import '../cubit/download_cubit.dart';
import '../cubit/download_state.dart';
import '../cubit/recitation_list_cubit.dart';
import '../cubit/recitation_list_state.dart';

class HomePage extends StatelessWidget {
  final String collectionId;
  final bool initialFavoritesTab;
  const HomePage({
    super.key,
    this.collectionId = 'rare_1387',
    this.initialFavoritesTab = false,
  });

  @override
  Widget build(BuildContext context) {
    context
        .read<RecitationListCubit>()
        .loadRecitations(collectionId: collectionId);
    return _HomeView(
      collectionId: collectionId,
      initialFavoritesTab: initialFavoritesTab,
    );
  }
}

enum _ListTab { golden, all, favorites }

class _HomeView extends StatefulWidget {
  final String collectionId;
  final bool initialFavoritesTab;
  const _HomeView({
    required this.collectionId,
    this.initialFavoritesTab = false,
  });

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> with WidgetsBindingObserver {
  late _ListTab _selectedTab;
  String? _selectedPlaceGroup;
  String? _selectedSurahCategory;

  _ListTab _defaultTabFor(String collectionId, bool initialFavoritesTab) {
    if (initialFavoritesTab) return _ListTab.favorites;
    if (collectionId == 'nahawand') return _ListTab.golden;
    return _ListTab.all;
  }

  @override
  void initState() {
    super.initState();
    _selectedTab =
        _defaultTabFor(widget.collectionId, widget.initialFavoritesTab);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(covariant _HomeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.collectionId != oldWidget.collectionId ||
        widget.initialFavoritesTab != oldWidget.initialFavoritesTab) {
      setState(() {
        _selectedTab =
            _defaultTabFor(widget.collectionId, widget.initialFavoritesTab);
        _selectedPlaceGroup = null;
        _selectedSurahCategory = null;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      context.read<AudioPlayerCubit>().saveCurrentPosition();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLarge = MediaQuery.sizeOf(context).width >= 600;

    return MultiBlocListener(
      listeners: [
        BlocListener<RecitationListCubit, RecitationListState>(
          listener: (context, state) {
            if (state is RecitationListLoaded) {
              context
                  .read<AudioPlayerCubit>()
                  .updatePlaylist(state.recitations);
            }
          },
        ),
        BlocListener<AudioPlayerCubit, AudioPlayerState>(
          listenWhen: (prev, curr) => curr is AudioPlayerError,
          listener: (context, state) {
            if (state is AudioPlayerError) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        color: AppColors.goldPrimary,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          state.message,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.darkCardSurface,
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    (isLarge ? 16.0 : 96.0) +
                        MediaQuery.of(context).padding.bottom,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: AppColors.goldPrimary.withAlpha(160),
                      width: 1.2,
                    ),
                  ),
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          },
        ),
        BlocListener<DownloadCubit, DownloadState>(
          listenWhen: (prev, curr) =>
              curr.lastError != null && prev.lastError != curr.lastError,
          listener: (context, state) {
            if (state.lastError != null) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        state.lastError!.contains('مساحة')
                            ? Icons.sd_card_alert_rounded
                            : Icons.cloud_off_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          state.lastError!,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.darkCardSurface,
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    (isLarge ? 16.0 : 96.0) +
                        MediaQuery.of(context).padding.bottom,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: AppColors.darkError.withAlpha(180),
                      width: 1.2,
                    ),
                  ),
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        bottomNavigationBar: const MiniPlayer(),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _AppBar(
              isDark: isDark,
              collectionId: widget.collectionId,
            ),
            _FilterTabs(
              selectedTab: _selectedTab,
              isDark: isDark,
              collectionId: widget.collectionId,
              onTabSelected: (tab) => setState(() => _selectedTab = tab),
            ),
            _SearchBar(
              isDark: isDark,
              collectionId: widget.collectionId,
              selectedTab: _selectedTab,
              selectedPlaceGroup: _selectedPlaceGroup,
              selectedSurahCategory: _selectedSurahCategory,
              onFiltersApplied: (place, category) => setState(() {
                _selectedPlaceGroup = place;
                _selectedSurahCategory = category;
              }),
              onResetFilters: () => setState(() {
                _selectedPlaceGroup = null;
                _selectedSurahCategory = null;
              }),
            ),
            _ResumePlaybackBanner(isDark: isDark),
            _Body(
              isDark: isDark,
              collectionId: widget.collectionId,
              selectedTab: _selectedTab,
              selectedPlaceGroup: _selectedPlaceGroup,
              selectedSurahCategory: _selectedSurahCategory,
              onSwitchToAll: () => setState(() => _selectedTab = _ListTab.all),
              onResetFilters: () => setState(() {
                _selectedPlaceGroup = null;
                _selectedSurahCategory = null;
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  final bool isDark;
  final String collectionId;
  const _AppBar({required this.isDark, required this.collectionId});

  @override
  Widget build(BuildContext context) {
    final title = switch (collectionId) {
      'mojawad' => 'المصحف المجود',
      'complete_murattal' => 'المصحف المرتل',
      'nahawand' => AppConstants.mahafilTitle,
      _ => AppConstants.rare1387Title,
    };
    final subtitle = switch (collectionId) {
      'mojawad' => 'الشيخ محمد صديق المنشاوي (١١٤ سورة)',
      'complete_murattal' => 'الشيخ محمد صديق المنشاوي (١١٤ سورة)',
      'nahawand' =>
        'الشيخ محمد صديق المنشاوي (${AppConstants.mahafilCountAr} تلاوة)',
      _ => 'الشيخ محمد صديق المنشاوي (٢٦ سورة)',
    };

    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      stretch: true,
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_rounded,
          color: isDark ? AppColors.goldPrimary : AppColors.goldDark,
        ),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(AppRoutes.landing);
          }
        },
        tooltip: 'الرئيسية',
      ),
      actions: [
        if (MediaQuery.sizeOf(context).width < 600) ...[
          IconButton(
            icon: Icon(
              Icons.queue_music_rounded,
              color: isDark ? AppColors.goldPrimary : AppColors.goldDark,
            ),
            onPressed: () => context.push(AppRoutes.playlists),
            tooltip: 'قوائم التشغيل',
          ),
          IconButton(
            icon: Icon(
              Icons.folder_special_outlined,
              color: isDark ? AppColors.goldPrimary : AppColors.goldDark,
            ),
            onPressed: () =>
                context.push('${AppRoutes.downloads}?collectionId=$collectionId'),
            tooltip: 'التلاوات المحمّلة',
          ),
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? AppColors.goldPrimary : AppColors.goldDark,
            ),
            onPressed: () => context.read<ThemeCubit>().toggle(),
            tooltip: isDark ? 'الوضع النهاري' : 'الوضع الليلي',
          ),
          const SizedBox(width: 4),
        ],
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(right: 56, bottom: 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: GoogleFonts.amiri(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.goldPrimary : AppColors.goldDark,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.cairo(
                fontSize: 10.5,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
        background: _AppBarBackground(isDark: isDark),
      ),
    );
  }
}

class _AppBarBackground extends StatelessWidget {
  final bool isDark;
  const _AppBarBackground({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isDark
              ? [AppColors.darkCardSurface, AppColors.darkBackground]
              : [AppColors.lightCardSurface, AppColors.lightBackground],
        ),
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, top: 50),
          child: Text(
            '﷽',
            style: GoogleFonts.amiri(
              fontSize: 28,
              color: isDark
                  ? AppColors.goldPrimary.withAlpha(60)
                  : AppColors.goldDark.withAlpha(40),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final _ListTab selectedTab;
  final bool isDark;
  final String collectionId;
  final ValueChanged<_ListTab> onTabSelected;

  const _FilterTabs({
    required this.selectedTab,
    required this.isDark,
    required this.collectionId,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final gold = isDark ? AppColors.goldPrimary : AppColors.goldDark;
    final bg = isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface;
    final isLarge = MediaQuery.sizeOf(context).width >= 600;
    final hPad = isLarge ? 20.0 : 16.0;

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 4),
        child: BlocBuilder<RecitationListCubit, RecitationListState>(
          buildWhen: (prev, curr) =>
              (prev is RecitationListLoaded ? prev.recitations.length : 0) !=
              (curr is RecitationListLoaded ? curr.recitations.length : 0),
          builder: (context, listState) {
            final currentItems = listState is RecitationListLoaded
                ? listState.recitations
                : const <Recitation>[];

            return BlocBuilder<FavoritesCubit, FavoritesState>(
              buildWhen: (prev, curr) =>
                  prev.favoriteIds.length != curr.favoriteIds.length ||
                  prev.favoriteIds != curr.favoriteIds,
              builder: (context, favState) {
                final count = currentItems
                    .where((item) => favState.isFavorite(item.id))
                    .length;

                if (collectionId == 'nahawand') {
                  return Row(
                    children: [
                      Expanded(
                        child: _TabButton(
                          icon: Icons.star_rounded,
                          label: 'المختارات الذهبية',
                          isSelected: selectedTab == _ListTab.golden,
                          gold: gold,
                          bg: bg,
                          isDark: isDark,
                          onTap: () => onTabSelected(_ListTab.golden),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _TabButton(
                          icon: Icons.list_alt_rounded,
                          label: 'كل المحافل',
                          isSelected: selectedTab == _ListTab.all,
                          gold: gold,
                          bg: bg,
                          isDark: isDark,
                          onTap: () => onTabSelected(_ListTab.all),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: isLarge ? 140 : 96,
                        child: _TabButton(
                          icon: Icons.favorite_rounded,
                          label: 'المفضلة ($count)',
                          isSelected: selectedTab == _ListTab.favorites,
                          gold: gold,
                          bg: bg,
                          isDark: isDark,
                          onTap: () => onTabSelected(_ListTab.favorites),
                        ),
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: _TabButton(
                        icon: Icons.list_alt_rounded,
                        label: 'التلاوات',
                        isSelected: selectedTab == _ListTab.all,
                        gold: gold,
                        bg: bg,
                        isDark: isDark,
                        onTap: () => onTabSelected(_ListTab.all),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _TabButton(
                        icon: Icons.favorite_rounded,
                        label: 'المفضلة ($count)',
                        isSelected: selectedTab == _ListTab.favorites,
                        gold: gold,
                        bg: bg,
                        isDark: isDark,
                        onTap: () => onTabSelected(_ListTab.favorites),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color gold;
  final Color bg;
  final bool isDark;
  final VoidCallback onTap;

  const _TabButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.gold,
    required this.bg,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? gold : bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? gold
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: gold.withAlpha(isDark ? 70 : 40),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: isSelected
                    ? (isDark ? AppColors.darkBackground : Colors.white)
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? (isDark ? AppColors.darkBackground : Colors.white)
                        : (isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  final bool isDark;
  final String collectionId;
  final _ListTab selectedTab;
  final String? selectedPlaceGroup;
  final String? selectedSurahCategory;
  final void Function(String? placeGroup, String? surahCategory)
      onFiltersApplied;
  final VoidCallback onResetFilters;

  const _SearchBar({
    required this.isDark,
    required this.collectionId,
    required this.selectedTab,
    required this.selectedPlaceGroup,
    required this.selectedSurahCategory,
    required this.onFiltersApplied,
    required this.onResetFilters,
  });

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void didUpdateWidget(covariant _SearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.collectionId != oldWidget.collectionId) {
      _debounce?.cancel();
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openFilterModal(
    BuildContext context,
    RecitationListLoaded listState,
  ) async {
    final availablePlaces = <String>{};
    final availableCategories = <String>{};
    for (final r in listState.recitations) {
      if (r is NahawandRecitationModel) {
        if (r.placeGroup.isNotEmpty) availablePlaces.add(r.placeGroup);
        if (r.category.isNotEmpty) availableCategories.add(r.category);
      }
    }

    final orderedPlaces = [
      for (final p in _mahafilPlaceOrder)
        if (availablePlaces.contains(p)) p,
      for (final p in availablePlaces)
        if (!_mahafilPlaceOrder.contains(p)) p,
    ];

    final orderedCategories = [
      for (final c in _mahafilSurahCategoryOrder)
        if (availableCategories.contains(c)) c,
      for (final c in availableCategories)
        if (!_mahafilSurahCategoryOrder.contains(c)) c,
    ];

    final favoriteIds = widget.selectedTab == _ListTab.favorites
        ? context.read<FavoritesCubit>().state.favoriteIds
        : null;

    final isWide = MediaQuery.sizeOf(context).width >= 600;
    final bg =
        widget.isDark ? AppColors.darkSurface : AppColors.lightBackground;
    final border = widget.isDark ? AppColors.darkBorder : AppColors.lightBorder;

    Widget buildContent(BuildContext modalCtx) {
      return _MahafilFilterModalContent(
        isDark: widget.isDark,
        filteredItems: listState.filtered,
        selectedTab: widget.selectedTab,
        favoriteIds: favoriteIds,
        places: orderedPlaces,
        categories: orderedCategories,
        initialPlace: widget.selectedPlaceGroup,
        initialCategory: widget.selectedSurahCategory,
        onApply: (place, category) {
          widget.onFiltersApplied(place, category);
          Navigator.of(modalCtx).pop();
        },
      );
    }

    if (isWide) {
      await showDialog<void>(
        context: context,
        builder: (dialogCtx) => Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            backgroundColor: bg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: border),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 560,
                maxHeight: 640,
              ),
              child: buildContent(dialogCtx),
            ),
          ),
        ),
      );
    } else {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: bg,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        builder: (sheetCtx) => Directionality(
          textDirection: TextDirection.rtl,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(sheetCtx).height * 0.82,
            ),
            child: buildContent(sheetCtx),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final gold = isDark ? AppColors.goldPrimary : AppColors.goldDark;
    final cardBg =
        isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final hPad = MediaQuery.sizeOf(context).width >= 600 ? 20.0 : 16.0;
    final isMahafil = widget.collectionId == 'nahawand';
    final activeCount = (widget.selectedPlaceGroup != null ? 1 : 0) +
        (widget.selectedSurahCategory != null ? 1 : 0);

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.cairo(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'ابحث عن سورة بالاسم أو الرقم...',
                      hintStyle: GoogleFonts.cairo(
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: isDark
                            ? AppColors.darkIconColor
                            : AppColors.lightIconColor,
                      ),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear_rounded,
                                color: isDark
                                    ? AppColors.darkTextTertiary
                                    : AppColors.lightTextTertiary,
                                size: 18,
                              ),
                              onPressed: () {
                                _debounce?.cancel();
                                _controller.clear();
                                context.read<RecitationListCubit>().search('');
                                setState(() {});
                              },
                              tooltip: 'مسح البحث',
                            )
                          : null,
                      filled: true,
                      fillColor: cardBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: gold, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (q) {
                      setState(() {});
                      _debounce?.cancel();
                      if (q.trim().isEmpty) {
                        context.read<RecitationListCubit>().search('');
                        return;
                      }
                      _debounce = Timer(const Duration(milliseconds: 140), () {
                        if (mounted) {
                          context.read<RecitationListCubit>().search(q);
                        }
                      });
                    },
                  ),
                ),
                if (isMahafil) ...[
                  const SizedBox(width: 8),
                  BlocBuilder<RecitationListCubit, RecitationListState>(
                    builder: (context, listState) {
                      final canOpen = listState is RecitationListLoaded &&
                          listState.recitations.isNotEmpty;
                      final hasFilters = activeCount > 0;
                      return Tooltip(
                        message: 'تصفية حسب المكان والسور',
                        child: Material(
                          key: const ValueKey('mahafil_filter_button'),
                          color: hasFilters ? gold.withAlpha(28) : cardBg,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: canOpen
                                ? () => _openFilterModal(context, listState)
                                : null,
                            child: Container(
                              height: 48,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: hasFilters ? gold : border,
                                  width: hasFilters ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.tune_rounded,
                                    size: 19,
                                    color: hasFilters ? gold : textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    hasFilters
                                        ? 'تصفية ($activeCount)'
                                        : 'تصفية',
                                    style: GoogleFonts.cairo(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: hasFilters ? gold : textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
            if (isMahafil && activeCount > 0)
              BlocBuilder<RecitationListCubit, RecitationListState>(
                builder: (context, listState) {
                  if (listState is! RecitationListLoaded) {
                    return const SizedBox.shrink();
                  }
                  final favoriteIds = widget.selectedTab == _ListTab.favorites
                      ? context.watch<FavoritesCubit>().state.favoriteIds
                      : null;
                  final shownCount = _filterMahafilRecitations(
                    items: listState.filtered,
                    selectedTab: widget.selectedTab,
                    placeGroup: widget.selectedPlaceGroup,
                    surahCategory: widget.selectedSurahCategory,
                    favoriteIds: favoriteIds,
                  ).length;

                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (widget.selectedPlaceGroup != null)
                          _ActiveFilterChip(
                            label: widget.selectedPlaceGroup == 'أخرى'
                                ? 'المكان: محافل أخرى'
                                : 'المكان: ${widget.selectedPlaceGroup}',
                            gold: gold,
                            onRemove: () => widget.onFiltersApplied(
                              null,
                              widget.selectedSurahCategory,
                            ),
                          ),
                        if (widget.selectedSurahCategory != null)
                          _ActiveFilterChip(
                            label: 'السور: ${widget.selectedSurahCategory}',
                            gold: gold,
                            onRemove: () => widget.onFiltersApplied(
                              widget.selectedPlaceGroup,
                              null,
                            ),
                          ),
                        Text(
                          'النتائج: $shownCount تلاوة',
                          style: GoogleFonts.cairo(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: widget.onResetFilters,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            child: Text(
                              'إعادة ضبط الفلاتر',
                              style: GoogleFonts.cairo(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: gold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

const List<String> _mahafilPlaceOrder = [
  'المسجد الأقصى',
  'مصر',
  'سوريا ودمشق',
  'الكويت',
  'ليبيا',
  'الإذاعة والاستوديو',
  'أخرى',
];

const List<String> _mahafilSurahCategoryOrder = [
  'البقرة والفاتحة',
  'آل عمران',
  'النساء والمائدة',
  'الأنعام والأعراف والأنفال',
  'التوبة ويونس وهود',
  'يوسف',
  'الرعد وإبراهيم والنحل',
  'الإسراء والكهف',
  'مريم وطه',
  'الأنبياء والحج والمؤمنون',
  'النور والفرقان والشعراء',
  'النمل والقصص والعنكبوت',
  'الروم ولقمان والأحزاب',
  'سبأ إلى الأحقاف',
  'ق والرحمن والواقعة',
  'الحشر والصف',
  'الفجر وقصار السور',
];

List<Recitation> _filterMahafilRecitations({
  required List<Recitation> items,
  required _ListTab selectedTab,
  String? placeGroup,
  String? surahCategory,
  Set<String>? favoriteIds,
}) {
  Iterable<Recitation> result = items;

  if (selectedTab == _ListTab.golden) {
    result = result.where((r) => r.isRare);
  } else if (selectedTab == _ListTab.favorites && favoriteIds != null) {
    result = result.where((r) => favoriteIds.contains(r.id));
  }

  if (placeGroup != null || surahCategory != null) {
    result = result.where((r) {
      if (r is! NahawandRecitationModel) return false;
      if (placeGroup != null && r.placeGroup != placeGroup) return false;
      if (surahCategory != null && r.category != surahCategory) return false;
      return true;
    });
  }

  return result.toList();
}

class _ActiveFilterChip extends StatelessWidget {
  final String label;
  final Color gold;
  final VoidCallback onRemove;

  const _ActiveFilterChip({
    required this.label,
    required this.gold,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: gold.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gold.withAlpha(140)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: gold,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onRemove,
            child: Icon(Icons.close_rounded, size: 15, color: gold),
          ),
        ],
      ),
    );
  }
}

class _MahafilFilterModalContent extends StatefulWidget {
  final bool isDark;
  final List<Recitation> filteredItems;
  final _ListTab selectedTab;
  final Set<String>? favoriteIds;
  final List<String> places;
  final List<String> categories;
  final String? initialPlace;
  final String? initialCategory;
  final void Function(String? place, String? category) onApply;

  const _MahafilFilterModalContent({
    required this.isDark,
    required this.filteredItems,
    required this.selectedTab,
    required this.favoriteIds,
    required this.places,
    required this.categories,
    required this.initialPlace,
    required this.initialCategory,
    required this.onApply,
  });

  @override
  State<_MahafilFilterModalContent> createState() =>
      _MahafilFilterModalContentState();
}

class _MahafilFilterModalContentState
    extends State<_MahafilFilterModalContent> {
  late String? _place;
  late String? _category;

  @override
  void initState() {
    super.initState();
    _place = widget.initialPlace;
    _category = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    final gold = widget.isDark ? AppColors.goldPrimary : AppColors.goldDark;
    final cardBg =
        widget.isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface;
    final border = widget.isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary =
        widget.isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = widget.isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final previewCount = _filterMahafilRecitations(
      items: widget.filteredItems,
      selectedTab: widget.selectedTab,
      placeGroup: _place,
      surahCategory: _category,
      favoriteIds: widget.favoriteIds,
    ).length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Row(
            children: [
              Icon(Icons.tune_rounded, color: gold, size: 20),
              const SizedBox(width: 8),
              Text(
                'تصفية المحافل',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              const Spacer(),
              if (_place != null || _category != null)
                TextButton(
                  onPressed: () => setState(() {
                    _place = null;
                    _category = null;
                  }),
                  child: Text(
                    'إعادة ضبط',
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: gold,
                    ),
                  ),
                ),
              IconButton(
                icon: Icon(Icons.close_rounded, color: textSecondary),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'إغلاق',
              ),
            ],
          ),
        ),
        Divider(height: 1, color: border),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.places.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: gold),
                      const SizedBox(width: 6),
                      Text(
                        'حسب المكان',
                        style: GoogleFonts.cairo(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _FilterPillChip(
                        label: 'الكل',
                        isSelected: _place == null,
                        gold: gold,
                        cardBg: cardBg,
                        border: border,
                        textSecondary: textSecondary,
                        isDark: widget.isDark,
                        onTap: () => setState(() => _place = null),
                      ),
                      for (final p in widget.places)
                        _FilterPillChip(
                          label: p == 'أخرى' ? 'محافل أخرى' : p,
                          isSelected: _place == p,
                          gold: gold,
                          cardBg: cardBg,
                          border: border,
                          textSecondary: textSecondary,
                          isDark: widget.isDark,
                          onTap: () =>
                              setState(() => _place = _place == p ? null : p),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                ],
                if (widget.categories.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.menu_book_outlined, size: 16, color: gold),
                      const SizedBox(width: 6),
                      Text(
                        'حسب السور',
                        style: GoogleFonts.cairo(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _FilterPillChip(
                        label: 'الكل',
                        isSelected: _category == null,
                        gold: gold,
                        cardBg: cardBg,
                        border: border,
                        textSecondary: textSecondary,
                        isDark: widget.isDark,
                        onTap: () => setState(() => _category = null),
                      ),
                      for (final c in widget.categories)
                        _FilterPillChip(
                          label: c,
                          isSelected: _category == c,
                          gold: gold,
                          cardBg: cardBg,
                          border: border,
                          textSecondary: textSecondary,
                          isDark: widget.isDark,
                          onTap: () => setState(
                            () => _category = _category == c ? null : c,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        Divider(height: 1, color: border),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () => widget.onApply(_place, _category),
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor:
                    widget.isDark ? AppColors.darkBackground : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'عرض النتائج ($previewCount تلاوة)',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterPillChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color gold;
  final Color cardBg;
  final Color border;
  final Color textSecondary;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterPillChip({
    required this.label,
    required this.isSelected,
    required this.gold,
    required this.cardBg,
    required this.border,
    required this.textSecondary,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? gold : cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? gold : border,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected
                  ? (isDark ? AppColors.darkBackground : Colors.white)
                  : textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ResumePlaybackBanner extends StatefulWidget {
  final bool isDark;
  const _ResumePlaybackBanner({required this.isDark});

  @override
  State<_ResumePlaybackBanner> createState() => _ResumePlaybackBannerState();
}

class _ResumePlaybackBannerState extends State<_ResumePlaybackBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
      buildWhen: (previous, current) =>
          (previous is AudioPlayerIdle) != (current is AudioPlayerIdle),
      builder: (context, playerState) {
        if (playerState is! AudioPlayerIdle) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return BlocBuilder<SettingsCubit, SettingsState>(
          buildWhen: (prev, curr) =>
              prev.lastPlayedRecitationId != curr.lastPlayedRecitationId ||
              prev.lastPlayedPositionSeconds != curr.lastPlayedPositionSeconds,
          builder: (context, settingsState) {
            final lastId = settingsState.lastPlayedRecitationId;
            final lastSeconds = settingsState.lastPlayedPositionSeconds ?? 0;

            if (lastId == null ||
                lastId == 'radio_minshawi' ||
                lastId.startsWith('radio_') ||
                lastSeconds < 5) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }

            return BlocBuilder<RecitationListCubit, RecitationListState>(
              buildWhen: (prev, curr) =>
                  prev.runtimeType != curr.runtimeType ||
                  (prev is RecitationListLoaded &&
                      curr is RecitationListLoaded &&
                      prev.recitations.length != curr.recitations.length),
              builder: (context, listState) {
                if (listState is! RecitationListLoaded) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }

                Recitation? found;
                try {
                  found = listState.recitations.firstWhere(
                    (r) => r.id == lastId,
                  );
                } catch (_) {
                  found = null;
                }

                if (found == null) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }
                final recitation = found;

                final isDark = widget.isDark;
                final gold =
                    isDark ? AppColors.goldPrimary : AppColors.goldDark;
                final bg =
                    isDark ? AppColors.darkCardSurface : const Color(0xFFF1F5F9);
                final textPrimary = isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary;
                final textSecondary = isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary;
                final hPad = MediaQuery.sizeOf(context).width >= 600 ? 20.0 : 16.0;

                return SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: gold.withAlpha(isDark ? 90 : 60),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(isDark ? 50 : 15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: gold.withAlpha(isDark ? 40 : 30),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.history_rounded,
                              color: gold,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'استئناف الاستماع من حيث توقفت',
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  '${recitation.cleanSurahTitleWithVerses} · عند ${Formatters.formatDuration(lastSeconds)}',
                                  style: GoogleFonts.cairo(
                                    fontSize: 11,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: gold,
                              foregroundColor: isDark
                                  ? AppColors.darkBackground
                                  : Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(
                              Icons.play_arrow_rounded,
                              size: 18,
                            ),
                            label: Text(
                              'استئناف',
                              style: GoogleFonts.cairo(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onPressed: () {
                              context.read<AudioPlayerCubit>().play(
                                    recitation,
                                    initialPosition:
                                        Duration(seconds: lastSeconds),
                                    playlist: listState.recitations,
                                  );
                            },
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            icon: Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: textSecondary,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            visualDensity: VisualDensity.compact,
                            tooltip: 'إغلاق',
                            onPressed: () {
                              setState(() => _dismissed = true);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  final bool isDark;
  final String collectionId;
  final _ListTab selectedTab;
  final String? selectedPlaceGroup;
  final String? selectedSurahCategory;
  final VoidCallback? onSwitchToAll;
  final VoidCallback? onResetFilters;

  const _Body({
    required this.isDark,
    required this.collectionId,
    required this.selectedTab,
    this.selectedPlaceGroup,
    this.selectedSurahCategory,
    this.onSwitchToAll,
    this.onResetFilters,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecitationListCubit, RecitationListState>(
      builder: (context, state) {
        if (state is RecitationListLoading || state is RecitationListInitial) {
          return const SliverFillRemaining(child: _LoadingView());
        }

        if (state is RecitationListError) {
          return SliverFillRemaining(
            child: _ErrorView(message: state.message, isDark: isDark),
          );
        }

        if (state is RecitationListLoaded) {
          final favoriteIds = selectedTab == _ListTab.favorites
              ? context.watch<FavoritesCubit>().state.favoriteIds
              : null;

          final items = _filterMahafilRecitations(
            items: state.filtered,
            selectedTab: selectedTab,
            placeGroup: collectionId == 'nahawand' ? selectedPlaceGroup : null,
            surahCategory:
                collectionId == 'nahawand' ? selectedSurahCategory : null,
            favoriteIds: favoriteIds,
          );

          if (items.isEmpty) {
            final hasActiveFilter = selectedPlaceGroup != null ||
                selectedSurahCategory != null;
            if (selectedTab == _ListTab.favorites && !hasActiveFilter) {
              return SliverFillRemaining(
                child: _FavoritesEmptyView(isDark: isDark),
              );
            }

            final allTabCount = (collectionId == 'nahawand' &&
                    selectedTab == _ListTab.golden)
                ? _filterMahafilRecitations(
                    items: state.filtered,
                    selectedTab: _ListTab.all,
                    placeGroup: selectedPlaceGroup,
                    surahCategory: selectedSurahCategory,
                  ).length
                : 0;

            return SliverFillRemaining(
              child: _EmptyView(
                isDark: isDark,
                allMahafilFallbackCount: allTabCount,
                onSwitchToAll: allTabCount > 0 ? onSwitchToAll : null,
                onResetFilters: hasActiveFilter ? onResetFilters : null,
              ),
            );
          }
          return _RecitationList(items: items, isDark: isDark);
        }

        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: isDark ? AppColors.goldPrimary : AppColors.goldDark,
            strokeWidth: 2.5,
          ),
          const SizedBox(height: 20),
          Text(
            'جارٍ تحميل التلاوات...',
            style: GoogleFonts.cairo(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final bool isDark;
  const _ErrorView({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: isDark ? AppColors.darkError : AppColors.lightError,
            ),
            const SizedBox(height: 20),
            Text(
              'تعذّر تحميل التلاوات',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => context.read<RecitationListCubit>().refresh(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                'إعادة المحاولة',
                style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final bool isDark;
  final int allMahafilFallbackCount;
  final VoidCallback? onSwitchToAll;
  final VoidCallback? onResetFilters;

  const _EmptyView({
    required this.isDark,
    this.allMahafilFallbackCount = 0,
    this.onSwitchToAll,
    this.onResetFilters,
  });

  @override
  Widget build(BuildContext context) {
    final gold = isDark ? AppColors.goldPrimary : AppColors.goldDark;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 56,
              color: isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.lightTextTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              onSwitchToAll != null
                  ? 'لا توجد نتائج ضمن المختارات الذهبية لهذه التصفية'
                  : 'لا توجد نتائج مطابقة للبحث',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 15,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            if (onSwitchToAll != null || onResetFilters != null) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  if (onSwitchToAll != null)
                    ElevatedButton.icon(
                      onPressed: onSwitchToAll,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gold,
                        foregroundColor:
                            isDark ? AppColors.darkBackground : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.list_alt_rounded, size: 18),
                      label: Text(
                        'عرض في كل المحافل ($allMahafilFallbackCount)',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                      ),
                    ),
                  if (onResetFilters != null)
                    OutlinedButton.icon(
                      onPressed: onResetFilters,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: gold,
                        side: BorderSide(color: gold.withAlpha(150)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
                      label: Text(
                        'إعادة ضبط الفلاتر',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FavoritesEmptyView extends StatelessWidget {
  final bool isDark;
  const _FavoritesEmptyView({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final gold = isDark ? AppColors.goldPrimary : AppColors.goldDark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: gold.withAlpha(25),
                border: Border.all(color: gold.withAlpha(80), width: 1.5),
              ),
              child: Icon(
                Icons.favorite_border_rounded,
                size: 36,
                color: gold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'قائمة المفضلة فارغة',
              style: GoogleFonts.amiri(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'انقر على أيقونة القلب في بطاقة أي سورة لإضافتها إلى قائمة مفضلتك',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecitationList extends StatelessWidget {
  final List<Recitation> items;
  final bool isDark;
  const _RecitationList({required this.items, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isLarge = width >= 600;
    final bottomInset = isLarge ? 24.0 : (120.0 + MediaQuery.of(context).padding.bottom);

    if (isLarge) {
      return SliverPadding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, bottomInset),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: width > 1300 ? 460 : (width > 900 ? 420 : 460),
            mainAxisExtent: 106,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => _RecitationCard(
              recitation: items[index],
              isDark: isDark,
              displayIndex: index + 1,
            ),
            childCount: items.length,
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: true,
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, bottomInset),
      sliver: SliverList.separated(
        itemCount: items.length,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: true,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) => _RecitationCard(
          recitation: items[index],
          isDark: isDark,
          displayIndex: index + 1,
        ),
      ),
    );
  }
}

class _RecitationCard extends StatefulWidget {
  final Recitation recitation;
  final bool isDark;
  final int? displayIndex;
  const _RecitationCard({
    required this.recitation,
    required this.isDark,
    this.displayIndex,
  });

  @override
  State<_RecitationCard> createState() => _RecitationCardState();
}

class _RecitationCardState extends State<_RecitationCard> {
  bool _isHovered = false;

  void _showDeleteDialog(BuildContext context, DownloadCubit cubit) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor:
            widget.isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'حذف التلاوة المحمّلة',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w700,
            color:
                widget.isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        content: Text(
          'هل تريد حذف ${widget.recitation.cleanSurahTitleWithVerses} من التخزين المحلي؟',
          style: GoogleFonts.cairo(
            fontSize: 13,
            color: widget.isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(
                color: widget.isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkError,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              cubit.deleteDownload(widget.recitation);
            },
            child: Text(
              'حذف',
              style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.recitation;
    final nahawand = r is NahawandRecitationModel ? r : null;

    final isActive = context.select<AudioPlayerCubit, bool>((cubit) {
      final s = cubit.state;
      if (s is AudioPlayerReady) return s.recitation.id == r.id;
      if (s is AudioPlayerLoading) return s.recitation.id == r.id;
      return false;
    });

    final activeGold = widget.isDark ? AppColors.goldPrimary : AppColors.goldDark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: _isHovered
            ? Matrix4.translationValues(0, -2, 0)
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: isActive
              ? (widget.isDark
                  ? AppColors.goldPrimary.withAlpha(22)
                  : AppColors.goldDark.withAlpha(14))
              : (_isHovered
                  ? (widget.isDark ? const Color(0xFF1E2836) : const Color(0xFFF1F5F9))
                  : (widget.isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (_isHovered)
              BoxShadow(
                color: activeGold.withAlpha(widget.isDark ? 35 : 20),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
          border: Border.all(
            color: isActive
                ? activeGold.withAlpha(160)
                : (_isHovered
                    ? activeGold.withAlpha(widget.isDark ? 110 : 70)
                    : (r.isDownloaded
                        ? AppColors.downloadedColor.withAlpha(90)
                        : (widget.isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder))),
            width: isActive || _isHovered ? 1.5 : 1.0,
          ),
        ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            final playerCubit = context.read<AudioPlayerCubit>();
            final s = playerCubit.state;
            if (s is AudioPlayerReady && s.recitation.id == r.id) {
              playerCubit.togglePlayPause();
            } else {
              playerCubit.play(r);
            }
          },
          onLongPress: r.isDownloaded
              ? () => _showDeleteDialog(context, context.read<DownloadCubit>())
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                _SurahBadge(
                  number: nahawand != null
                      ? (widget.displayIndex ?? nahawand.nahawandId)
                      : r.surahNumber,
                  isActive: isActive,
                  isDark: widget.isDark,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              r.cleanSurahTitleWithVerses,
                              style: GoogleFonts.amiri(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isActive
                                    ? activeGold
                                    : (widget.isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (r.isDownloaded) ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.offline_pin_rounded,
                              size: 15,
                              color: AppColors.downloadedColor.withAlpha(200),
                            ),
                          ],
                        ],
                      ),
                      if (r.cleanLocationOrDetail.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          r.cleanLocationOrDetail,
                          style: GoogleFonts.cairo(
                            fontSize: 11.5,
                            color: widget.isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 5),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (nahawand != null || r.durationSeconds > 0) ...[
                            Flexible(
                              child: _MetaChip(
                                icon: Icons.access_time_rounded,
                                label: nahawand != null
                                    ? '${nahawand.durationFormatted} دقيقة'
                                    : Formatters.formatDuration(
                                        r.durationSeconds),
                                isDark: widget.isDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: _MetaChip(
                              icon: Icons.history_rounded,
                              label: nahawand != null
                                  ? nahawand.placeOrYear
                                  : (r.recordingYear.contains('/')
                                      ? r.recordingYear.split('/')[0].trim()
                                      : r.recordingYear),
                              isDark: widget.isDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                _CardActionButtons(
                  recitation: r,
                  isActive: isActive,
                  isDark: widget.isDark,
                  onDeleteRequested: () =>
                      _showDeleteDialog(context, context.read<DownloadCubit>()),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

class _SurahBadge extends StatelessWidget {
  final int number;
  final bool isActive;
  final bool isDark;
  const _SurahBadge({
    required this.number,
    required this.isActive,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isActive
              ? [AppColors.goldPrimary, AppColors.goldLight]
              : isDark
                  ? [AppColors.goldDark, AppColors.goldPrimary.withAlpha(180)]
                  : [AppColors.goldPrimary, AppColors.goldDark],
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.goldPrimary.withAlpha(100),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          number.toString(),
          style: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.darkBackground,
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color:
              isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
        ),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11,
              color: isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.lightTextTertiary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _CardActionButtons extends StatelessWidget {
  final Recitation recitation;
  final bool isActive;
  final bool isDark;
  final VoidCallback onDeleteRequested;

  const _CardActionButtons({
    required this.recitation,
    required this.isActive,
    required this.isDark,
    required this.onDeleteRequested,
  });

  @override
  Widget build(BuildContext context) {
    final gold = isDark ? AppColors.goldPrimary : AppColors.goldDark;
    final secondaryIconColor =
        isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          BlocBuilder<FavoritesCubit, FavoritesState>(
            buildWhen: (prev, curr) =>
                prev.isFavorite(recitation.id) !=
                curr.isFavorite(recitation.id),
            builder: (context, favState) {
              final isFav = favState.isFavorite(recitation.id);
              return PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  size: 20,
                  color: secondaryIconColor,
                ),
                color: isDark
                    ? AppColors.darkCardSurface
                    : AppColors.lightCardSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(2),
                constraints: const BoxConstraints(),
                tooltip: 'خيارات التلاوة',
                onSelected: (val) {
                  if (val == 'playlist') {
                    AddToPlaylistBottomSheet.show(context, recitation);
                  } else if (val == 'favorite') {
                    context
                        .read<FavoritesCubit>()
                        .toggleFavorite(recitation.id);
                  } else if (val == 'delete') {
                    onDeleteRequested();
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'playlist',
                    child: Row(
                      children: [
                        Icon(Icons.playlist_add_rounded, color: gold, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'إضافة إلى قائمة تشغيل',
                          style: GoogleFonts.cairo(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'favorite',
                    child: Row(
                      children: [
                        Icon(
                          isFav
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFav
                              ? const Color(0xFFEF4444)
                              : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isFav ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
                          style: GoogleFonts.cairo(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isFav ? const Color(0xFFEF4444) : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (recitation.isDownloaded)
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.darkError,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'حذف التنزيل',
                            style: GoogleFonts.cairo(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkError,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 2),
          BlocBuilder<DownloadCubit, DownloadState>(
            buildWhen: (prev, curr) {
              return prev.isDownloading(recitation.id) !=
                      curr.isDownloading(recitation.id) ||
                  prev.isPaused(recitation.id) !=
                      curr.isPaused(recitation.id) ||
                  prev.getProgress(recitation.id) !=
                      curr.getProgress(recitation.id);
            },
            builder: (context, downloadState) {
              final isDownloading = downloadState.isDownloading(recitation.id);
              final isPaused = downloadState.isPaused(recitation.id);
              final progress = downloadState.getProgress(recitation.id);
              final percent = (progress * 100).toInt();

              if (isDownloading) {
                return Tooltip(
                  message: 'إيقاف مؤقت ($percent%) · اضغط مطولاً للإلغاء',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      context
                          .read<DownloadCubit>()
                          .pauseDownload(recitation.id);
                    },
                    onLongPress: () {
                      context.read<DownloadCubit>().cancelDownload(recitation);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم إلغاء التحميل',
                            style: GoogleFonts.cairo(color: Colors.white),
                          ),
                          backgroundColor: AppColors.darkCardSurface,
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          width: MediaQuery.sizeOf(context).width >= 600
                              ? 420
                              : null,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 4),
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: progress > 0 ? progress : null,
                              strokeWidth: 2.4,
                              backgroundColor: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                              color: gold,
                            ),
                            Icon(
                              Icons.pause_rounded,
                              size: 15,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }

              if (isPaused) {
                return Tooltip(
                  message: 'استئناف التنزيل ($percent%) · اضغط مطولاً للإلغاء',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      context.read<DownloadCubit>().resumeDownload(recitation);
                    },
                    onLongPress: () {
                      context.read<DownloadCubit>().cancelDownload(recitation);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم إلغاء التحميل',
                            style: GoogleFonts.cairo(color: Colors.white),
                          ),
                          backgroundColor: AppColors.darkCardSurface,
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          width: MediaQuery.sizeOf(context).width >= 600
                              ? 420
                              : null,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 4),
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: progress > 0 ? progress : null,
                              strokeWidth: 2.4,
                              backgroundColor: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                              color: gold,
                            ),
                            Icon(
                              Icons.play_arrow_rounded,
                              size: 16,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }

              if (recitation.isDownloaded) {
                return IconButton(
                  icon: const Icon(
                    Icons.offline_pin_rounded,
                    size: 20,
                  ),
                  color: AppColors.downloadedColor.withAlpha(220),
                  onPressed: onDeleteRequested,
                  tooltip: 'تم التحميل (اضغط للحذف)',
                  padding: const EdgeInsets.all(2),
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(),
                );
              }

              return IconButton(
                icon: const Icon(
                  Icons.cloud_download_outlined,
                  size: 22,
                ),
                color: AppColors.availableColor,
                onPressed: () {
                  context.read<DownloadCubit>().startDownload(recitation);
                },
                tooltip: 'تحميل للاستماع بدون إنترنت',
                padding: const EdgeInsets.all(2),
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(),
              );
            },
          ),
          const SizedBox(width: 2),
          BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
            buildWhen: (prev, curr) {
              final prevActive = (prev is AudioPlayerReady &&
                      prev.recitation.id == recitation.id) ||
                  (prev is AudioPlayerLoading &&
                      prev.recitation.id == recitation.id);
              final currActive = (curr is AudioPlayerReady &&
                      curr.recitation.id == recitation.id) ||
                  (curr is AudioPlayerLoading &&
                      curr.recitation.id == recitation.id);
              final prevPlaying = prev is AudioPlayerReady && prev.isPlaying;
              final currPlaying = curr is AudioPlayerReady && curr.isPlaying;
              return prevActive != currActive ||
                  prevPlaying != currPlaying ||
                  (prev is AudioPlayerLoading) != (curr is AudioPlayerLoading);
            },
            builder: (context, playerState) {
              final isThisActive = (playerState is AudioPlayerReady &&
                      playerState.recitation.id == recitation.id) ||
                  (playerState is AudioPlayerLoading &&
                      playerState.recitation.id == recitation.id);

              final isThisPlaying = isThisActive &&
                  playerState is AudioPlayerReady &&
                  playerState.isPlaying;

              final isThisLoading =
                  isThisActive && playerState is AudioPlayerLoading;

              if (isThisLoading) {
                return SizedBox(
                  width: 34,
                  height: 34,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: gold,
                    ),
                  ),
                );
              }

              return IconButton(
                icon: Icon(
                  isThisPlaying
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_fill_rounded,
                  size: 34,
                ),
                color: isThisActive ? gold : gold.withAlpha(210),
                onPressed: () {
                  final cubit = context.read<AudioPlayerCubit>();
                  if (isThisActive && playerState is AudioPlayerReady) {
                    cubit.togglePlayPause();
                  } else {
                    cubit.play(recitation);
                  }
                },
                tooltip: isThisPlaying ? 'إيقاف مؤقت' : 'تشغيل',
                padding: const EdgeInsets.all(2),
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(),
              );
            },
          ),
        ],
      ),
    );
  }
}
