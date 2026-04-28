import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/route_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/settings_provider.dart';
import '../../services/translation/translation_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<TranslationService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Consumer<SettingsProvider>(
                builder: (context, provider, _) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    children: [
                      _buildSectionLabel('app_information'.tr),
                      _buildCard([
                        _buildInfoTile(
                          icon: Icons.info_outline_rounded,
                          title: 'version'.tr,
                          subtitle: '1.0.0',
                        ),
                        _buildDivider(),
                        _buildModelTile(context, provider),
                      ]),

                      if (provider.modelUpdateState == ModelUpdateState.upToDate)
                        _buildStatusBanner(
                          message: 'model_up_to_date'.tr,
                          color: AppColors.success,
                          icon: Icons.check_circle_rounded,
                        ),
                      if (provider.modelUpdateState == ModelUpdateState.error &&
                          provider.modelUpdateError != null)
                        _buildStatusBanner(
                          message: provider.modelUpdateError!,
                          color: AppColors.error,
                          icon: Icons.error_outline_rounded,
                        ),

                      const SizedBox(height: 20),
                      _buildSectionLabel('preferences'.tr),
                      _buildCard([
                        _buildNavTile(
                          icon: Icons.language_rounded,
                          iconColor: const Color(0xFF2979FF),
                          title: 'language'.tr,
                          subtitle: provider.languageDisplayName,
                          onTap: () => _showLanguageDialog(context, provider),
                        ),
                        _buildDivider(),
                        _buildNavTile(
                          icon: Icons.analytics_rounded,
                          iconColor: const Color(0xFF9C27B0),
                          title: 'confidence_threshold'.tr,
                          subtitle:
                          '${(provider.confidenceThreshold * 100).toInt()}%',
                          onTap: () => _showThresholdDialog(context, provider),
                        ),
                      ]),

                      const SizedBox(height: 20),
                      _buildSectionLabel('data_storage'.tr),
                      _buildCard([
                        _buildNavTile(
                          icon: Icons.cleaning_services_rounded,
                          iconColor: AppColors.warning,
                          title: 'clear_cache'.tr,
                          subtitle: 'free_up_space'.tr,
                          onTap: () =>
                              _showClearCacheDialog(context, provider),
                        ),
                      ]),

                      const SizedBox(height: 20),
                      _buildSectionLabel('about'.tr),
                      _buildCard([
                        _buildNavTile(
                          icon: Icons.help_outline_rounded,
                          iconColor: AppColors.info,
                          title: 'help_faq'.tr,
                          onTap: () =>
                              Navigator.pushNamed(context, Routes.helpAndFaq),
                        ),
                      ]),

                      const SizedBox(height: 32),
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.eco_rounded,
                                  color: Colors.white, size: 26),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'app_name'.tr,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'built_with'.tr,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.primary, size: 20),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            'settings'.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textHint,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 56, endIndent: 0);
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _iconBox(icon, AppColors.textSecondary),
      title: Text(title,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary)),
      subtitle: Text(subtitle,
          style:
          const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required String title,
    Color iconColor = AppColors.primary,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _iconBox(icon, iconColor),
      title: Text(title,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary)),
      subtitle: subtitle != null
          ? Text(subtitle,
          style: const TextStyle(
              fontSize: 13, color: AppColors.textSecondary))
          : null,
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppColors.textHint, size: 22),
      onTap: onTap,
    );
  }

  Widget _buildModelTile(BuildContext context, SettingsProvider provider) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _iconBox(Icons.model_training_rounded, AppColors.success),
      title: Text('model_version'.tr,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary)),
      subtitle: Text(provider.modelVersion,
          style:
          const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      trailing: _buildModelUpdateTrailing(provider),
      onTap: provider.modelUpdateState == ModelUpdateState.checking ||
          provider.modelUpdateState == ModelUpdateState.downloading
          ? null
          : () => provider.checkForModelUpdate(),
    );
  }

  Widget _buildModelUpdateTrailing(SettingsProvider provider) {
    switch (provider.modelUpdateState) {
      case ModelUpdateState.checking:
      case ModelUpdateState.downloading:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            if (provider.modelUpdateState == ModelUpdateState.downloading) ...[
              const SizedBox(width: 6),
              Text('downloading'.tr,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textHint)),
            ],
          ],
        );
      case ModelUpdateState.upToDate:
        return const Icon(Icons.check_circle_rounded,
            color: AppColors.success, size: 20);
      case ModelUpdateState.error:
        return const Icon(Icons.error_outline_rounded,
            color: AppColors.error, size: 20);
      default:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primaryMuted,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'check_updates'.tr,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        );
    }
  }

  Widget _buildStatusBanner({
    required String message,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
              child: Text(message,
                  style: TextStyle(
                      fontSize: 13,
                      color: color,
                      fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }


  void _showLanguageDialog(BuildContext context, SettingsProvider provider) {
    String selected = provider.language;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text('language'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _langOption('English', 'en', selected, (v) {
                setState(() => selected = v!);
              }),
              _langOption('বাংলা (Bengali)', 'bn', selected, (v) {
                setState(() => selected = v!);
              }),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: Text('cancel'.tr)),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogCtx);
                final success = await provider.setLanguage(selected);
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('language_changed'.tr),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                }
              },
              child: Text('confirm'.tr),
            ),
          ],
        ),
      ),
    );
  }

  Widget _langOption(String label, String value, String groupValue,
      ValueChanged<String?> onChanged) {
    return RadioListTile<String>(
      title: Text(label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      value: value,
      groupValue: groupValue,
      activeColor: AppColors.primary,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showThresholdDialog(BuildContext context, SettingsProvider provider) {
    double temp = provider.confidenceThreshold;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text('confidence_threshold'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(temp * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Slider(
                value: temp,
                min: 0.5,
                max: 0.95,
                divisions: 9,
                activeColor: AppColors.primary,
                label: '${(temp * 100).toInt()}%',
                onChanged: (v) => setState(() => temp = v),
              ),
              const SizedBox(height: 8),
              Text(
                'Higher threshold = more accurate but fewer detections',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: Text('cancel'.tr)),
            ElevatedButton(
              onPressed: () async {
                await provider.setConfidenceThreshold(temp);
                if (dialogCtx.mounted) {
                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(dialogCtx).showSnackBar(
                    SnackBar(
                      content: Text('threshold_updated'.tr),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                }
              },
              child: Text('save'.tr),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('clear_cache'.tr),
        content: Text('clear_cache_warning'.tr),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await provider.clearCache();
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                  content: Text(
                      success ? 'cache_cleared'.tr : 'cache_clear_failed'.tr),
                  backgroundColor:
                  success ? AppColors.success : AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                ));
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white),
            child: Text('clear'.tr),
          ),
        ],
      ),
    );
  }
}