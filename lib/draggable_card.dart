import 'package:flutter/material.dart';

class DraggableResizableWidget extends StatefulWidget {
  final Widget child;

  DraggableResizableWidget({required this.child});

  @override
  _DraggableResizableWidgetState createState() =>
      _DraggableResizableWidgetState();
}

class _DraggableResizableWidgetState extends State<DraggableResizableWidget> {
  double top = 0;
  double left = 0;
  double scale = 1.0;
  double initialScale = 1.0;
  Offset initialFocalPoint = Offset(0, 0);
  Offset initialPosition = Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        // onScaleStart: (details) {
        //   initialScale = scale;
        //   initialFocalPoint = details.focalPoint;
        //   initialPosition = Offset(left, top);
        // },
        onScaleUpdate: (details) {
          setState(() {
            top = initialPosition.dy + (details.focalPoint.dy - initialFocalPoint.dy) / scale;
            left = initialPosition.dx + (details.focalPoint.dx - initialFocalPoint.dx) / scale;
            scale = initialScale * details.scale;
          });
        },
        child: Transform.scale(
          scale: scale,
          child: widget.child,
        ),
      ),
    );
  }
}
