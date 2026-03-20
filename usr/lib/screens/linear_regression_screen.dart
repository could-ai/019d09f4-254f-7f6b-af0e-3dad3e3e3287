import 'package:flutter/material.dart';

class LinearRegressionScreen extends StatefulWidget {
  const LinearRegressionScreen({super.key});

  @override
  State<LinearRegressionScreen> createState() => _LinearRegressionScreenState();
}

class _LinearRegressionScreenState extends State<LinearRegressionScreen> {
  List<Offset> points = [];
  double? m; // slope
  double? b; // y-intercept

  void _addPoint(TapDownDetails details) {
    setState(() {
      points.add(details.localPosition);
      _calculateRegression();
    });
  }

  void _clearPoints() {
    setState(() {
      points.clear();
      m = null;
      b = null;
    });
  }

  void _calculateRegression() {
    if (points.length < 2) {
      m = null;
      b = null;
      return;
    }

    double sumX = 0;
    double sumY = 0;
    double sumXY = 0;
    double sumX2 = 0;
    int n = points.length;

    for (var p in points) {
      sumX += p.dx;
      sumY += p.dy;
      sumXY += p.dx * p.dy;
      sumX2 += p.dx * p.dx;
    }

    double denominator = (n * sumX2) - (sumX * sumX);
    if (denominator == 0) return; // Prevent division by zero

    m = ((n * sumXY) - (sumX * sumY)) / denominator;
    b = (sumY - (m! * sumX)) / n;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Linear Regression'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearPoints,
            tooltip: 'Clear Canvas',
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.black12,
            width: double.infinity,
            child: Column(
              children: [
                const Text(
                  'Tap on the canvas to add data points.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  m != null && b != null
                      ? 'Equation: y = ${m!.toStringAsFixed(2)}x + ${b!.toStringAsFixed(2)}'
                      : 'Add at least 2 points to see the line of best fit.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: m != null ? Colors.orangeAccent : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTapDown: _addPoint,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  border: Border.all(color: Colors.orangeAccent.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CustomPaint(
                    painter: RegressionPainter(points, m, b),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RegressionPainter extends CustomPainter {
  final List<Offset> points;
  final double? m;
  final double? b;

  RegressionPainter(this.points, this.m, this.b);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid lines for better visualization
    final gridPaint = Paint()
      ..color = Colors.white10
      ..strokeWidth = 1.0;
    
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    // Draw data points
    final pointPaint = Paint()
      ..color = Colors.tealAccent
      ..style = PaintingStyle.fill;

    final pointBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (var p in points) {
      canvas.drawCircle(p, 6.0, pointPaint);
      canvas.drawCircle(p, 6.0, pointBorderPaint);
    }

    // Draw regression line
    if (m != null && b != null && points.length >= 2) {
      final linePaint = Paint()
        ..color = Colors.orangeAccent
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      // Calculate start and end points of the line to span the canvas width
      double startX = 0;
      double startY = m! * startX + b!;
      
      double endX = size.width;
      double endY = m! * endX + b!;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant RegressionPainter oldDelegate) {
    return true; // Repaint whenever state changes
  }
}
