import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../providers/prediction_provider.dart';


class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detection Result'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            context.read<PredictionProvider>().reset();
            Navigator.pop(context);
          },
        ),
      ),
      body: Consumer<PredictionProvider>(
        builder: (context, provider, child) {
          final prediction = provider.currentPrediction;
          final diseaseInfo = provider.currentDiseaseInfo;
          final imagePath = provider.selectedImage?.path;

          if (prediction == null) {
            return const Center(child: Text('No prediction available'));
          }

          final confidenceColor = AppColors.getConfidenceColor(prediction.confidence);
          final confidenceLabel = AppColors.getConfidenceLabel(prediction.confidence);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (imagePath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(imagePath),
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                  ),

                const SizedBox(height: 24),

                Text(
                  prediction.diseaseName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                Card(
                  color: confidenceColor.withValues(alpha:0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getConfidenceIcon(prediction.confidence),
                              color: confidenceColor,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Confidence: ${prediction.getConfidencePercentage()}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: confidenceColor,
                                  ),
                                ),
                                Text(
                                  '$confidenceLabel Confidence',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: confidenceColor.withValues(alpha:0.8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                if (diseaseInfo != null) ...[
                  _buildExpandableSection(
                    title: 'Disease Details',
                    icon: Icons.info_outline,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Symptoms', diseaseInfo.symptoms),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          'Severity',
                          diseaseInfo.severityLevel.displayName,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          'Affected Crops',
                          diseaseInfo.affectedCrops.join(', '),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  _buildExpandableSection(
                    title: 'Treatment Options',
                    icon: Icons.healing,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (diseaseInfo.getTreatmentOptions().hasCulturalControl)
                          _buildTreatmentSection(
                            'Cultural Control',
                            diseaseInfo.culturalControl!,
                          ),
                        if (diseaseInfo.getTreatmentOptions().hasChemicalControl) ...[
                          const SizedBox(height: 12),
                          _buildTreatmentSection(
                            'Chemical Control',
                            diseaseInfo.chemicalControl!,
                          ),
                        ],
                        if (diseaseInfo.getTreatmentOptions().hasBiologicalControl) ...[
                          const SizedBox(height: 12),
                          _buildTreatmentSection(
                            'Biological Control',
                            diseaseInfo.biologicalControl!,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.read<PredictionProvider>().reset();
                          Navigator.pushReplacementNamed(context, Routes.home);
                        },
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Try Another'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, Routes.history);
                        },
                        icon: const Icon(Icons.history),
                        label: const Text('View History'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    return Card(
      child: ExpansionTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildTreatmentSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  IconData _getConfidenceIcon(double confidence) {
    if (confidence >= 0.85) return Icons.check_circle;
    if (confidence >= 0.60) return Icons.warning;
    return Icons.error;
  }
}