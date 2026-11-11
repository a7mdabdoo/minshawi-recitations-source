import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:al_minshawi_recitations/core/constants/app_constants.dart';
import 'package:al_minshawi_recitations/features/recitations/data/models/nahawand_recitation_model.dart';
import 'package:al_minshawi_recitations/features/recitations/data/models/recitation_model.dart';
import 'package:al_minshawi_recitations/features/recitations/domain/entities/recitation.dart';
import 'package:al_minshawi_recitations/features/recitations/presentation/cubit/recitation_list_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Recitation Title and Location separation tests', () {
    test('Separates concert title with dash into pure Surah name and location', () {
      const recitation = Recitation(
        id: '1',
        surahNumber: 19,
        surahNameAr: 'مريم - المسجد الأقصى 1964',
        surahNameEn: 'Maryam',
        verseRange: '',
        durationSeconds: 2400,
        fileSizeBytes: 1000,
        audioUrl: 'http://example.com/audio.mp3',
        recordingYear: '1964',
        recordingLocation: 'المسجد الأقصى (1964)',
        isRare: true,
        quality: 'High',
      );

      expect(recitation.cleanSurahTitleWithVerses, 'سورة مريم');
      expect(recitation.cleanLocationOrDetail, 'المسجد الأقصى 1964');
    });

    test('Omits numeric verse range for non-Mahafil sections (Murattal, Mujawwad, Rare)', () {
      const murattal = Recitation(
        id: 'murattal_001',
        surahNumber: 1,
        surahNameAr: 'الفاتحة',
        surahNameEn: 'Al-Fatihah',
        verseRange: '1-7',
        durationSeconds: 50,
        fileSizeBytes: 1000,
        audioUrl: 'http://example.com/audio.mp3',
        recordingYear: '',
        recordingLocation: '',
        collectionId: 'complete_murattal',
        isRare: false,
        quality: 'High',
      );

      const mojawad = Recitation(
        id: 'mojawad_002',
        surahNumber: 2,
        surahNameAr: 'البقرة',
        surahNameEn: 'Al-Baqarah',
        verseRange: '1-286',
        durationSeconds: 3600,
        fileSizeBytes: 1000,
        audioUrl: 'http://example.com/audio.mp3',
        recordingYear: '',
        recordingLocation: '',
        collectionId: 'mojawad',
        isRare: false,
        quality: 'High',
      );

      const rare = Recitation(
        id: 'rare_1387_003',
        surahNumber: 3,
        surahNameAr: 'آل عمران',
        surahNameEn: 'Aal-E-Imran',
        verseRange: '1-200',
        durationSeconds: 2400,
        fileSizeBytes: 1000,
        audioUrl: 'http://example.com/audio.mp3',
        recordingYear: '1387',
        recordingLocation: 'تسجيل إذاعي',
        collectionId: 'rare_1387',
        isRare: true,
        quality: 'High',
      );

      expect(murattal.cleanSurahTitleWithVerses, 'سورة الفاتحة');
      expect(murattal.cleanLocationOrDetail, 'Al-Fatihah');
      expect(mojawad.cleanSurahTitleWithVerses, 'سورة البقرة');
      expect(rare.cleanSurahTitleWithVerses, 'سورة آل عمران');
    });

    test('Retains numeric verse range ONLY for Mahafil (Nahawand) section', () {
      const mahfil = Recitation(
        id: 'nahawand_10',
        surahNumber: 59,
        surahNameAr: 'الحشر - دمشق',
        surahNameEn: 'Al-Hashr',
        verseRange: '18-24',
        durationSeconds: 1800,
        fileSizeBytes: 1000,
        audioUrl: 'http://example.com/audio.mp3',
        recordingYear: '1960',
        recordingLocation: 'دمشق',
        collectionId: 'nahawand',
        isRare: true,
        quality: 'High',
      );

      expect(mahfil.cleanSurahTitleWithVerses, 'سورة الحشر (الآيات: 18-24)');
      expect(mahfil.cleanLocationOrDetail, 'دمشق');
    });

    test('Never prepends Surah prefix to Live Quran Radio', () {
      expect(
        AppConstants.minshawiRadio.cleanSurahTitleWithVerses,
        'إذاعة القرآن الكريم',
      );

      const prefixedRadio = Recitation(
        id: 'radio_custom',
        surahNumber: 0,
        surahNameAr: 'سورة إذاعة القرآن الكريم',
        surahNameEn: 'Live Radio',
        verseRange: '',
        durationSeconds: 0,
        fileSizeBytes: 0,
        audioUrl: 'http://example.com/radio',
        recordingYear: 'بث مباشر',
        recordingLocation: 'بث مباشر',
        collectionId: 'radio',
        isRare: false,
        quality: 'Live',
      );

      expect(prefixedRadio.cleanSurahTitleWithVerses, 'إذاعة القرآن الكريم');
    });

    test('Handles combined Surahs title correctly', () {
      const recitation = Recitation(
        id: '3',
        surahNumber: 59,
        surahNameAr: 'الحشر والطارق والفجر والعلق - ستينات الإسكندرية',
        surahNameEn: 'Al-Hashr & others',
        verseRange: '',
        durationSeconds: 1800,
        fileSizeBytes: 1000,
        audioUrl: 'http://example.com/audio.mp3',
        recordingYear: '1960',
        recordingLocation: 'ستينات الإسكندرية',
        isRare: true,
        quality: 'High',
      );

      expect(recitation.cleanSurahTitleWithVerses, 'سورة الحشر والطارق والفجر والعلق');
      expect(recitation.cleanLocationOrDetail, 'ستينات الإسكندرية');
    });

    test('Manifest non-Mahafil collections suppress ayah counts across all 254 items', () async {
      final rawJson =
          await rootBundle.loadString('assets/data/recitations_manifest.json');
      final decoded = json.decode(rawJson) as Map<String, dynamic>;
      final collections = decoded['collections'] as List<dynamic>;

      int checkedCount = 0;
      for (final col in collections) {
        final colMap = col as Map<String, dynamic>;
        final items = colMap['recitations'] as List<dynamic>;
        for (final item in items) {
          final model =
              RecitationModel.fromJson(item as Map<String, dynamic>);
          checkedCount++;

          expect(model.isMahfel, isFalse, reason: 'Item ${model.id}');
          expect(model.isRadio, isFalse, reason: 'Item ${model.id}');
          expect(
            model.cleanSurahTitleWithVerses,
            isNot(contains('(')),
            reason: 'Title for ${model.id} must not include verse parentheses',
          );
          expect(
            model.cleanSurahTitleWithVerses,
            isNot(contains('الآيات')),
            reason: 'Title for ${model.id} must not include الآيات',
          );
          expect(
            model.trailingVerseOrLocation,
            isNot(contains('الآيات')),
            reason: 'Trailing label for ${model.id} must not include الآيات',
          );
          if (model.verseRange.trim().isNotEmpty) {
            expect(
              model.cleanSurahTitleWithVerses,
              isNot(contains(model.verseRange.trim())),
            );
            expect(
              model.trailingVerseOrLocation,
              isNot(contains(model.verseRange.trim())),
            );
          }
        }
      }

      expect(checkedCount, 254);
    });

    test('Nahawand candidates stay classified as Mahafil and never as Radio', () async {
      final rawJson =
          await rootBundle.loadString('assets/data/nahawand_candidates.json');
      final items = json.decode(rawJson) as List<dynamic>;
      expect(items.length, equals(1019));

      int verseRangeItems = 0;
      int goldenItems = 0;
      final seenUrls = <String>{};
      for (final item in items) {
        final model =
            NahawandRecitationModel.fromJson(item as Map<String, dynamic>);
        expect(model.isMahfel, isTrue, reason: 'Item ${model.id}');
        expect(model.isRadio, isFalse, reason: 'Item ${model.id}');
        expect(model.audioUrl, startsWith('https://'), reason: 'HTTPS ${model.id}');
        expect(seenUrls.add(model.audioUrl), isTrue, reason: 'Unique URL ${model.id}');
        expect(model.category, isNotEmpty, reason: 'Category ${model.id}');
        expect(model.placeGroup, isNotEmpty, reason: 'Place group ${model.id}');
        expect(model.durationSeconds, greaterThan(0), reason: 'Duration ${model.id}');
        expect(model.fileSizeBytes, greaterThan(0), reason: 'File size ${model.id}');
        if (model.isGoldenSelection) goldenItems++;

        if (model.hasNumericVerseRange) {
          verseRangeItems++;
          expect(
            model.cleanSurahTitleWithVerses,
            contains(model.verseRange.trim()),
            reason: 'Mahfil ${model.id} should retain verse range in title',
          );
          expect(
            model.trailingVerseOrLocation,
            contains('الآيات: ${model.verseRange.trim()}'),
            reason: 'Mahfil ${model.id} should retain verse range in trailing',
          );
        }
      }

      expect(verseRangeItems, greaterThan(0));
      expect(goldenItems, equals(67));
    });

    test('Formats collection labels and قصار السور titles cleanly', () {
      const radioEdition = Recitation(
        id: 'rare_1387_001',
        surahNumber: 1,
        surahNameAr: 'الفاتحة',
        surahNameEn: 'Al-Fatihah',
        verseRange: '1-7',
        durationSeconds: 51,
        fileSizeBytes: 1232162,
        audioUrl: 'https://example.com/1.mp3',
        recordingYear: '1387',
        recordingLocation: 'تسجيل إذاعي',
        collectionId: 'rare_1387',
        isRare: true,
        quality: 'High',
      );
      const qisar = Recitation(
        id: 'nahawand_1149',
        surahNumber: 89,
        surahNameAr: 'قصار السور - المسجد الأموي - دمشق (1952)',
        surahNameEn: 'Qisar',
        verseRange: '',
        durationSeconds: 1660,
        fileSizeBytes: 6794389,
        audioUrl: 'https://example.com/qisar.mp3',
        recordingYear: '1952',
        recordingLocation: 'المسجد الأموي - دمشق (1952)',
        collectionId: 'nahawand',
        isRare: true,
        quality: 'High',
      );

      expect(radioEdition.sourceLabel, AppConstants.rare1387Title);
      expect(qisar.sourceLabel, AppConstants.mahafilTitle);
      expect(qisar.cleanSurahTitleWithVerses, 'قصار السور');
      expect(
        NahawandRecitationModel.resolveSurahNumber('طه', 'مريم وطه'),
        equals(20),
      );
    });

    test('Search ignores hidden verseRange on non-Mahafil items but matches Mahafil', () {
      const mojawad = Recitation(
        id: 'mojawad_002',
        surahNumber: 2,
        surahNameAr: 'البقرة',
        surahNameEn: 'Al-Baqarah',
        verseRange: '1-286',
        durationSeconds: 3600,
        fileSizeBytes: 1000,
        audioUrl: 'https://example.com/2.mp3',
        recordingYear: '',
        recordingLocation: '',
        collectionId: 'mojawad',
        isRare: false,
        quality: 'High',
      );
      const mahfil = Recitation(
        id: 'nahawand_286',
        surahNumber: 2,
        surahNameAr: 'البقرة - محفل الإسكندرية',
        surahNameEn: 'Al-Baqarah',
        verseRange: '284-286',
        durationSeconds: 1800,
        fileSizeBytes: 1000,
        audioUrl: 'https://example.com/mahfil.mp3',
        recordingYear: '1962',
        recordingLocation: 'الإسكندرية',
        collectionId: 'nahawand',
        isRare: true,
        quality: 'High',
      );

      const loaded = RecitationListLoaded(
        recitations: [mojawad, mahfil],
        searchQuery: '286',
      );

      expect(loaded.filtered, equals([mahfil]));
    });
  });
}
