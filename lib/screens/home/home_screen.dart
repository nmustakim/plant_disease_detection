import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../providers/prediction_provider.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Disease Detector'
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, Routes.settings);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.eco,
                size: 120,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),
              const Text(
                'Detect Plant Diseases',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Take a photo or upload an image of a plant leaf to identify diseases',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 48),

              Consumer<PredictionProvider>(
                builder: (context, provider, child) {
                  return ElevatedButton.icon(
                    onPressed: provider.isLoading
                        ? null
                        : () => _scanLeaf(context, provider),
                    icon: provider.isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.camera_alt, size: 28),
                    label: Text(
                      provider.isLoading ? 'Processing...' : 'Scan Leaf',
                      style: const TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              Consumer<PredictionProvider>(
                builder: (context, provider, child) {
                  return OutlinedButton.icon(
                    onPressed: provider.isLoading
                        ? null
                        : () => _uploadImage(context, provider),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Upload from Gallery'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, Routes.history);
                },
                icon: const Icon(Icons.history),
                label: const Text('View History'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _scanLeaf(BuildContext context, PredictionProvider provider) async {
    await provider.captureAndClassify();

    if (provider.hasResult && context.mounted) {
      Navigator.pushNamed(context, Routes.result);
    } else if (provider.hasError&& context.mounted) {
      _showErrorDialog(context, provider.errorMessage ?? 'Failed to scan leaf');
    }
  }

  Future<void> _uploadImage(BuildContext context, PredictionProvider provider) async {
    await provider.uploadAndClassify();

    if (provider.hasResult&& context.mounted) {
      Navigator.pushNamed(context, Routes.result);
    } else if (provider.hasError&& context.mounted) {
      _showErrorDialog(context, provider.errorMessage ?? 'Failed to upload image');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}