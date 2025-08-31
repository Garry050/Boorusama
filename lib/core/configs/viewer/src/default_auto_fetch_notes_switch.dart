// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../widgets/widgets.dart';
import '../../config/types.dart';
import '../../create/providers.dart';

class DefaultAutoFetchNotesSwitch extends ConsumerWidget {
  const DefaultAutoFetchNotesSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoLoadNotes = ref.watch(
      editBooruConfigProvider(ref.watch(editBooruConfigIdProvider)).select(
        (value) =>
            value.viewerNotesFetchBehaviorTyped ==
            BooruConfigViewerNotesFetchBehavior.auto,
      ),
    );

    return BooruSwitchListTile(
      title: Text(context.t.booru.viewer.auto_fetch_notes),
      subtitle: Text(
        context.t.booru.viewer.auto_fetch_notes_description,
      ),
      value: autoLoadNotes,
      onChanged: (value) =>
          ref.editNotifier.updateViewerNotesFetchBehavior(value),
      contentPadding: EdgeInsets.zero,
    );
  }
}
