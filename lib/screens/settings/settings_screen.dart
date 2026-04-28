import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/settings_provider.dart';
import '../../services/translation/translation_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('settings'.tr)),
      body: Consumer<SettingsProvider>(
        builder: (context, provider, child) {
          return ListView(
            children: [
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Text(
                  'app_information'.tr,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text('version'.tr),
                subtitle: const Text('1.0.0'),
              ),
              ListTile(
                leading: const Icon(Icons.model_training),
                title: Text('model_version'.tr),
                subtitle: Text(provider.modelVersion),
                trailing: _buildModelUpdateTrailing(context, provider),
                onTap: provider.modelUpdateState == ModelUpdateState.checking ||
                    provider.modelUpdateState == ModelUpdateState.downloading
                    ? null
                    : () => provider.checkForModelUpdate(),
              ),
              if (provider.modelUpdateState == ModelUpdateState.upToDate)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Model is up to date.',
                    style: TextStyle(fontSize: 12, color: Colors.green.shade700),
                  ),
                ),
              if (provider.modelUpdateState == ModelUpdateState.error &&
                  provider.modelUpdateError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    provider.modelUpdateError!,
                    style: const TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ),

              const Divider(),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Text(
                  'preferences'.tr,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.language),
                title: Text('language'.tr),
                subtitle: Text(provider.languageDisplayName),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showLanguageDialog(context, provider),
              ),

              ListTile(
                leading: const Icon(Icons.analytics),
                title: Text('confidence_threshold'.tr),
                subtitle: Text(
                  '${(provider.confidenceThreshold * 100).toInt()}%',
                ),
                trailing: const Icon(Icons.tune),
                onTap: () => _showThresholdDialog(context, provider),
              ),

              const Divider(),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Text(
                  'data_storage'.tr,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.cleaning_services),
                title: Text('clear_cache'.tr),
                subtitle: Text('free_up_space'.tr),
                onTap: () => _showClearCacheDialog(context, provider),
              ),

              const Divider(),

              // About Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Text(
                  'about'.tr,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: Text('help_faq'.tr),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate to help screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.star_outline),
                title: Text('rate_app'.tr),
                trailing: const Icon(Icons.open_in_new),
                onTap: () {
                  // TODO: Open app store
                },
              ),

              const SizedBox(height: 24),

              Center(
                child: Text(
                  'built_with'.tr,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildModelUpdateTrailing(BuildContext context, SettingsProvider provider) {
    switch (provider.modelUpdateState) {
      case ModelUpdateState.checking:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case ModelUpdateState.downloading:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 6),
            Text(
              'Downloading...',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        );
      case ModelUpdateState.upToDate:
        return const Icon(Icons.check_circle, color: Colors.green, size: 20);
      case ModelUpdateState.error:
        return const Icon(Icons.error_outline, color: Colors.red, size: 20);
      default:
        return TextButton(
          onPressed: () => provider.checkForModelUpdate(),
          child: const Text('Check for Updates'),
        );
    }
  }

  void _showLanguageDialog(BuildContext context, SettingsProvider provider) {
    String selectedLanguage = provider.language;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('language'.tr),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: const Text('English'),
                  value: 'en',
                  groupValue: selectedLanguage,
                  onChanged: (value) {
                    setState(() {
                      selectedLanguage = value!;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('বাংলা (Bengali)'),
                  value: 'bn',
                  groupValue: selectedLanguage,
                  onChanged: (value) {
                    setState(() {
                      selectedLanguage = value!;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text('cancel'.tr),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  final success = await provider.setLanguage(selectedLanguage);
                  if (success && context.mounted) {
                    _showRestartDialog(context);
                  }
                },
                child: Text('confirm'.tr),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showThresholdDialog(BuildContext context, SettingsProvider provider) {
    double tempValue = provider.confidenceThreshold;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('confidence_threshold'.tr),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${(tempValue * 100).toInt()}%'),
                Slider(
                  value: tempValue,
                  min: 0.5,
                  max: 0.95,
                  divisions: 9,
                  label: '${(tempValue * 100).toInt()}%',
                  onChanged: (value) {
                    setState(() {
                      tempValue = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Higher threshold = more accurate but fewer detections',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text('cancel'.tr),
              ),
              ElevatedButton(
                onPressed: () async {
                  await provider.setConfidenceThreshold(tempValue);
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(content: Text('threshold_updated'.tr)),
                    );
                  }
                },
                child: Text('save'.tr),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('clear_cache'.tr),
        content: Text('clear_cache_warning'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.clearCache();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'cache_cleared'.tr : 'cache_clear_failed'.tr,
                    ),
                  ),
                );
              }
            },
            child: Text('clear'.tr),
          ),
        ],
      ),
    );
  }

  void _showRestartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('language'.tr),
        content: Text('language_restart_hint'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ok'.tr),
          ),
        ],
      ),
    );
  }
}