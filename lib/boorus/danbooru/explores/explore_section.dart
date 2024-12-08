// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/theme.dart';
import 'package:boorusama/foundation/i18n.dart';

class ExploreSection extends StatelessWidget {
  const ExploreSection({
    super.key,
    required this.title,
    required this.builder,
    required this.onPressed,
  });

  final Widget Function(BuildContext context) builder;
  final String title;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          title: Text(
            title,
            style: context.textTheme.titleLarge!
                .copyWith(fontWeight: FontWeight.w700),
          ),
          trailing: onPressed != null
              ? TextButton(
                  onPressed: onPressed,
                  child: Text(
                    'explore.see_more',
                    style: context.textTheme.labelLarge,
                  ).tr(),
                )
              : null,
        ),
        builder(context),
      ],
    );
  }
}
