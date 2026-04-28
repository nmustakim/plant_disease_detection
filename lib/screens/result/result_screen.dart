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
        duration: const Duration(milliseconds: 700), vsync: this);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
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
      backgroundColor: AppColors.background,
      body: Consumer<PredictionProvider>(
        builder: (context, provider, _) {
          final prediction = provider.currentPrediction;
          final diseaseInfo = provider.currentDiseaseInfo;
          final imagePath = provider.selectedImage?.path;

          if (prediction == null) {
            return const Center(
              child: Text('No prediction available',
                  style: TextStyle(color: AppColors.textSecondary)),
            );
          }

          final confidenceColor =
          AppColors.getConfidenceColor(prediction.confidence);

          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 320,
                    pinned: true,
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    leading: Padding(
                      padding: const EdgeInsets.all(8),
                      child: _CircleIconButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () {
                          context.read<PredictionProvider>().reset();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    title: Text(
                      StringTranslation('detection_result').tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                    flexibleSpace: imagePath != null
                        ? FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Hero(
                            tag: 'plant_image',
                            child: Image.file(
                              File(imagePath),
                              fit: BoxFit.cover,
                            ),
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.3),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.5),
                                ],
                                stops: const [0.0, 0.4, 1.0],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                        : null,
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Transform.translate(
                            offset: const Offset(0, -22),
                            child: _buildDiseaseNameCard(
                                prediction.diseaseName, confidenceColor),
                          ),

                          _buildConfidenceCard(prediction, confidenceColor),

                          const SizedBox(height: 16),

                          if (diseaseInfo != null) ...[
                            _buildSectionCard(
                              title: StringTranslation('disease_details').tr,
                              icon: Icons.local_hospital_rounded,
                              accentColor: const Color(0xFF2979FF),
                              children: [
                                _buildInfoRow(
                                  icon: Icons.medical_services_rounded,
                                  label: StringTranslation('symptoms').tr,
                                  value: diseaseInfo.symptoms,
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  icon: Icons.warning_amber_rounded,
                                  label: StringTranslation('severity').tr,
                                  value: diseaseInfo.severityLevel.displayName,
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  icon: Icons.grass_rounded,
                                  label: StringTranslation('affected_crops').tr,
                                  value: diseaseInfo.affectedCrops.join(', '),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            _buildTreatmentSection(diseaseInfo),

                            const SizedBox(height: 16),
                          ],

                          // Feedback
                          _buildFeedbackCard(context, prediction.id),

                          const SizedBox(height: 16),

                          // Action buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    context.read<PredictionProvider>().reset();
                                    Navigator.pushReplacementNamed(
                                        context, Routes.home);
                                  },
                                  icon: const Icon(
                                      Icons.document_scanner_rounded,
                                      size: 18),
                                  label: Text(StringTranslation('try_another').tr),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => Navigator.pushNamed(
                                      context, Routes.history),
                                  icon: const Icon(Icons.history_rounded,
                                      size: 18),
                                  label: Text(StringTranslation('history').tr),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color:
                                  AppColors.warning.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.warning_amber_rounded,
                                    color: AppColors.warning, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    StringTranslation('disclaimer').tr,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.warning
                                          .withValues(alpha: 0.9),
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDiseaseNameCard(String name, Color confidenceColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.eco_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  StringTranslation('detected_disease').tr,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textHint,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceCard(prediction, Color confidenceColor) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: confidenceColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: confidenceColor.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 68,
            height: 68,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: prediction.confidence,
                  constraints: BoxConstraints(
                    minHeight: 80,minWidth: 80
                  ),
                  strokeWidth: 6,
                  backgroundColor: confidenceColor.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(confidenceColor),
                  strokeCap: StrokeCap.round,
                ),
                Text(
                  prediction.getConfidencePercentage(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: confidenceColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppColors.getConfidenceLabel(prediction.confidence),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: confidenceColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  StringTranslation('confidence').tr,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: prediction.confidence,
                    minHeight: 6,
                    backgroundColor: confidenceColor.withValues(alpha: 0.15),
                    valueColor:
                    AlwaysStoppedAnimation<Color>(confidenceColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color accentColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          tilePadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primaryMuted,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textHint,
                    letterSpacing: 0.6,
                  )),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.45,
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTreatmentSection(diseaseInfo) {
    final options = diseaseInfo.getTreatmentOptions();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.healing_rounded,
                color: AppColors.success, size: 20),
          ),
          title: Text(
            StringTranslation('treatment_options').tr,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          tilePadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            if (options.hasCulturalControl)
              _buildTreatmentChip(
                icon: Icons.nature_people_rounded,
                label: StringTranslation('cultural_control').tr,
                content: diseaseInfo.culturalControl!,
                color: const Color(0xFF795548),
              ),
            if (options.hasChemicalControl) ...[
              const SizedBox(height: 10),
              _buildTreatmentChip(
                icon: Icons.science_rounded,
                label: StringTranslation('chemical_control').tr,
                content: diseaseInfo.chemicalControl!,
                color: const Color(0xFFE65100),
              ),
            ],
            if (options.hasBiologicalControl) ...[
              const SizedBox(height: 10),
              _buildTreatmentChip(
                icon: Icons.eco_rounded,
                label: StringTranslation('biological_control').tr,
                content: diseaseInfo.biologicalControl!,
                color: AppColors.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentChip({
    required IconData icon,
    required String label,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  )),
            ],
          ),
          const SizedBox(height: 8),
          Text(content,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              )),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(BuildContext context, String predictionId) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primaryMuted,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.feedback_rounded,
                    color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                StringTranslation('feedback_title').tr,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _FeedbackChip(
                icon: Icons.thumb_up_rounded,
                label: StringTranslation('feedback_correct').tr,
                color: AppColors.success,
                onTap: () => _showFeedbackDialog(
                    context, predictionId, UserFeedback.correct),
              ),
              const SizedBox(width: 8),
              _FeedbackChip(
                icon: Icons.thumb_down_rounded,
                label: StringTranslation('feedback_incorrect').tr,
                color: AppColors.error,
                onTap: () => _showFeedbackDialog(
                    context, predictionId, UserFeedback.incorrect),
              ),
              const SizedBox(width: 8),
              _FeedbackChip(
                icon: Icons.help_rounded,
                label: StringTranslation('feedback_unsure').tr,
                color: AppColors.warning,
                onTap: () => _showFeedbackDialog(
                    context, predictionId, UserFeedback.unsure),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(
      BuildContext context, String predictionId, UserFeedback userFeedback) {
    final diseaseController = TextEditingController();
    final commentController = TextEditingController();
    final feedbackController = FeedbackController(
      feedbackDao: FeedbackDao(),
      errorHandler: ErrorHandler(ErrorLogsDao()),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius:
              BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  userFeedback.displayName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                if (userFeedback == UserFeedback.incorrect) ...[
                  TextField(
                    controller: diseaseController,
                    decoration: InputDecoration(
                      labelText: StringTranslation('correct_disease_name').tr,
                      hintText: 'e.g., Tomato Early Blight',
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                    labelText: StringTranslation('comments_optional').tr,
                    hintText: 'Your feedback helps us improve...',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(sheetCtx);
                    final result = await feedbackController.submitFeedback(
                      predictionId: predictionId,
                      userFeedback: userFeedback,
                      correctDiseaseName:
                      diseaseController.text.isNotEmpty
                          ? diseaseController.text
                          : null,
                      comments: commentController.text.isNotEmpty
                          ? commentController.text
                          : null,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            result.success
                                ? StringTranslation('feedback_thanks').tr
                                : result.errorMessage ??
                                StringTranslation('error').tr,
                          ),
                          backgroundColor: result.success
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      );
                    }
                  },
                  child: Text(StringTranslation('submit_feedback').tr),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _FeedbackChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _FeedbackChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

