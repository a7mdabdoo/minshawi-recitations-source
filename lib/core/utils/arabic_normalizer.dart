class ArabicNormalizer {
  ArabicNormalizer._();

  static final RegExp _tashkeelAndTatweelRegex =
      RegExp(r'[\u064B-\u065F\u0670\u0640\u06D6-\u06ED]');
  static final RegExp _alefVariantsRegex = RegExp(r'[أإآٱ]');
  static final RegExp _alefMaksuraRegex = RegExp(r'[ى]');
  static final RegExp _taaMarbutaRegex = RegExp(r'[ة]');

  static final RegExp _arabicDigitsRegex = RegExp(r'[٠-٩]');
  static final RegExp _whitespaceRegex = RegExp(r'\s+');
  static final Expando<String> _searchCorpusCache =
      Expando<String>('recitationSearchCorpus');

  static String normalize(String text) {
    if (text.isEmpty) return '';

    var normalized = text;

    normalized = normalized.replaceAll(_tashkeelAndTatweelRegex, '');
    normalized = normalized.replaceAll(_alefVariantsRegex, 'ا');
    normalized = normalized.replaceAll(_taaMarbutaRegex, 'ه');
    normalized = normalized.replaceAll(_alefMaksuraRegex, 'ي');
    normalized = normalized.replaceAllMapped(
      _arabicDigitsRegex,
      (m) => String.fromCharCode(m.group(0)!.codeUnitAt(0) - 0x0660 + 48),
    );

    return normalized.trim().toLowerCase();
  }

  static bool matches(String source, String query) {
    if (query.trim().isEmpty) return true;
    if (source.isEmpty) return false;

    final normSource = normalize(source);
    final normQuery = normalize(query);

    if (normSource.contains(normQuery)) {
      return true;
    }

    if (normQuery.startsWith('ال') && normQuery.length > 2) {
      final strippedQuery = normQuery.substring(2);
      if (normSource.contains(strippedQuery)) {
        return true;
      }
    }

    if (normSource.startsWith('ال') && normSource.length > 2) {
      final strippedSource = normSource.substring(2);
      if (strippedSource.contains(normQuery)) {
        return true;
      }
    }

    return false;
  }

  /// Normalizes and splits [query] into search tokens once before filtering.
  static List<String> tokenizeQuery(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];
    return trimmed
        .split(_whitespaceRegex)
        .map(normalize)
        .where((w) => w.isNotEmpty)
        .toList();
  }

  /// Checks whether all [tokens] match the normalized corpus built for [cacheKey].
  static bool matchesPreparedCached({
    required List<String> tokens,
    required Object cacheKey,
    required Iterable<String> Function() sourcesBuilder,
  }) {
    if (tokens.isEmpty) return true;

    var combinedNormSource = _searchCorpusCache[cacheKey];
    if (combinedNormSource == null) {
      combinedNormSource =
          sourcesBuilder().map(normalize).where((s) => s.isNotEmpty).join(' ');
      _searchCorpusCache[cacheKey] = combinedNormSource;
    }

    return _matchTokensAgainstCorpus(
      combinedNormSource: combinedNormSource,
      tokens: tokens,
    );
  }

  /// Checks if all keywords in [query] match across the provided [sources].
  /// Every significant word/token in the query must be found in the normalized searchable text.
  static bool matchesMultiToken({
    required String query,
    required Iterable<String> sources,
  }) {
    final tokens = tokenizeQuery(query);
    if (tokens.isEmpty) return true;

    final combinedNormSource =
        sources.map(normalize).where((s) => s.isNotEmpty).join(' ');
    return _matchTokensAgainstCorpus(
      combinedNormSource: combinedNormSource,
      tokens: tokens,
    );
  }

  static bool _matchTokensAgainstCorpus({
    required String combinedNormSource,
    required List<String> tokens,
  }) {
    if (combinedNormSource.isEmpty) return false;

    var nonSurahTokenCount = 0;
    for (final token in tokens) {
      if (token == 'سوره' || token == 'سورة') {
        continue;
      }
      nonSurahTokenCount++;

      var matched = combinedNormSource.contains(token);

      // Check stripping "ال"
      if (!matched && token.startsWith('ال') && token.length > 2) {
        matched = combinedNormSource.contains(token.substring(2));
      }

      // Check adding "ال"
      if (!matched && !token.startsWith('ال')) {
        matched = combinedNormSource.contains('ال$token');
      }

      if (!matched) {
        return false;
      }
    }

    // If query only consisted of "سورة", match if the combined text has "سورة" or surah references
    if (nonSurahTokenCount == 0) {
      return combinedNormSource.contains('سوره') ||
          combinedNormSource.contains('سورة');
    }

    return true;
  }
}
