// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/sankaku/sankaku.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/home/home.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/router.dart';

class SankakuHomePage extends ConsumerWidget {
  const SankakuHomePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final login = config.login;

    return HomePageScaffold(
      mobileMenu: [
        if (login != null)
          SideMenuTile(
            icon: const Icon(Symbols.favorite),
            title: Text('profile.favorites'.tr()),
            onTap: () {
              goToFavoritesPage(context);
            },
          ),
      ],
      desktopMenuBuilder: (context, constraints) => [
        if (login != null)
          HomeNavigationTile(
            value: 1,
            constraints: constraints,
            selectedIcon: Symbols.favorite,
            icon: Symbols.favorite,
            title: 'Favorites',
          ),
      ],
      desktopViews: [if (login != null) SankakuFavoritesPage(username: login)],
    );
  }
}

class SankakuFavoritesPage extends ConsumerWidget {
  const SankakuFavoritesPage({
    super.key,
    required this.username,
  });

  final String username;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final query = 'fav:$username';

    return FavoritesPageScaffold(
      favQueryBuilder: () => query,
      fetcher: (page) =>
          ref.read(sankakuPostRepoProvider(config)).getPosts(query, page),
    );
  }
}
