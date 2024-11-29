// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/foundation/gestures.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/functional.dart';

class BooruConfig extends Equatable with BooruConfigAuthMixin {
  const BooruConfig({
    required this.id,
    required this.booruId,
    required this.booruIdHint,
    required this.apiKey,
    required this.login,
    required this.passHash,
    required this.name,
    required this.ratingFilter,
    required this.deletedItemBehavior,
    required this.bannedPostVisibility,
    required this.url,
    required this.customDownloadFileNameFormat,
    required this.customBulkDownloadFileNameFormat,
    required this.customDownloadLocation,
    required this.imageDetaisQuality,
    required this.granularRatingFilters,
    required this.postGestures,
    required this.defaultPreviewImageButtonAction,
    required this.listing,
    required this.alwaysIncludeTags,
  });

  factory BooruConfig.fromJson(Map<String, dynamic> json) {
    final ratingFilter = json['ratingFilter'] as int?;
    final bannedPostVisibility = json['bannedPostVisibility'] as int?;

    return BooruConfig(
      id: json['id'] as int,
      booruId: json['booruId'] as int,
      booruIdHint: json['booruIdHint'] as int,
      apiKey: json['apiKey'] as String?,
      login: json['login'] as String?,
      passHash: json['passHash'] as String?,
      url: json['url'] as String,
      name: json['name'] as String,
      deletedItemBehavior: BooruConfigDeletedItemBehavior
          .values[json['deletedItemBehavior'] as int],
      ratingFilter: ratingFilter != null
          ? BooruConfigRatingFilter.values.getOrNull(ratingFilter) ??
              BooruConfigRatingFilter.hideNSFW
          : BooruConfigRatingFilter.hideNSFW,
      bannedPostVisibility: bannedPostVisibility != null
          ? BooruConfigBannedPostVisibility.values
                  .getOrNull(bannedPostVisibility) ??
              BooruConfigBannedPostVisibility.show
          : BooruConfigBannedPostVisibility.show,
      customDownloadFileNameFormat:
          json['customDownloadFileNameFormat'] as String?,
      customBulkDownloadFileNameFormat:
          json['customBulkDownloadFileNameFormat'] as String?,
      customDownloadLocation: json['customDownloadLocation'] as String?,
      imageDetaisQuality: json['imageDetaisQuality'] as String?,
      granularRatingFilters: parseGranularRatingFilters(
        json['granularRatingFilterString'] as String?,
      ),
      postGestures: json['postGestures'] == null
          ? null
          : PostGestureConfig.fromJson(
              json['postGestures'] as Map<String, dynamic>),
      defaultPreviewImageButtonAction:
          json['defaultPreviewImageButtonAction'] as String?,
      listing: json['listing'] == null
          ? null
          : ListingConfigs.fromJson(json['listing'] as Map<String, dynamic>),
      alwaysIncludeTags: json['alwaysIncludeTags'] as String?,
    );
  }

  static const BooruConfig empty = BooruConfig(
    id: -2,
    booruId: -1,
    booruIdHint: -1,
    apiKey: null,
    login: null,
    passHash: null,
    name: '',
    deletedItemBehavior: BooruConfigDeletedItemBehavior.show,
    ratingFilter: BooruConfigRatingFilter.none,
    bannedPostVisibility: BooruConfigBannedPostVisibility.show,
    url: '',
    customDownloadFileNameFormat: null,
    customBulkDownloadFileNameFormat: null,
    customDownloadLocation: null,
    imageDetaisQuality: null,
    granularRatingFilters: null,
    postGestures: null,
    defaultPreviewImageButtonAction: null,
    listing: null,
    alwaysIncludeTags: null,
  );

  static BooruConfig defaultConfig({
    required BooruType booruType,
    required String url,
    required String? customDownloadFileNameFormat,
  }) =>
      BooruConfig(
        id: -1,
        booruId: booruType.toBooruId(),
        booruIdHint: booruType.toBooruId(),
        apiKey: null,
        login: null,
        passHash: null,
        name: 'new profile',
        deletedItemBehavior: BooruConfigDeletedItemBehavior.show,
        ratingFilter: BooruConfigRatingFilter.none,
        bannedPostVisibility: BooruConfigBannedPostVisibility.show,
        url: url,
        customDownloadFileNameFormat: customDownloadFileNameFormat,
        customBulkDownloadFileNameFormat: customDownloadFileNameFormat,
        customDownloadLocation: null,
        imageDetaisQuality: null,
        granularRatingFilters: null,
        postGestures: null,
        defaultPreviewImageButtonAction: null,
        listing: null,
        alwaysIncludeTags: null,
      );

  final int id;
  @override
  final int booruId;
  @override
  final int booruIdHint;
  final String url;
  @override
  final String? apiKey;
  @override
  final String? login;
  final String? passHash;
  final String name;
  final BooruConfigDeletedItemBehavior deletedItemBehavior;
  final BooruConfigRatingFilter ratingFilter;
  final BooruConfigBannedPostVisibility bannedPostVisibility;
  final String? customDownloadFileNameFormat;
  final String? customBulkDownloadFileNameFormat;
  final String? customDownloadLocation;
  final String? imageDetaisQuality;
  final Set<Rating>? granularRatingFilters;
  final PostGestureConfig? postGestures;
  final String? defaultPreviewImageButtonAction;
  final ListingConfigs? listing;
  final String? alwaysIncludeTags;

  BooruConfig copyWith({
    String? url,
    String? apiKey,
    String? login,
    String? name,
  }) {
    return BooruConfig(
      id: id,
      booruId: booruId,
      booruIdHint: booruIdHint,
      url: url ?? this.url,
      apiKey: apiKey ?? this.apiKey,
      login: login ?? this.login,
      name: name ?? this.name,
      passHash: passHash,
      deletedItemBehavior: deletedItemBehavior,
      ratingFilter: ratingFilter,
      bannedPostVisibility: bannedPostVisibility,
      customDownloadFileNameFormat: customDownloadFileNameFormat,
      customBulkDownloadFileNameFormat: customBulkDownloadFileNameFormat,
      customDownloadLocation: customDownloadLocation,
      imageDetaisQuality: imageDetaisQuality,
      granularRatingFilters: granularRatingFilters,
      postGestures: postGestures,
      defaultPreviewImageButtonAction: defaultPreviewImageButtonAction,
      listing: listing,
      alwaysIncludeTags: alwaysIncludeTags,
    );
  }

  @override
  List<Object?> get props => [
        id,
        booruId,
        booruIdHint,
        apiKey,
        login,
        passHash,
        name,
        deletedItemBehavior,
        ratingFilter,
        bannedPostVisibility,
        url,
        customDownloadFileNameFormat,
        customBulkDownloadFileNameFormat,
        customDownloadLocation,
        imageDetaisQuality,
        granularRatingFilters,
        postGestures,
        defaultPreviewImageButtonAction,
        listing,
        alwaysIncludeTags,
      ];

  @override
  String toString() {
    return 'Config(id=$id, booruId=$booruIdHint, name=$name, url=$url, login=${hasLoginDetails()})';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booruId': booruId,
      'booruIdHint': booruIdHint,
      'apiKey': apiKey,
      'login': login,
      'passHash': passHash,
      'url': url,
      'name': name,
      'deletedItemBehavior': deletedItemBehavior.index,
      'ratingFilter': ratingFilter.index,
      'bannedPostVisibility': bannedPostVisibility.index,
      'customDownloadFileNameFormat': customDownloadFileNameFormat,
      'customBulkDownloadFileNameFormat': customBulkDownloadFileNameFormat,
      'customDownloadLocation': customDownloadLocation,
      'imageDetaisQuality': imageDetaisQuality,
      'granularRatingFilterString': granularRatingFilterToString(
        granularRatingFilters,
      ),
      'postGestures': postGestures?.toJson(),
      'defaultPreviewImageButtonAction': defaultPreviewImageButtonAction,
      'listing': listing?.toJson(),
      'alwaysIncludeTags': alwaysIncludeTags,
    };
  }
}

class BooruConfigAuth extends Equatable with BooruConfigAuthMixin {
  const BooruConfigAuth({
    required this.booruId,
    required this.booruIdHint,
    required this.url,
    required this.apiKey,
    required this.login,
    required this.passHash,
  });

  factory BooruConfigAuth.fromConfig(BooruConfig config) {
    return BooruConfigAuth(
      booruId: config.booruId,
      booruIdHint: config.booruIdHint,
      url: config.url,
      apiKey: config.apiKey,
      login: config.login,
      passHash: config.passHash,
    );
  }

  @override
  final int booruId;
  @override
  final int booruIdHint;
  final String url;
  @override
  final String? apiKey;
  @override
  final String? login;
  final String? passHash;

  @override
  List<Object?> get props => [
        booruId,
        booruIdHint,
        url,
        apiKey,
        login,
        passHash,
      ];
}

Set<Rating>? parseGranularRatingFilters(String? granularRatingFilterString) {
  if (granularRatingFilterString == null) return null;

  return granularRatingFilterString
      .split('|')
      .map((e) => mapStringToRating(e))
      .toSet();
}

String? granularRatingFilterToString(Set<Rating>? granularRatingFilters) {
  if (granularRatingFilters == null) return null;

  return granularRatingFilters.map((e) => e.toShortString()).join('|');
}

enum BooruConfigDeletedItemBehavior {
  show,
  hide,
}

enum BooruConfigRatingFilter {
  none,
  hideExplicit,
  hideNSFW,
  custom,
}

enum BooruConfigBannedPostVisibility {
  show,
  hide,
}

extension BooruConfigRatingFilterX on BooruConfigRatingFilter {
  String getRatingTerm() => switch (this) {
        BooruConfigRatingFilter.none => 'None',
        BooruConfigRatingFilter.hideExplicit => 'Safeish',
        BooruConfigRatingFilter.hideNSFW => 'Safe',
        BooruConfigRatingFilter.custom => 'Custom'
      };

  String getFilterRatingTerm() => switch (this) {
        BooruConfigRatingFilter.none => 'None',
        BooruConfigRatingFilter.hideExplicit => 'Moderate',
        BooruConfigRatingFilter.hideNSFW => 'Aggressive',
        BooruConfigRatingFilter.custom => 'Custom'
      };
}

extension BooruConfigNullX on BooruConfig? {
  bool get hideBannedPosts =>
      this?.bannedPostVisibility == BooruConfigBannedPostVisibility.hide;
}

mixin BooruConfigAuthMixin {
  int? get booruIdHint;
  int get booruId;

  String? get login;
  String? get apiKey;

  BooruType get booruType => intToBooruType(booruIdHint);

  bool isUnverified() => booruId != booruIdHint;

  bool hasLoginDetails() {
    if (login == null || apiKey == null) return false;
    if (login!.isEmpty && apiKey!.isEmpty) return false;

    return true;
  }
}

extension BooruConfigX on BooruConfig {
  Booru? createBooruFrom(BooruFactory factory) =>
      factory.create(type: intToBooruType(booruId));

  bool isDefault() => id == -1;

  bool get hasStrictSFW => url == kDanbooruSafeUrl && isIOS();
  bool get hasSoftSFW => url == kDanbooruSafeUrl;

  Set<Rating>? get granularRatingFiltersWithoutUnknown {
    if (granularRatingFilters == null) return null;

    return granularRatingFilters!.where((e) => e != Rating.unknown).toSet();
  }

  ImageQuickActionType get defaultPreviewImageButtonActionType =>
      switch (defaultPreviewImageButtonAction) {
        kDownloadAction => ImageQuickActionType.download,
        kToggleBookmarkAction => ImageQuickActionType.bookmark,
        kViewArtistAction => ImageQuickActionType.artist,
        '' => ImageQuickActionType.none,
        _ => ImageQuickActionType.defaultAction,
      };

  BooruConfigAuth get auth => BooruConfigAuth.fromConfig(this);
}

enum ImageQuickActionType {
  none,
  defaultAction,
  download,
  bookmark,
  artist,
}
