import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// Bridges one-finger interactions won by an image viewer to the surrounding
/// page view.
class ViewerPageDragController {
  ViewerPageDragController({
    required PageController pageController,
    required Axis Function() axis,
    required bool Function() canDrag,
  }) : _pageController = pageController,
       _axis = axis,
       _canDrag = canDrag;

  final PageController _pageController;
  final Axis Function() _axis;
  final bool Function() _canDrag;

  Drag? _drag;
  ScrollHoldController? _hold;

  void start(ScaleStartDetails details, {required bool enabled}) {
    cancel();

    if (!enabled || details.pointerCount != 1 || !_canStartDrag) return;

    final position = _pageController.position;
    _hold = position.hold(_disposeHold);
    _drag = position.drag(
      DragStartDetails(
        sourceTimeStamp: details.sourceTimeStamp,
        globalPosition: details.focalPoint,
        localPosition: details.localFocalPoint,
        kind: details.kind,
      ),
      _disposeDrag,
    );
  }

  void update(ScaleUpdateDetails details, {required bool enabled}) {
    final drag = _drag;
    if (drag == null) return;

    if (!enabled || details.pointerCount != 1 || !_canContinueDrag) {
      cancel();
      return;
    }

    final delta = _axisOffset(details.focalPointDelta);
    drag.update(
      DragUpdateDetails(
        sourceTimeStamp: details.sourceTimeStamp,
        delta: delta,
        primaryDelta: _primaryValue(delta),
        globalPosition: details.focalPoint,
        localPosition: details.localFocalPoint,
      ),
    );
  }

  void end(ScaleEndDetails details, {required bool enabled}) {
    final drag = _drag;
    _drag = null;
    _cancelHold();

    if (drag == null) return;

    if (!enabled || details.pointerCount > 0 || !_canContinueDrag) {
      drag.cancel();
      return;
    }

    final velocity = _axisOffset(details.velocity.pixelsPerSecond);
    drag.end(
      DragEndDetails(
        velocity: Velocity(pixelsPerSecond: velocity),
        primaryVelocity: _primaryValue(velocity),
      ),
    );
  }

  void cancel() {
    final drag = _drag;
    _drag = null;
    drag?.cancel();
    _cancelHold();
  }

  void dispose() => cancel();

  bool get _canStartDrag =>
      _pageController.hasClients &&
      _canDrag() &&
      !_pageController.position.isScrollingNotifier.value;

  bool get _canContinueDrag => _pageController.hasClients && _canDrag();

  Offset _axisOffset(Offset value) => switch (_axis()) {
    Axis.horizontal => Offset(value.dx, 0),
    Axis.vertical => Offset(0, value.dy),
  };

  double _primaryValue(Offset value) => switch (_axis()) {
    Axis.horizontal => value.dx,
    Axis.vertical => value.dy,
  };

  void _disposeDrag() => _drag = null;

  void _disposeHold() => _hold = null;

  void _cancelHold() {
    final hold = _hold;
    _hold = null;
    hold?.cancel();
  }
}
