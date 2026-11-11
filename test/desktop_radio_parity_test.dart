import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:al_minshawi_recitations/core/constants/app_constants.dart';
import 'package:al_minshawi_recitations/core/desktop/widgets/desktop_player_bar.dart';
import 'package:al_minshawi_recitations/core/desktop/widgets/desktop_sidebar.dart';
import 'package:al_minshawi_recitations/core/theme/theme_cubit.dart';
import 'package:al_minshawi_recitations/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:al_minshawi_recitations/features/favorites/presentation/cubit/favorites_state.dart';
import 'package:al_minshawi_recitations/features/player/presentation/cubit/audio_player_cubit.dart';
import 'package:al_minshawi_recitations/features/player/presentation/cubit/audio_player_state.dart';
import 'package:al_minshawi_recitations/features/player/presentation/cubit/sleep_timer_cubit.dart';
import 'package:al_minshawi_recitations/features/player/presentation/cubit/sleep_timer_state.dart';
import 'package:al_minshawi_recitations/features/player/presentation/pages/audio_player_screen.dart';
import 'package:al_minshawi_recitations/features/playlists/presentation/cubit/playlists_cubit.dart';
import 'package:al_minshawi_recitations/features/playlists/presentation/cubit/playlists_state.dart';
import 'package:al_minshawi_recitations/features/recitations/domain/entities/recitation.dart';
import 'package:al_minshawi_recitations/features/recitations/presentation/cubit/download_cubit.dart';
import 'package:al_minshawi_recitations/features/recitations/presentation/cubit/download_state.dart';
import 'package:al_minshawi_recitations/features/recitations/presentation/cubit/recitation_list_cubit.dart';
import 'package:al_minshawi_recitations/features/recitations/presentation/cubit/recitation_list_state.dart';

class _TrackingFakeAudioPlayerCubit extends Cubit<AudioPlayerState>
    implements AudioPlayerCubit {
  _TrackingFakeAudioPlayerCubit(
    super.initialState, {
    List<Recitation> initialPlaylist = const [],
  }) : _playlist = initialPlaylist;

  final List<Recitation> _playlist;

  int playCallCount = 0;
  Recitation? lastPlayedRecitation;
  int pauseCallCount = 0;
  int togglePlayPauseCallCount = 0;
  int toggleShuffleCallCount = 0;
  int toggleLoopCallCount = 0;
  int playNextCallCount = 0;
  int playPreviousCallCount = 0;
  int skipForwardCallCount = 0;
  int skipBackwardCallCount = 0;
  int seekToCallCount = 0;
  int setSpeedCallCount = 0;
  int cycleAbRepeatCallCount = 0;

  @override
  List<Recitation> get playlist => _playlist;

  @override
  Recitation? get currentRecitation => state.currentRecitation;

  @override
  bool get isShuffleEnabled =>
      state is AudioPlayerReady && (state as AudioPlayerReady).isShuffleEnabled;

  @override
  LoopMode get loopMode => state is AudioPlayerReady
      ? (state as AudioPlayerReady).loopMode
      : LoopMode.off;

  @override
  AbLoopState get abLoopState => state is AudioPlayerReady
      ? (state as AudioPlayerReady).abLoopState
      : AbLoopState.off;

  @override
  double get speed =>
      state is AudioPlayerReady ? (state as AudioPlayerReady).speed : 1.0;

  @override
  double get volume => 1.0;

  @override
  Future<void> play(
    Recitation recitation, {
    List<Recitation>? playlist,
    Duration? initialPosition,
  }) async {
    playCallCount++;
    lastPlayedRecitation = recitation;
  }

  @override
  Future<void> pause() async {
    pauseCallCount++;
  }

  @override
  Future<void> togglePlayPause() async {
    togglePlayPauseCallCount++;
  }

  @override
  void toggleShuffle() {
    toggleShuffleCallCount++;
  }

  @override
  void toggleLoopMode() {
    toggleLoopCallCount++;
  }

  @override
  Future<void> playNext() async {
    playNextCallCount++;
  }

  @override
  Future<void> playPrevious() async {
    playPreviousCallCount++;
  }

  @override
  Future<void> skipForward() async {
    skipForwardCallCount++;
  }

  @override
  Future<void> skipBackward() async {
    skipBackwardCallCount++;
  }

  @override
  Future<void> seekTo(Duration position) async {
    seekToCallCount++;
  }

  @override
  Future<void> setSpeed(double speed) async {
    setSpeedCallCount++;
  }

  @override
  Future<AbLoopState> cycleAbRepeat() async {
    cycleAbRepeatCallCount++;
    return AbLoopState.off;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeFavoritesCubit extends Cubit<FavoritesState>
    implements FavoritesCubit {
  _FakeFavoritesCubit() : super(const FavoritesInitial());
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSleepTimerCubit extends Cubit<SleepTimerState>
    implements SleepTimerCubit {
  _FakeSleepTimerCubit() : super(SleepTimerState.initial);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRecitationListCubit extends Cubit<RecitationListState>
    implements RecitationListCubit {
  _FakeRecitationListCubit() : super(const RecitationListInitial());
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

class _FakeThemeCubit extends Cubit<ThemeMode> implements ThemeCubit {
  _FakeThemeCubit([super.mode = ThemeMode.dark]);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _wrapWithProviders({
  required AudioPlayerCubit audioPlayerCubit,
  required Widget child,
  ThemeMode themeMode = ThemeMode.dark,
}) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<AudioPlayerCubit>.value(value: audioPlayerCubit),
      BlocProvider<FavoritesCubit>.value(value: _FakeFavoritesCubit()),
      BlocProvider<SleepTimerCubit>.value(value: _FakeSleepTimerCubit()),
      BlocProvider<RecitationListCubit>.value(
        value: _FakeRecitationListCubit(),
      ),
      BlocProvider<DownloadCubit>.value(value: _FakeDownloadCubit()),
      BlocProvider<PlaylistsCubit>.value(value: _FakePlaylistsCubit()),
      BlocProvider<ThemeCubit>.value(value: _FakeThemeCubit(themeMode)),
    ],
    child: child,
  );
}

void main() {
  testWidgets('DesktopSidebar shows Clean Live Radio branding and toggles playback',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final idleAudio = _TrackingFakeAudioPlayerCubit(const AudioPlayerIdle());

    await tester.pumpWidget(
      _wrapWithProviders(
        audioPlayerCubit: idleAudio,
        child: MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: Row(
                children: [
                  DesktopSidebar(
                    currentPath: '/',
                    isCollapsed: false,
                    onToggleCollapse: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('إذاعة القرآن الكريم'), findsOneWidget);
    expect(find.textContaining('سورة إذاعة'), findsNothing);
    expect(find.text('مباشر'), findsOneWidget);

    await tester.tap(find.text('إذاعة القرآن الكريم'));
    await tester.pump();
    expect(idleAudio.playCallCount, 1);
    expect(idleAudio.lastPlayedRecitation?.id, AppConstants.minshawiRadio.id);

    // Now test playing radio state shows 'يعمل' and taps pause()
    final playingRadio = _TrackingFakeAudioPlayerCubit(
      AudioPlayerReady(
        recitation: AppConstants.minshawiRadio,
        position: const Duration(seconds: 25),
        duration: Duration.zero,
        isPlaying: true,
      ),
    );

    await tester.pumpWidget(
      _wrapWithProviders(
        audioPlayerCubit: playingRadio,
        child: MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: Row(
                children: [
                  DesktopSidebar(
                    currentPath: '/',
                    isCollapsed: false,
                    onToggleCollapse: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('يعمل'), findsOneWidget);
    await tester.tap(find.text('إذاعة القرآن الكريم'));
    await tester.pump();
    expect(playingRadio.pauseCallCount, 1);
  });

  testWidgets(
      'DesktopPlayerBar enforces radio parity: clean branding, disabled controls, no favorite/download, flat live slider',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final cubit = _TrackingFakeAudioPlayerCubit(
      AudioPlayerReady(
        recitation: AppConstants.minshawiRadio,
        position: const Duration(seconds: 45),
        duration: Duration.zero,
        isPlaying: true,
        speed: 1.5,
        loopMode: LoopMode.all,
        isShuffleEnabled: true,
      ),
    );

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              bottomNavigationBar: DesktopPlayerBar(),
              body: SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      _wrapWithProviders(
        audioPlayerCubit: cubit,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();

    expect(find.text('إذاعة القرآن الكريم'), findsOneWidget);
    expect(find.textContaining('سورة إذاعة'), findsNothing);
    expect(find.text('بث مباشر'), findsOneWidget);
    // Speed locked at 1.0x during live radio
    expect(find.text('1.0x'), findsOneWidget);
    expect(find.text('1.5x'), findsNothing);

    // Download and favorite buttons hidden in live radio mode
    expect(find.byIcon(Icons.download_rounded), findsNothing);
    expect(find.byIcon(Icons.download_done_rounded), findsNothing);
    expect(find.byIcon(Icons.favorite_rounded), findsNothing);
    expect(find.byIcon(Icons.favorite_outline_rounded), findsNothing);

    // Seek slider disabled & zero-radius thumb in live radio mode
    final seekSlider = tester.widgetList<Slider>(find.byType(Slider)).first;
    expect(seekSlider.onChanged, isNull);
    expect(seekSlider.onChangeEnd, isNull);

    // Tap disabled transport/track buttons and ensure callbacks never fire
    for (final icon in [
      Icons.shuffle_rounded,
      Icons.skip_previous_rounded,
      Icons.replay_10_rounded,
      Icons.forward_10_rounded,
      Icons.skip_next_rounded,
      Icons.repeat_rounded,
      Icons.repeat_on_rounded,
    ]) {
      await tester.tap(find.byIcon(icon));
      await tester.pump();
    }

    expect(cubit.toggleShuffleCallCount, 0);
    expect(cubit.playPreviousCallCount, 0);
    expect(cubit.skipBackwardCallCount, 0);
    expect(cubit.skipForwardCallCount, 0);
    expect(cubit.playNextCallCount, 0);
    expect(cubit.toggleLoopCallCount, 0);
    expect(cubit.cycleAbRepeatCallCount, 0);
  });

  testWidgets(
      'AudioPlayerScreen split-view desktop layout handles live radio cleanly',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final cubit = _TrackingFakeAudioPlayerCubit(
      AudioPlayerReady(
        recitation: AppConstants.minshawiRadio,
        position: const Duration(seconds: 12),
        duration: Duration.zero,
        isPlaying: true,
        speed: 1.25,
        loopMode: LoopMode.one,
        isShuffleEnabled: true,
      ),
      initialPlaylist: const [],
    );

    await tester.pumpWidget(
      _wrapWithProviders(
        audioPlayerCubit: cubit,
        child: const MaterialApp(
          home: AudioPlayerScreen(),
        ),
      ),
    );
    await tester.pump();

    // Clean live radio branding & status
    expect(find.text('إذاعة القرآن الكريم'), findsOneWidget);
    expect(find.textContaining('سورة إذاعة'), findsNothing);
    expect(find.text('بث مباشر'), findsOneWidget);
    expect(find.text('1.0x'), findsOneWidget);

    // Favorite, playlist-add, and download actions hidden for live radio
    expect(find.byIcon(Icons.playlist_add_rounded), findsNothing);
    expect(find.byIcon(Icons.favorite_rounded), findsNothing);
    expect(find.byIcon(Icons.favorite_border_rounded), findsNothing);
    expect(find.byIcon(Icons.file_download_outlined), findsNothing);

    // Empty playlist panel renders dedicated live radio listening state & omits '(0)'
    expect(
      find.text('يتم الآن الاستماع إلى البث المباشر لإذاعة القرآن الكريم'),
      findsOneWidget,
    );
    expect(find.text('قائمة السور والتلاوات'), findsOneWidget);
    expect(find.text('قائمة السور والتلاوات (0)'), findsNothing);

    // Disabled controls do not trigger cubit actions
    for (final icon in [
      Icons.skip_previous_rounded,
      Icons.replay_10_rounded,
      Icons.forward_10_rounded,
      Icons.skip_next_rounded,
      Icons.shuffle_rounded,
      Icons.repeat_rounded,
    ]) {
      await tester.tap(find.byIcon(icon));
      await tester.pump();
    }
    await tester.tap(find.text('A-B'));
    await tester.pump();

    expect(cubit.playPreviousCallCount, 0);
    expect(cubit.skipBackwardCallCount, 0);
    expect(cubit.skipForwardCallCount, 0);
    expect(cubit.playNextCallCount, 0);
    expect(cubit.toggleShuffleCallCount, 0);
    expect(cubit.toggleLoopCallCount, 0);
    expect(cubit.cycleAbRepeatCallCount, 0);

    // Seek bar disabled & thumb radius 0
    final seekSlider = tester.widgetList<Slider>(find.byType(Slider)).first;
    expect(seekSlider.onChanged, isNull);
    expect(seekSlider.onChangeEnd, isNull);
  });
}
