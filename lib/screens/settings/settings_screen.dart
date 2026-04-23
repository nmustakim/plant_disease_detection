
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/constants/app_constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<SettingsProvider>();
    final s    = prov.settings;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: Text(s.language == 'en' ? 'English' : 'বাংলা'),
            trailing: DropdownButton<String>(
              value: s.language,
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'bn', child: Text('বাংলা')),
              ],
              onChanged: (lang) {
                if (lang != null) prov.setLanguage(lang);
              },
            ),
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.memory),
            title: const Text('Model Version'),
            subtitle: Text('v${s.modelVersion}'),
            trailing: OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Checking for model updates…')));
              },
              child: const Text('Check for Updates'),
            ),
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('Confidence Threshold'),
            subtitle: Text('${(s.confidenceThreshold * 100).toStringAsFixed(0)}%'
                ' – results below this are marked "Unknown"'),
          ),
          Slider(
            value: s.confidenceThreshold,
            min: 0.40,
            max: 0.90,
            divisions: 10,
            label: '${(s.confidenceThreshold * 100).toStringAsFixed(0)}%',
            onChanged: (v) => prov.setConfidenceThreshold(v),
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.cleaning_services),
            title: const Text('Clear Cache'),
            subtitle: const Text('Frees temporary image processing storage'),
            onTap: () async {
              final ok = await prov.clearCache();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ok ? 'Cache cleared.' : 'Nothing to clear.')));
              }
            },
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: Text(
              '${AppConstants.appName} v${AppConstants.appVersion}\n'
              'IT402 Capstone – Md Nayeem Mustakim\n'
              'International Open University',
            ),
          ),
          const Divider(),

          const Padding(
            padding: EdgeInsets.all(16),
            child: Card(
              color: Color(0xFFFFF5E6),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'DISCLAIMER: Plant DD AI provides AI-based predictions for '
                  'advisory purposes only. Always consult a qualified agronomist '
                  'before applying treatments.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF7B3B00)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
