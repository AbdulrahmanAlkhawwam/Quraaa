import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_shadows.dart';

enum PdfPageTurnSide { left, right }

class PdfPageTurnGestureLayer extends StatefulWidget {
  const PdfPageTurnGestureLayer({
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
    super.key,
  });

  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  State<PdfPageTurnGestureLayer> createState() =>
      _PdfPageTurnGestureLayerState();
}

class _PdfPageTurnGestureLayerState extends State<PdfPageTurnGestureLayer> {
  static const double _edgeWidth = 36;
  static const double _turnDistance = 150;
  static const double _turnThreshold = 0.42;

  PdfPageTurnSide? _activeSide;
  Offset? _pressPosition;
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    final bool hasTurnAction = widget.canGoPrevious || widget.canGoNext;
    if (!hasTurnAction) {
      return const SizedBox.shrink();
    }

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        if (_activeSide != null && _pressPosition != null)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _PageCurlPainter(
                  side: _activeSide!,
                  progress: _progress,
                  pressPosition: _pressPosition!,
                ),
              ),
            ),
          ),
        if (_activeSide != null && _pressPosition != null)
          Positioned.fill(
            child: IgnorePointer(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final Size size = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  return _GrabHandIndicator(
                    center: _indicatorCenter(size),
                    side: _activeSide!,
                  );
                },
              ),
            ),
          ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: _PaperEdgeGesture(
            width: _edgeWidth,
            enabled: widget.canGoPrevious,
            side: PdfPageTurnSide.left,
            onStart: _start,
            onMove: _move,
            onEnd: () => _end(widget.onPrevious),
          ),
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: _PaperEdgeGesture(
            width: _edgeWidth,
            enabled: widget.canGoNext,
            side: PdfPageTurnSide.right,
            onStart: _start,
            onMove: _move,
            onEnd: () => _end(widget.onNext),
          ),
        ),
      ],
    );
  }

  void _start(PdfPageTurnSide side, Offset position) {
    setState(() {
      _activeSide = side;
      _pressPosition = position;
      _progress = 0.08;
    });
  }

  void _move(PdfPageTurnSide side, Offset position, double delta) {
    if (_activeSide != side) {
      return;
    }

    setState(() {
      _pressPosition = position;
      _progress = (delta.abs() / _turnDistance).clamp(0.08, 1).toDouble();
    });
  }

  void _end(VoidCallback onCompleted) {
    final bool shouldComplete = _progress >= _turnThreshold;
    setState(() {
      _activeSide = null;
      _pressPosition = null;
      _progress = 0;
    });

    if (shouldComplete) {
      onCompleted();
    }
  }

  Offset _indicatorCenter(Size size) {
    final Offset position = _pressPosition!;
    final double y = position.dy.clamp(28.0, size.height - 28);
    if (_activeSide == PdfPageTurnSide.left) {
      return Offset(position.dx.clamp(14.0, 38.0), y);
    }

    final double x = size.width - (_edgeWidth - position.dx);
    return Offset(x.clamp(size.width - 38, size.width - 14), y);
  }
}

class _PaperEdgeGesture extends StatelessWidget {
  const _PaperEdgeGesture({
    required this.width,
    required this.enabled,
    required this.side,
    required this.onStart,
    required this.onMove,
    required this.onEnd,
  });

  final double width;
  final bool enabled;
  final PdfPageTurnSide side;
  final void Function(PdfPageTurnSide side, Offset position) onStart;
  final void Function(
    PdfPageTurnSide side,
    Offset position,
    double delta,
  ) onMove;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: double.infinity,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onLongPressStart: !enabled
            ? null
            : (LongPressStartDetails details) {
                onStart(side, details.localPosition);
              },
        onLongPressMoveUpdate: !enabled
            ? null
            : (LongPressMoveUpdateDetails details) {
                final double turnDelta = side == PdfPageTurnSide.left
                    ? details.offsetFromOrigin.dx
                    : -details.offsetFromOrigin.dx;
                onMove(side, details.localPosition, turnDelta);
              },
        onLongPressEnd: !enabled ? null : (_) => onEnd(),
        onLongPressCancel: !enabled ? null : onEnd,
      ),
    );
  }
}

class _PageCurlPainter extends CustomPainter {
  const _PageCurlPainter({
    required this.side,
    required this.progress,
    required this.pressPosition,
  });

  final PdfPageTurnSide side;
  final double progress;
  final Offset pressPosition;

  @override
  void paint(Canvas canvas, Size size) {
    final bool isLeft = side == PdfPageTurnSide.left;
    final double curlWidth = (size.width * 0.5 * progress)
        .clamp(18.0, size.width * 0.58)
        .toDouble();
    final double clampedY = pressPosition.dy.clamp(28.0, size.height - 28);
    final bool turnsFromTop = clampedY < size.height / 2;
    final double cornerY = turnsFromTop ? 0 : size.height;
    final double edgeX = isLeft ? 0 : size.width;
    final Offset corner = Offset(edgeX, cornerY);
    final Offset horizontalTip = Offset(
      isLeft ? curlWidth : size.width - curlWidth,
      cornerY,
    );
    final Offset verticalTip = Offset(
      edgeX,
      turnsFromTop
          ? math.min(size.height, curlWidth * 1.16)
          : math.max(0, size.height - curlWidth * 1.16),
    );
    final Offset pulledTip = Offset(
      isLeft
          ? math.min(size.width, curlWidth * 1.08)
          : math.max(0, size.width - curlWidth * 1.08),
      turnsFromTop
          ? math.min(size.height, curlWidth * 0.98)
          : math.max(0, size.height - curlWidth * 0.98),
    );

    final Path curlPath = Path()
      ..moveTo(corner.dx, corner.dy)
      ..lineTo(horizontalTip.dx, horizontalTip.dy)
      ..lineTo(pulledTip.dx, pulledTip.dy)
      ..lineTo(verticalTip.dx, verticalTip.dy)
      ..close();
    final Rect curlBounds = curlPath.getBounds();

    canvas.drawPath(
      curlPath,
      Paint()
        ..shader = LinearGradient(
          begin: isLeft ? Alignment.centerLeft : Alignment.centerRight,
          end: isLeft ? Alignment.centerRight : Alignment.centerLeft,
          colors: const <Color>[
            Color(0xEEFFFFFF),
            Color(0xDCF7F3E9),
            Color(0x883A3024),
          ],
          stops: const <double>[0, 0.72, 1],
        ).createShader(curlBounds),
    );
    canvas.drawPath(
      curlPath,
      Paint()
        ..color = const Color(0x33423B2B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, 2.4 * progress),
    );
  }

  @override
  bool shouldRepaint(covariant _PageCurlPainter oldDelegate) {
    return side != oldDelegate.side ||
        progress != oldDelegate.progress ||
        pressPosition != oldDelegate.pressPosition;
  }
}

class _GrabHandIndicator extends StatelessWidget {
  const _GrabHandIndicator({
    required this.center,
    required this.side,
  });

  final Offset center;
  final PdfPageTurnSide side;

  @override
  Widget build(BuildContext context) {
    final double angle = side == PdfPageTurnSide.left ? -0.28 : 0.28;

    return Stack(
      children: <Widget>[
        Positioned(
          left: center.dx - 16,
          top: center.dy - 16,
          child: Transform.rotate(
            angle: angle,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xEFFFFFFF),
                borderRadius: BorderRadius.circular(7),
                boxShadow: AppShadows.elevation1,
              ),
              child: const Padding(
                padding: EdgeInsets.all(5),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedHandGrab,
                  color: AppColors.secondary,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
