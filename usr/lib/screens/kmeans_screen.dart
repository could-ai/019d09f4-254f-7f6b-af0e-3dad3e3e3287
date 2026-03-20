import 'package:flutter/material.dart';
import 'dart:math';

class KMeansScreen extends StatefulWidget {
  const KMeansScreen({super.key});

  @override
  State<KMeansScreen> createState() => _KMeansScreenState();
}

class _KMeansScreenState extends State<KMeansScreen> {
  List<Offset> points = [];
  List<Offset> centroids = [];
  List<int> assignments = [];
  int k = 3;
  bool isInitialized = false;
  int iteration = 0;

  final List<Color> clusterColors = [
    Colors.redAccent,
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
  ];

  void _addPoint(TapDownDetails details) {
    setState(() {
      points.add(details.localPosition);
      if (isInitialized) {
        // If already initialized, assign the new point to the nearest centroid
        _assignPointsToCentroids();
      } else {
        assignments.add(-1); // Unassigned
      }
    });
  }

  void _clear() {
    setState(() {
      points.clear();
      centroids.clear();
      assignments.clear();
      isInitialized = false;
      iteration = 0;
    });
  }

  void _initializeCentroids() {
    if (points.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add some points first!')),
      );
      return;
    }
    
    setState(() {
      centroids.clear();
      final random = Random();
      
      // Randomly pick k distinct points as initial centroids (Forgy method)
      List<Offset> shuffledPoints = List.from(points)..shuffle(random);
      for (int i = 0; i < min(k, points.length); i++) {
        centroids.add(shuffledPoints[i]);
      }
      
      isInitialized = true;
      iteration = 1;
      _assignPointsToCentroids();
    });
  }

  void _assignPointsToCentroids() {
    assignments.clear();
    for (var p in points) {
      int bestCluster = -1;
      double minDistance = double.infinity;

      for (int i = 0; i < centroids.length; i++) {
        double dist = (p - centroids[i]).distance;
        if (dist < minDistance) {
          minDistance = dist;
          bestCluster = i;
        }
      }
      assignments.add(bestCluster);
    }
  }

  void _updateCentroids() {
    if (!isInitialized) return;
    
    setState(() {
      List<Offset> newCentroids = List.filled(centroids.length, Offset.zero);
      List<int> counts = List.filled(centroids.length, 0);

      // Sum up all points assigned to each centroid
      for (int i = 0; i < points.length; i++) {
        int cluster = assignments[i];
        if (cluster != -1) {
          newCentroids[cluster] += points[i];
          counts[cluster]++;
        }
      }

      // Calculate the mean (new centroid position)
      bool changed = false;
      for (int i = 0; i < centroids.length; i++) {
        if (counts[i] > 0) {
          Offset newPos = Offset(
            newCentroids[i].dx / counts[i],
            newCentroids[i].dy / counts[i],
          );
          
          // Check if centroid actually moved
          if ((centroids[i] - newPos).distance > 0.1) {
            changed = true;
            centroids[i] = newPos;
          }
        }
      }
      
      if (changed) {
        iteration++;
        _assignPointsToCentroids();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Converged! Centroids did not move.')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('K-Means Clustering'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clear,
            tooltip: 'Clear Canvas',
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            color: Colors.black12,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        const Text('Clusters (K): '),
                        DropdownButton<int>(
                          value: k,
                          dropdownColor: const Color(0xFF2C2C2C),
                          items: [2, 3, 4, 5].map((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(value.toString()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              k = value!;
                              _clear();
                            });
                          },
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: isInitialized ? null : _initializeCentroids,
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: const Text('Initialize'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent.withOpacity(0.2),
                        foregroundColor: Colors.purpleAccent,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: isInitialized ? _updateCentroids : null,
                      icon: const Icon(Icons.skip_next, size: 18),
                      label: const Text('Step'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent.withOpacity(0.2),
                        foregroundColor: Colors.tealAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isInitialized 
                      ? 'Iteration: $iteration | Tap "Step" to move centroids'
                      : 'Tap canvas to add points, then tap "Initialize"',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
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
                  border: Border.all(color: Colors.purpleAccent.withOpacity(0.5)),
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
                    painter: KMeansPainter(points, centroids, assignments, clusterColors),
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

class KMeansPainter extends CustomPainter {
  final List<Offset> points;
  final List<Offset> centroids;
  final List<int> assignments;
  final List<Color> colors;

  KMeansPainter(this.points, this.centroids, this.assignments, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.white10
      ..strokeWidth = 1.0;
    
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    // Draw lines from points to their assigned centroids
    if (centroids.isNotEmpty && assignments.length == points.length) {
      for (int i = 0; i < points.length; i++) {
        if (assignments[i] != -1) {
          final linePaint = Paint()
            ..color = colors[assignments[i] % colors.length].withOpacity(0.3)
            ..strokeWidth = 1.0
            ..style = PaintingStyle.stroke;
          
          canvas.drawLine(points[i], centroids[assignments[i]], linePaint);
        }
      }
    }

    // Draw points
    for (int i = 0; i < points.length; i++) {
      final isAssigned = assignments.isNotEmpty && i < assignments.length && assignments[i] != -1;
      
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = isAssigned ? colors[assignments[i] % colors.length] : Colors.grey;
        
      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.white
        ..strokeWidth = 1.0;

      canvas.drawCircle(points[i], 6.0, paint);
      canvas.drawCircle(points[i], 6.0, borderPaint);
    }

    // Draw centroids
    for (int i = 0; i < centroids.length; i++) {
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = colors[i % colors.length];
      
      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.white
        ..strokeWidth = 2.0;

      // Draw a larger circle for centroid
      canvas.drawCircle(centroids[i], 12.0, paint);
      canvas.drawCircle(centroids[i], 12.0, borderPaint);
      
      // Draw crosshair inside centroid
      canvas.drawLine(
        Offset(centroids[i].dx - 8, centroids[i].dy),
        Offset(centroids[i].dx + 8, centroids[i].dy),
        borderPaint,
      );
      canvas.drawLine(
        Offset(centroids[i].dx, centroids[i].dy - 8),
        Offset(centroids[i].dx, centroids[i].dy + 8),
        borderPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant KMeansPainter oldDelegate) {
    return true;
  }
}
