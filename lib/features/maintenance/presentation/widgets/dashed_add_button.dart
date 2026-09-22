import 'package:design_system/colors/app_colors.dart';
import 'package:flutter/material.dart';

/// Dashed-border "add another row" button shared by every work-list form
/// (ТО, Тюнінг, ...) - visually distinct from a solid button since it adds
/// a line item rather than submitting the form.
class DashedAddButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const DashedAddButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CustomPaint(
        painter: _DashedBorderPainter(AppColors.dashedBorder),
        child: TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
            minimumSize: const Size.fromHeight(44),
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.add, size: 15),
          label: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  const _DashedBorderPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(0.5),
          const Radius.circular(10),
        ),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final metric in path.computeMetrics()) {
      for (double offset = 0; offset < metric.length; offset += 9) {
        canvas.drawPath(metric.extractPath(offset, offset + 5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      color != oldDelegate.color;
}
