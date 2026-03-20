import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ML Algorithms Visualizer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select an Algorithm',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildAlgoCard(
                    context,
                    'Linear Regression',
                    'Finds the line of best fit for a set of data points.',
                    Icons.show_chart,
                    '/linear_regression',
                    Colors.orangeAccent,
                  ),
                  _buildAlgoCard(
                    context,
                    'K-Means Clustering',
                    'Groups data points into K distinct clusters.',
                    Icons.bubble_chart,
                    '/kmeans',
                    Colors.purpleAccent,
                  ),
                  // Placeholders for future algorithms
                  _buildAlgoCard(
                    context,
                    'KNN Classification',
                    'Coming soon...',
                    Icons.scatter_plot,
                    null,
                    Colors.grey,
                  ),
                  _buildAlgoCard(
                    context,
                    'Decision Trees',
                    'Coming soon...',
                    Icons.account_tree,
                    null,
                    Colors.grey,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlgoCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    String? route,
    Color color,
  ) {
    final isEnabled = route != null;

    return InkWell(
      onTap: isEnabled ? () => Navigator.pushNamed(context, route) : null,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: isEnabled ? 4 : 1,
        color: isEnabled ? Theme.of(context).cardColor : Colors.white10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isEnabled ? color.withOpacity(0.5) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isEnabled ? Colors.white : Colors.white54,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: isEnabled ? Colors.white70 : Colors.white38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
