
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/history_provider.dart';
import '../../data/models/prediction.dart';
import '../../core/theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        context.read<HistoryProvider>().loadPredictions());
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<HistoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prediction History'),
        actions: [
          if (prov.predictions.isNotEmpty)
            TextButton(
              onPressed: () => _confirmClearAll(context),
              child: const Text('Clear All', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: prov.isLoading
          ? const Center(child: CircularProgressIndicator())
          : prov.predictions.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No predictions yet.',
                          style: TextStyle(color: Colors.grey, fontSize: 16)),
                      SizedBox(height: 8),
                      Text('Scan a leaf to get started.',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: prov.predictions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final p = prov.predictions[index];
                    return _PredictionTile(
                      prediction: p,
                      onDelete: () => _confirmDelete(context, p),
                    );
                  },
                ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Prediction p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete prediction?'),
        content: Text('Remove "${p.diseaseName}" from history?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true && mounted) {
      await context.read<HistoryProvider>().deletePrediction(p.id);
    }
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear all predictions?'),
        content: const Text('This will permanently delete your entire history.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await context.read<HistoryProvider>().clearAll();
    }
  }
}

class _PredictionTile extends StatelessWidget {
  final Prediction prediction;
  final VoidCallback onDelete;

  const _PredictionTile({required this.prediction, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.confidenceColor(prediction.confidence);
    return Dismissible(
      key: Key(prediction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
            color: Colors.red, borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: prediction.imagePath.isNotEmpty
                ? Image.file(File(prediction.imagePath),
                    width: 52, height: 52, fit: BoxFit.cover)
                : Container(width: 52, height: 52,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, color: Colors.grey)),
          ),
          title: Text(prediction.diseaseName,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(prediction.getFormattedDate(),
              style: const TextStyle(fontSize: 12)),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha:0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${prediction.getConfidencePercentage()}%',
              style: TextStyle(color: color, fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ),
          onTap: () => _showDetail(context),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(prediction.diseaseName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Date: ${prediction.getFormattedDate()}'),
            Text('Confidence: ${prediction.getConfidencePercentage()}%'),
            Text('Model: v${prediction.modelVersion}'),
            Text('ID: ${prediction.id}',
                style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
