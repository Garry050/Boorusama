// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../core/boorus/booru/booru.dart';
import '../../../../core/configs/config.dart';
import '../../../../core/tags/tag/tag.dart';
import '../autocomplete/moebooru_autocomplete_provider.dart';
import 'moebooru_tag_repository.dart';

final moebooruTagRepoProvider =
    Provider.family<MoebooruTagRepository, BooruConfigAuth>((ref, config) {
  return MoebooruTagRepository(
    repo: ref.watch(moebooruTagSummaryRepoProvider(config)),
  );
});

final moebooruAllTagsProvider =
    FutureProvider.family<Map<String, Tag>, BooruConfigAuth>(
        (ref, config) async {
  if (config.booruType != BooruType.moebooru) return {};

  final repo = ref.watch(moebooruTagSummaryRepoProvider(config));
  final data = await repo.getTagSummaries();

  final tags = data
      .map(tagSummaryToTag)
      .sorted((a, b) => a.rawName.compareTo(b.rawName));

  return {
    for (final tag in tags) tag.rawName: tag,
  };
});
