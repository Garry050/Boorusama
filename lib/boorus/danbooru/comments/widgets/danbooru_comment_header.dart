// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/comments/comments.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/comments/comment_header.dart';
import 'package:boorusama/core/users/colors.dart';

class DanbooruCommentHeader extends ConsumerWidget {
  const DanbooruCommentHeader({
    super.key,
    required this.comment,
  });

  final CommentData comment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommentHeader(
      authorName: comment.authorName,
      authorTitleColor: Color(getUserHexColor(comment.authorLevel)),
      createdAt: comment.createdAt,
      onTap: () => goToUserDetailsPage(
        context,
        uid: comment.authorId,
      ),
    );
  }
}
