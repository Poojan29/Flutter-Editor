import 'package:flutter/material.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';

typedef PointMoveCallback = void Function(Offset offset);

class OverLayedWidget extends StatelessWidget {
  final Widget child;
  final VoidCallback onDragStart;
  final VoidCallback onDragEnd;
  final PointMoveCallback onDragUpdate;

  const OverLayedWidget(
      {Key? key,
      required this.child,
      required this.onDragStart,
      required this.onDragEnd,
      required this.onDragUpdate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());

    return Listener(
      onPointerMove: (event) {
        onDragUpdate(event.position);
      },
      child: MatrixGestureDetector(
        onMatrixUpdate: (m, tm, sm, rm) {
          notifier.value = m;
        },
        onScaleStart: () {
          onDragStart();
        },
        onScaleEnd: () {
          onDragEnd();
        },
        child: AnimatedBuilder(
            animation: notifier,
            builder: (ctx, childWidget) {
              return Transform(
                transform: notifier.value,
                child: child,
              );
            }),
      ),
    );
  }
}
