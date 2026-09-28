import 'package:boorusama/core/posts/details_pageview/src/viewer_page_drag_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

void main() {
  testWidgets(
    'fast one-finger viewer gestures move horizontal pages in both directions',
    (tester) async {
      final controller = _HarnessController(Axis.horizontal);
      final transformController = TransformationController();
      var viewerInteractionCount = 0;

      await tester.pumpWidget(
        _ViewerPageHarness(
          controller: controller,
          transformController: transformController,
          onViewerInteractionStart: () => viewerInteractionCount++,
        ),
      );
      await tester.pumpAndSettle();

      await _fastDrag(tester, const ValueKey('page-1'), const Offset(-500, 0));

      expect(controller.pageController.page, closeTo(2, 0.001));
      expect(viewerInteractionCount, 1);

      await _fastDrag(tester, const ValueKey('page-2'), const Offset(500, 0));

      expect(controller.pageController.page, closeTo(1, 0.001));
      expect(viewerInteractionCount, 2);

      await _disposeHarness(tester, controller, transformController);
    },
  );

  testWidgets('slow drags snap and stop at horizontal page edges', (
    tester,
  ) async {
    final controller = _HarnessController(Axis.horizontal);
    final transformController = TransformationController();

    await tester.pumpWidget(
      _ViewerPageHarness(
        controller: controller,
        transformController: transformController,
      ),
    );
    await tester.pumpAndSettle();

    await _slowDrag(tester, const ValueKey('page-1'), const Offset(-500, 0));
    expect(controller.pageController.page, closeTo(2, 0.001));

    await _slowDrag(tester, const ValueKey('page-2'), const Offset(-500, 0));
    expect(controller.pageController.page, closeTo(2, 0.001));

    await _slowDrag(tester, const ValueKey('page-2'), const Offset(500, 0));
    await _slowDrag(tester, const ValueKey('page-1'), const Offset(500, 0));
    expect(controller.pageController.page, closeTo(0, 0.001));

    await _slowDrag(tester, const ValueKey('page-0'), const Offset(500, 0));
    expect(controller.pageController.page, closeTo(0, 0.001));

    await _disposeHarness(tester, controller, transformController);
  });

  testWidgets(
    'pinch and zoomed pan keep the page fixed and identity restores paging',
    (tester) async {
      final controller = _HarnessController(Axis.horizontal);
      final transformController = TransformationController();

      await tester.pumpWidget(
        _ViewerPageHarness(
          controller: controller,
          transformController: transformController,
        ),
      );
      await tester.pumpAndSettle();

      final center = tester.getCenter(find.byKey(const ValueKey('page-1')));
      final firstPointer = await tester.startGesture(
        center - const Offset(40, 0),
        pointer: 1,
      );
      final secondPointer = await tester.startGesture(
        center + const Offset(40, 0),
        pointer: 2,
      );
      await tester.pump();
      await firstPointer.moveTo(center - const Offset(160, 0));
      await secondPointer.moveTo(center + const Offset(160, 0));
      await tester.pump();
      await firstPointer.up();
      await secondPointer.up();
      await tester.pumpAndSettle();

      expect(controller.pageController.page, closeTo(1, 0.001));
      expect(transformController.value.getMaxScaleOnAxis(), greaterThan(1));
      expect(controller.zoomed, isTrue);

      await _fastDrag(tester, const ValueKey('page-1'), const Offset(-500, 0));

      expect(controller.pageController.page, closeTo(1, 0.001));

      transformController.value = Matrix4.identity();
      await tester.pump();
      expect(controller.zoomed, isFalse);

      await _fastDrag(tester, const ValueKey('page-1'), const Offset(-500, 0));

      expect(controller.pageController.page, closeTo(2, 0.001));

      await _disposeHarness(tester, controller, transformController);
    },
  );

  testWidgets(
    'multi-touch and disabled states do not leave a stale vertical drag',
    (tester) async {
      final controller = _HarnessController(Axis.vertical);
      final transformController = TransformationController();

      await tester.pumpWidget(
        _ViewerPageHarness(
          controller: controller,
          transformController: transformController,
        ),
      );
      await tester.pumpAndSettle();

      final center = tester.getCenter(find.byKey(const ValueKey('page-1')));
      final firstPointer = await tester.startGesture(center, pointer: 1);
      await firstPointer.moveBy(const Offset(0, -80));
      final secondPointer = await tester.startGesture(
        center + const Offset(40, 0),
        pointer: 2,
      );
      await tester.pump();
      await secondPointer.up();
      await firstPointer.up();
      await tester.pumpAndSettle();

      transformController.value = Matrix4.identity();
      controller
        ..setSwipeEnabled(false)
        ..setSwipeEnabled(true)
        ..setSheetExpanded(true)
        ..setSheetExpanded(false);
      await tester.pump();

      await _fastDrag(tester, const ValueKey('page-1'), const Offset(0, -400));

      expect(controller.pageController.page, closeTo(2, 0.001));

      await _disposeHarness(tester, controller, transformController);
    },
  );
}

class _HarnessController {
  _HarnessController(this.axis) {
    viewerPageDrag = ViewerPageDragController(
      pageController: pageController,
      axis: () => axis,
      canDrag: () => pagePagingEnabled,
    );
  }

  final Axis axis;
  final pageController = PageController(initialPage: 1);
  final pagePagingEnabledNotifier = ValueNotifier(true);

  late final ViewerPageDragController viewerPageDrag;

  var zoomed = false;
  var _swipeEnabled = true;
  var _sheetExpanded = false;

  bool get viewerEnabled => !_sheetExpanded;
  bool get pagePagingEnabled => _swipeEnabled && !_sheetExpanded && !zoomed;

  void onViewerInteractionStart(ScaleStartDetails details) {
    viewerPageDrag.start(details, enabled: viewerEnabled);
  }

  void onViewerInteractionUpdate(ScaleUpdateDetails details) {
    viewerPageDrag.update(details, enabled: viewerEnabled);
  }

  void onViewerInteractionEnd(ScaleEndDetails details) {
    viewerPageDrag.end(details, enabled: viewerEnabled);
  }

  void onTransformationChanged(KurumiTransformationDetails details) {
    zoomed = details.isZoomed;
    _syncPagingState();
  }

  void setSwipeEnabled(bool value) {
    _swipeEnabled = value;
    _syncPagingState();
  }

  void setSheetExpanded(bool value) {
    _sheetExpanded = value;
    _syncPagingState();
  }

  void _syncPagingState() {
    if (!pagePagingEnabled) {
      viewerPageDrag.cancel();
    }
    pagePagingEnabledNotifier.value = pagePagingEnabled;
  }

  void dispose() {
    viewerPageDrag.dispose();
    pageController.dispose();
    pagePagingEnabledNotifier.dispose();
  }
}

class _ViewerPageHarness extends StatelessWidget {
  const _ViewerPageHarness({
    required this.controller,
    required this.transformController,
    this.onViewerInteractionStart,
  });

  final _HarnessController controller;
  final TransformationController transformController;
  final VoidCallback? onViewerInteractionStart;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ValueListenableBuilder(
        valueListenable: controller.pagePagingEnabledNotifier,
        builder: (context, pagePagingEnabled, _) => PageView.builder(
          controller: controller.pageController,
          scrollDirection: controller.axis,
          physics: pagePagingEnabled
              ? const PageScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) => KurumiInteractiveViewer(
            controller: transformController,
            contentSize: const Size(800, 600),
            onTransformationChanged: controller.onTransformationChanged,
            onInteractionStart: (details) {
              onViewerInteractionStart?.call();
              controller.onViewerInteractionStart(details);
            },
            onInteractionUpdate: controller.onViewerInteractionUpdate,
            onInteractionEnd: controller.onViewerInteractionEnd,
            child: ColoredBox(
              key: ValueKey('page-$index'),
              color: Colors.primaries[index],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _fastDrag(
  WidgetTester tester,
  Key pageKey,
  Offset delta,
) async {
  final gesture = await tester.startGesture(
    tester.getCenter(find.byKey(pageKey)),
  );
  await gesture.moveBy(delta);
  await gesture.up();
  await tester.pumpAndSettle();
}

Future<void> _slowDrag(
  WidgetTester tester,
  Key pageKey,
  Offset delta,
) async {
  await tester.timedDrag(
    find.byKey(pageKey),
    delta,
    const Duration(milliseconds: 600),
  );
  await tester.pumpAndSettle();
}

Future<void> _disposeHarness(
  WidgetTester tester,
  _HarnessController controller,
  TransformationController transformController,
) async {
  await tester.pumpWidget(const SizedBox.shrink());
  controller.dispose();
  transformController.dispose();
}
