import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../core/theme/app_colors.dart';
import '../../core/constants/route_constants.dart';
import '../../providers/prediction_provider.dart';
import '../../controllers/feedback_controller.dart';
import '../../data/database/daos/feedback_dao.dart';
import '../../data/models/feedback.dart';
import '../../core/errors/error_handler.dart';
import '../../data/database/daos/error_logs_dao.dart';
import '../../services/translation/translation_service.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withValues(alpha: 0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<PredictionProvider>(
            builder: (context, provider, child) {
              final prediction = provider.currentPrediction;
              final diseaseInfo = provider.currentDiseaseInfo;
              final imagePath = provider.selectedImage?.path;

              if (prediction == null) {
                return const Center(child: Text('No prediction available'));
              }

              final confidenceColor =
              AppColors.getConfidenceColor(prediction.confidence);
              final confidenceLabel =
              AppColors.getConfidenceLabel(prediction.confidence);

              return CustomScrollView(
                slivers: [
                  // Custom App Bar
                  SliverAppBar(
                    expandedHeight: 60,
                    floating: false,
                    pinned: true,
                    backgroundColor: Colors.white,
                    elevation: 0,
                    leading: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: AppColors.primary),
                        onPressed: () {
                          context.read<PredictionProvider>().reset();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    title: Text(
                      'detection_result'.tr,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Content
                  SliverList(
                    delegate: SliverChildListDelegate([
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Image Card
                                if (imagePath != null)
                                  Hero(
                                    tag: 'plant_image',
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.2),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                        BorderRadius.circular(20),
                                        child: Image.file(
                                          File(imagePath),
                                          height: 300,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),

                                const SizedBox(height: 24),

                                // Disease Name Card
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColors.primary
                                            .withValues(alpha: 0.1),
                                        AppColors.secondary
                                            .withValues(alpha: 0.05),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Icons.bug_report,
                                        size: 40,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        prediction.diseaseName,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Confidence Card
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color:
                                    confidenceColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: confidenceColor
                                          .withValues(alpha: 0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: confidenceColor
                                              .withValues(alpha: 0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          _getConfidenceIcon(
                                              prediction.confidence),
                                          color: confidenceColor,
                                          size: 32,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              prediction
                                                  .getConfidencePercentage(),
                                              style: TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                                color: confidenceColor,
                                              ),
                                            ),
                                            Text(
                                              '$confidenceLabel ${'confidence'.tr}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: confidenceColor,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Progress indicator
                                      SizedBox(
                                        width: 60,
                                        height: 60,
                                        child: Stack(
                                          children: [
                                            Center(
                                              child: SizedBox(
                                                width: 60,
                                                height: 60,
                                                child:
                                                CircularProgressIndicator(
                                                  value:
                                                  prediction.confidence,
                                                  strokeWidth: 6,
                                                  backgroundColor:
                                                  confidenceColor
                                                      .withValues(
                                                      alpha: 0.2),
                                                  valueColor:
                                                  AlwaysStoppedAnimation<
                                                      Color>(
                                                      confidenceColor),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                if (diseaseInfo != null) ...[
                                  // Disease Details
                                  _buildExpandableSection(
                                    title: 'disease_details'.tr,
                                    icon: Icons.info_outline,
                                    color: Colors.blue,
                                    content: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        _buildDetailCard(
                                          icon: Icons.medical_services,
                                          label: 'symptoms'.tr,
                                          value: diseaseInfo.symptoms,
                                        ),
                                        const SizedBox(height: 12),
                                        _buildDetailCard(
                                          icon: Icons.warning_amber,
                                          label: 'severity'.tr,
                                          value: diseaseInfo.severityLevel
                                              .displayName,
                                        ),
                                        const SizedBox(height: 12),
                                        _buildDetailCard(
                                          icon: Icons.grass,
                                          label: 'affected_crops'.tr,
                                          value: diseaseInfo.affectedCrops
                                              .join(', '),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Treatment Options
                                  _buildExpandableSection(
                                    title: 'treatment_options'.tr,
                                    icon: Icons.healing,
                                    color: Colors.green,
                                    content: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        if (diseaseInfo
                                            .getTreatmentOptions()
                                            .hasCulturalControl)
                                          _buildTreatmentCard(
                                            icon: Icons.nature_people,
                                            title: 'cultural_control'.tr,
                                            content:
                                            diseaseInfo.culturalControl!,
                                            color: Colors.brown,
                                          ),
                                        if (diseaseInfo
                                            .getTreatmentOptions()
                                            .hasChemicalControl) ...[
                                          const SizedBox(height: 12),
                                          _buildTreatmentCard(
                                            icon: Icons.science,
                                            title: 'chemical_control'.tr,
                                            content:
                                            diseaseInfo.chemicalControl!,
                                            color: Colors.orange,
                                          ),
                                        ],
                                        if (diseaseInfo
                                            .getTreatmentOptions()
                                            .hasBiologicalControl) ...[
                                          const SizedBox(height: 12),
                                          _buildTreatmentCard(
                                            icon: Icons.eco,
                                            title: 'biological_control'.tr,
                                            content:
                                            diseaseInfo.biologicalControl!,
                                            color: Colors.green,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 16),

                                // Feedback Section
                                _buildFeedbackSection(context, prediction.id),

                                const SizedBox(height: 16),

                                // Action Buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          context
                                              .read<PredictionProvider>()
                                              .reset();
                                          Navigator.pushReplacementNamed(
                                              context, Routes.home);
                                        },
                                        icon: const Icon(Icons.camera_alt),
                                        label: Text('try_another'.tr),
                                        style: OutlinedButton.styleFrom(
                                          padding:
                                          const EdgeInsets.symmetric(
                                              vertical: 16),
                                          side: const BorderSide(
                                              color: AppColors.primary,
                                              width: 2),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              context, Routes.history);
                                        },
                                        icon: const Icon(Icons.history),
                                        label: Text('history'.tr),
                                        style: ElevatedButton.styleFrom(
                                          padding:
                                          const EdgeInsets.symmetric(
                                              vertical: 16),
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                // Disclaimer
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'disclaimer'.tr,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required Color color,
    required Widget content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.all(16),
          children: [content],
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection(BuildContext context, String predictionId) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.feedback_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'feedback_title'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildFeedbackButton(
                context: context,
                icon: Icons.thumb_up,
                label: 'feedback_correct'.tr,
                value: UserFeedback.correct,
                predictionId: predictionId,
              ),
              const SizedBox(width: 12),
              _buildFeedbackButton(
                context: context,
                icon: Icons.thumb_down,
                label: 'feedback_incorrect'.tr,
                value: UserFeedback.incorrect,
                predictionId: predictionId,
              ),
              const SizedBox(width: 12),
              _buildFeedbackButton(
                context: context,
                icon: Icons.help_outline,
                label: 'feedback_unsure'.tr,
                value: UserFeedback.unsure,
                predictionId: predictionId,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required UserFeedback value,
    required String predictionId,
  }) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () => _showFeedbackDialog(context, predictionId, value),
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showFeedbackDialog(
      BuildContext context,
      String predictionId,
      UserFeedback userFeedback,
      ) {
    final TextEditingController diseaseController = TextEditingController();
    final TextEditingController commentController = TextEditingController();

    final feedbackController = FeedbackController(
      feedbackDao: FeedbackDao(),
      errorHandler: ErrorHandler(ErrorLogsDao()),
    );

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  userFeedback == UserFeedback.correct
                      ? Icons.thumb_up
                      : userFeedback == UserFeedback.incorrect
                      ? Icons.thumb_down
                      : Icons.help_outline,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(userFeedback.displayName),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (userFeedback == UserFeedback.incorrect) ...[
                    TextField(
                      controller: diseaseController,
                      decoration: InputDecoration(
                        labelText: 'correct_disease_name'.tr,
                        hintText: 'e.g., Tomato Early Blight',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      labelText: 'comments_optional'.tr,
                      hintText: 'Your feedback helps us improve...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text('cancel'.tr),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);

                  final result = await feedbackController.submitFeedback(
                    predictionId: predictionId,
                    userFeedback: userFeedback,
                    correctDiseaseName: diseaseController.text.isNotEmpty
                        ? diseaseController.text
                        : null,
                    comments: commentController.text.isNotEmpty
                        ? commentController.text
                        : null,
                  );

                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content: Text(
                          result.success
                              ? 'Thank you for your feedback!'
                              : result.errorMessage ??
                              'Failed to submit feedback',
                        ),
                        backgroundColor:
                        result.success ? Colors.green : Colors.red,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Text('submit_feedback'.tr),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _getConfidenceIcon(double confidence) {
    if (confidence >= 0.85) return Icons.check_circle;
    if (confidence >= 0.60) return Icons.warning_amber;
    return Icons.error_outline;
  }
}