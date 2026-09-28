// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../settings/providers.dart';

class InteractiveViewerExtended extends ConsumerWidget {
  const InteractiveViewerExtended({
    required this.child,
    super.key,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.controller,
    this.onTransformationChanged,
    this.onInteractionStart,
    this.onInteractionUpdate,
    this.onInteractionEnd,
    this.enable = true,
    this.contentSize,
    this.panEnabled = true,
    this.scaleEnabled = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final void Function(TapDownDetails?)? onDoubleTap;
  final VoidCallback? onLongPress;
  final void Function(KurumiTransformationDetails details)?
  onTransformationChanged;
  final GestureScaleStartCallback? onInteractionStart;
  final GestureScaleUpdateCallback? onInteractionUpdate;
  final GestureScaleEndCallback? onInteractionEnd;
  final TransformationController? controller;
  final bool enable;
  final Size? contentSize;
  final bool panEnabled;
  final bool scaleEnabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableHapticFeedback = ref.watch(
      hapticFeedbackLevelProvider.select((value) => value.isReducedOrAbove),
    );

    return KurumiInteractiveViewer(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      controller: controller,
      onTransformationChanged: onTransformationChanged,
      onInteractionStart: onInteractionStart,
      onInteractionUpdate: onInteractionUpdate,
      onInteractionEnd: onInteractionEnd,
      enable: enable,
      contentSize: contentSize,
      enableHapticFeedback: enableHapticFeedback,
      panEnabled: panEnabled,
      scaleEnabled: scaleEnabled,
      child: child,
    );
  }
}
