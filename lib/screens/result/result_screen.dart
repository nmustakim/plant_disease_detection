import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/prediction_provider.dart';
import '../../providers/feedback_provider.dart';
import '../../data/models/feedback.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/route_constants.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov   = context.watch<PredictionProvider>();
    final result = prov.latestResult;

    if (result == null) {
      return const Scaffold(
        body: Center(child: Text('No result available.')),
      );
    }

    final prediction  = result.prediction;
    final diseaseInfo = result.diseaseInfo;
    final confColor   = AppTheme.confidenceColor(prediction.confidence);
    final confPct     = prediction.getConfidencePercentage();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Result'),
        leading: BackButton(onPressed: () =>
            Navigator.pushReplacementNamed(context, Routes.home)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(File(prediction.imagePath),
                  height: 200, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(prediction.diseaseName,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20))),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Text('Confidence: ', style: TextStyle(fontSize: 13)),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: prediction.confidence,
                            color: confColor,
                            backgroundColor: Colors.grey[200],
                            minHeight: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('$confPct%',
                          style: TextStyle(color: confColor,
                              fontWeight: FontWeight.bold)),
                    ]),
                    if (prediction.isUnknown)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          '⚠ Try a clearer photo in better lighting.',
                          style: TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            if (diseaseInfo != null)
              _AccordionTile(
                title: '🔬 Disease Details',
                children: [
                  Text('Severity: ${diseaseInfo.severityLevel}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  ...diseaseInfo.getSymptomsFormatted().map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text('• $s'),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Affects: ${diseaseInfo.getAffectedCropsList()}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),

            if (diseaseInfo != null)
              _AccordionTile(
                title: '💊 Treatment Options',
                children: diseaseInfo.getTreatmentOptions().map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: RichText(text: TextSpan(
                    style: const TextStyle(color: Colors.black87, fontSize: 13),
                    children: [
                      TextSpan(text: '${t['type']}: ',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: t['detail']),
                    ],
                  )),
                )).toList(),
              ),

            if (diseaseInfo != null && diseaseInfo.referenceLinks.isNotEmpty)
              TextButton(
                onPressed: () async {
                  final url = Uri.parse(diseaseInfo.referenceLinks.first);
                  if (await canLaunchUrl(url)) launchUrl(url);
                },
                child: const Text('📖 Learn More (FAO / USDA)'),
              ),

            const SizedBox(height: 16),

            Row(children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},  //already saved during inference
                  child: const Text('💾 Saved ✓'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<PredictionProvider>().reset();
                    Navigator.pushReplacementNamed(context, Routes.home);
                  },
                  child: const Text('🔁 Try Another'),
                ),
              ),
            ]),
            const SizedBox(height: 12),

            _FeedbackRow(predictionId: prediction.id),
          ],
        ),
      ),
    );
  }
}

class _AccordionTile extends StatelessWidget {
  final String         title;
  final List<Widget>   children;
  const _AccordionTile({required this.title, required this.children});

  @override
  Widget build(BuildContext context) => Card(
    child: ExpansionTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    ),
  );
}

class _FeedbackRow extends StatefulWidget {
  final String predictionId;
  const _FeedbackRow({required this.predictionId});

  @override
  State<_FeedbackRow> createState() => _FeedbackRowState();
}

class _FeedbackRowState extends State<_FeedbackRow> {
  FeedbackType? _selected;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text('Was this correct? '),
      for (final type in FeedbackType.values)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ChoiceChip(
            label: Text(type.name[0].toUpperCase() + type.name.substring(1)),
            selected: _selected == type,
            onSelected: (_) async {
              setState(() => _selected = type);
              final fb = FeedbackModel(
                predictionId: widget.predictionId,
                userFeedback: type,
                timestamp:    DateTime.now(),
              );
              await context.read<FeedbackProvider>().submitFeedback(fb);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Feedback submitted. Thank you!')));
              }
            },
          ),
        ),
    ],
  );
}
