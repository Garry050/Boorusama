// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'bookmark_scroll_view.dart';
import 'providers.dart';

class BookmarkPage extends ConsumerStatefulWidget {
  const BookmarkPage({
    super.key,
  });

  @override
  ConsumerState<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends ConsumerState<BookmarkPage> {
  final _searchController = TextEditingController();
  final scrollController = AutoScrollController();
  final focusNode = FocusNode();

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
    scrollController.dispose();
    focusNode.dispose();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      ref.read(selectedTagsProvider.notifier).state = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomContextMenuOverlay(
      child: Scaffold(
        floatingActionButton: ScrollToTop(
          scrollController: scrollController,
          child: BooruScrollToTopButton(
            onPressed: () => scrollController.jumpTo(0),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: BookmarkScrollView(
            controller: scrollController,
            focusNode: focusNode,
            searchController: _searchController,
          ),
        ),
      ),
    );
  }
}
