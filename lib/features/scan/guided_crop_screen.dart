import 'dart:io';

import 'package:flutter/material.dart';

/// The user boxes each souvenir on one photo of the whole shelf or
/// fridge. Resolves to the boxes as normalized rects (0–1 of the image),
/// or null when they back out.
///
/// Automatic scene splitting is deliberately not attempted: a person
/// drawing boxes is reliable on day one, and the crops feed the same
/// review grid a detector would.
class GuidedCropScreen extends StatefulWidget {
  const GuidedCropScreen({
    super.key,
    required this.imagePath,
    required this.imageSize,
    this.single = false,
  });

  final String imagePath;

  /// One box only — cropping a single souvenir's photo. Drawing again
  /// replaces the box, and the action reads "Crop" instead of "Next".
  final bool single;

  /// Pixel size of the image, for the aspect-correct fit.
  final Size imageSize;

  /// Boxes narrower or shorter than this fraction are accidental taps.
  static const minBoxFraction = 0.03;

  @override
  State<GuidedCropScreen> createState() => _GuidedCropScreenState();
}

class _GuidedCropScreenState extends State<GuidedCropScreen> {
  final _boxes = <Rect>[];
  Offset? _dragStart;
  Offset? _dragCurrent;

  Rect? get _dragRect => _dragStart == null || _dragCurrent == null
      ? null
      : Rect.fromPoints(_dragStart!, _dragCurrent!);

  Offset _normalize(Offset local, Size displayed) => Offset(
    (local.dx / displayed.width).clamp(0.0, 1.0),
    (local.dy / displayed.height).clamp(0.0, 1.0),
  );

  void _endDrag() {
    final rect = _dragRect;
    setState(() {
      _dragStart = null;
      _dragCurrent = null;
      if (rect != null &&
          rect.width >= GuidedCropScreen.minBoxFraction &&
          rect.height >= GuidedCropScreen.minBoxFraction) {
        if (widget.single) _boxes.clear();
        _boxes.add(rect);
      }
    });
  }

  void _tap(Offset normalized) {
    final hit = _boxes.lastWhere(
      (b) => b.contains(normalized),
      orElse: () => Rect.zero,
    );
    if (hit != Rect.zero) setState(() => _boxes.remove(hit));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.single ? 'Crop the photo' : 'Box each souvenir'),
        actions: [
          TextButton(
            onPressed: _boxes.isEmpty
                ? null
                : () => Navigator.of(context).pop(List.of(_boxes)),
            child: Text(
              widget.single
                  ? 'Crop'
                  : _boxes.isEmpty
                  ? 'Next'
                  : 'Next · ${_boxes.length}',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              widget.single
                  ? 'Drag a box around the souvenir. Drag again to redo. '
                        'Rough is fine.'
                  : 'Drag a box around each souvenir. Tap a box to remove it. '
                        'Rough is fine — each box becomes its own photo.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final scale = (constraints.maxWidth / widget.imageSize.width)
                    .clamp(
                      0.0,
                      constraints.maxHeight / widget.imageSize.height,
                    );
                final displayed = Size(
                  widget.imageSize.width * scale,
                  widget.imageSize.height * scale,
                );
                return Center(
                  child: SizedBox.fromSize(
                    size: displayed,
                    child: GestureDetector(
                      key: const Key('guided-crop-canvas'),
                      behavior: HitTestBehavior.opaque,
                      // The box corner is where the finger landed, not
                      // where the pan recognizer accepted (~18px later).
                      onPanDown: (d) => setState(() {
                        _dragStart = _normalize(d.localPosition, displayed);
                        _dragCurrent = _dragStart;
                      }),
                      onPanUpdate: (d) => setState(() {
                        _dragCurrent = _normalize(d.localPosition, displayed);
                      }),
                      onPanEnd: (_) => _endDrag(),
                      onPanCancel: _endDrag,
                      onTapUp: (d) =>
                          _tap(_normalize(d.localPosition, displayed)),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            File(widget.imagePath),
                            fit: BoxFit.fill,
                            errorBuilder: (_, _, _) => Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                            ),
                          ),
                          CustomPaint(
                            painter: _BoxesPainter(
                              boxes: _boxes,
                              draft: _dragRect,
                              color: theme.colorScheme.primary,
                              labelStyle: theme.textTheme.labelSmall!.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Text(
                _boxes.isEmpty
                    ? (widget.single ? 'No crop yet.' : 'No boxes yet.')
                    : widget.single
                    ? 'Crop set.'
                    : '${_boxes.length} ${_boxes.length == 1 ? 'box' : 'boxes'}',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BoxesPainter extends CustomPainter {
  _BoxesPainter({
    required this.boxes,
    required this.draft,
    required this.color,
    required this.labelStyle,
  });

  final List<Rect> boxes;
  final Rect? draft;
  final Color color;
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    Rect scaled(Rect r) => Rect.fromLTRB(
      r.left * size.width,
      r.top * size.height,
      r.right * size.width,
      r.bottom * size.height,
    );
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = color;
    final fill = Paint()..color = color.withValues(alpha: 0.15);
    final label = Paint()..color = color;

    for (var i = 0; i < boxes.length; i++) {
      final r = scaled(boxes[i]);
      canvas.drawRect(r, fill);
      canvas.drawRect(r, stroke);
      final tp = TextPainter(
        text: TextSpan(text: '${i + 1}', style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final badge = Rect.fromLTWH(r.left, r.top, tp.width + 10, tp.height + 4);
      canvas.drawRect(badge, label);
      tp.paint(canvas, badge.topLeft + const Offset(5, 2));
    }
    final d = draft;
    if (d != null) {
      canvas.drawRect(
        scaled(d),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = color.withValues(alpha: 0.7),
      );
    }
  }

  @override
  bool shouldRepaint(_BoxesPainter old) =>
      old.boxes != boxes ||
      old.draft != draft ||
      old.boxes.length != boxes.length;
}
