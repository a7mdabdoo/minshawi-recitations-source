import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:al_minshawi_recitations/core/constants/app_constants.dart';
import 'package:al_minshawi_recitations/core/settings/settings_cubit.dart';
import 'package:al_minshawi_recitations/core/theme/theme_cubit.dart';
import 'package:al_minshawi_recitations/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:al_minshawi_recitations/features/favorites/presentation/cubit/favorites_state.dart';
import 'package:al_minshawi_recitations/features/player/presentation/cubit/audio_player_cubit.dart';
import 'package:al_minshawi_recitations/features/player/presentation/cubit/audio_player_state.dart';
import 'package:al_minshawi_recitations/features/playlists/presentation/cubit/playlists_cubit.dart';
import 'package:al_minshawi_recitations/features/playlists/presentation/cubit/playlists_state.dart';
import 'package:al_minshawi_recitations/features/recitations/data/models/nahawand_recitation_model.dart';
import 'package:al_minshawi_recitations/features/recitations/domain/entities/recitation.dart';
import 'package:al_minshawi_recitations/features/recitations/presentation/cubit/download_cubit.dart';
import 'package:al_minshawi_recitations/features/recitations/presentation/cubit/download_state.dart';
import 'package:al_minshawi_recitations/features/recitations/presentation/cubit/recitation_list_cubit.dart';
import 'package:al_minshawi_recitations/features/recitations/presentation/cubit/recitation_list_state.dart';
import 'package:al_minshawi_recitations/features/recitations/presentation/pages/home_page.dart';

class _FakeRecitationListCubit extends Cubit<RecitationListState>
    implements RecitationListCubit {
  _FakeRecitationListCubit(List<Recitation> items)
      : _all = items,
        super(RecitationListLoaded(recitations: items));

  final List<Recitation> _all;

  @override
  Future<void> loadRecitations({String? collectionId}) async {}

  @override
  void search(String query) {
    emit(RecitationListLoaded(recitations: _all, searchQuery: query));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAudioPlayerCubit extends Cubit<AudioPlayerState>
    implements AudioPlayerCubit {
  _FakeAudioPlayerCubit() : super(const AudioPlayerIdle());

  @override
  void updatePlaylist(List<Recitation> recitations) {}

  @override
  Future<void> saveCurrentPosition() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeFavoritesCubit extends Cubit<FavoritesState>
    implements FavoritesCubit {
  _FakeFavoritesCubit() : super(const FavoritesLoaded({}));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDownloadCubit extends Cubit<DownloadState> implements DownloadCubit {
  _FakeDownloadCubit() : super(const DownloadState());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePlaylistsCubit extends Cubit<PlaylistsState>
    implements PlaylistsCubit {
  _FakePlaylistsCubit() : super(const PlaylistsLoaded(playlists: []));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSettingsCubit extends SettingsCubit {
  _FakeSettingsCubit() : super(null);
}

class _FakeThemeCubit extends Cubit<ThemeMode> implements ThemeCubit {
  _FakeThemeCubit() : super(ThemeMode.dark);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final sampleMahafil = [
    NahawandRecitationModel.fromJson({
      'id': 10,
      'title': 'يوسف - المسجد الأقصى 1964',
      'surah': 'يوسف',
      'place_or_year': 'المسجد الأقصى (1964)',
      'place_group': 'المسجد الأقصى',
      'duration': '32:10',
      'file_size_bytes': 8000000,
      'audio_url': 'https://example.com/10.mp3',
      'category': 'يوسف',
      'is_iconic_concert': true,
      'is_golden_selection': true,
    }),
    NahawandRecitationModel.fromJson({
      'id': 20,
      'title': 'مريم - دمشق 1956',
      'surah': 'مريم',
      'place_or_year': 'المسجد الأموي - دمشق (1956)',
      'place_group': 'سوريا ودمشق',
      'duration': '40:00',
      'file_size_bytes': 9500000,
      'audio_url': 'https://example.com/20.mp3',
      'category': 'مريم وطه',
      'is_iconic_concert': true,
      'is_golden_selection': false,
    }),
    NahawandRecitationModel.fromJson({
      'id': 30,
      'title': 'طه - المسجد الأقصى 1964',
      'surah': 'طه',
      'place_or_year': 'المسجد الأقصى (1964)',
      'place_group': 'المسجد الأقصى',
      'duration': '25:00',
      'file_size_bytes': 6000000,
      'audio_url': 'https://example.com/30.mp3',
      'category': 'مريم وطه',
      'is_iconic_concert': false,
      'is_golden_selection': false,
    }),
  ];

  Widget buildSubject() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RecitationListCubit>.value(
          value: _FakeRecitationListCubit(sampleMahafil),
        ),
        BlocProvider<AudioPlayerCubit>.value(value: _FakeAudioPlayerCubit()),
        BlocProvider<FavoritesCubit>.value(value: _FakeFavoritesCubit()),
        BlocProvider<DownloadCubit>.value(value: _FakeDownloadCubit()),
        BlocProvider<PlaylistsCubit>.value(value: _FakePlaylistsCubit()),
        BlocProvider<SettingsCubit>.value(value: _FakeSettingsCubit()),
        BlocProvider<ThemeCubit>.value(value: _FakeThemeCubit()),
      ],
      child: const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: HomePage(collectionId: 'nahawand'),
        ),
      ),
    );
  }

  testWidgets('Mahafil defaults to Golden tab and opens filter modal on tap',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text(AppConstants.mahafilTitle), findsOneWidget);
    // Default screen hides filter options until the filter button is pressed
    expect(find.byKey(const ValueKey('mahafil_filter_button')), findsOneWidget);
    expect(find.text('مريم وطه'), findsNothing);
    // Only the golden selection (1 item) is displayed under default tab
    expect(find.textContaining('يوسف'), findsOneWidget);
    expect(find.textContaining('دمشق'), findsNothing);

    // Open filter dialog by tapping filter button
    await tester.tap(find.byKey(const ValueKey('mahafil_filter_button')));
    await tester.pumpAndSettle();

    expect(find.text('تصفية المحافل'), findsOneWidget);
    await tester.tap(find.text('مريم وطه'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('عرض النتائج (0 تلاوة)'));
    await tester.pumpAndSettle();

    expect(find.text('النتائج: 0 تلاوة'), findsOneWidget);
    expect(find.textContaining('عرض في كل المحافل'), findsOneWidget);

    await tester.tap(find.textContaining('عرض في كل المحافل'));
    await tester.pumpAndSettle();

    // Now shows both items under 'مريم وطه' across Syria & Al-Aqsa
    expect(find.text('النتائج: 2 تلاوة'), findsOneWidget);

    // Narrow down further via filter modal -> Place 'المسجد الأقصى'
    await tester.tap(find.byKey(const ValueKey('mahafil_filter_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('المسجد الأقصى'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('عرض النتائج (1 تلاوة)'));
    await tester.pumpAndSettle();

    expect(find.text('النتائج: 1 تلاوة'), findsOneWidget);

    // Reset filters hides filter strip and shows all 3 items under 'كل المحافل'
    await tester.tap(find.text('إعادة ضبط الفلاتر').first);
    await tester.pumpAndSettle();

    expect(find.text('النتائج: 3 تلاوة'), findsNothing);
    expect(find.textContaining('مريم'), findsOneWidget);
    expect(find.textContaining('طه'), findsOneWidget);
  });
}
