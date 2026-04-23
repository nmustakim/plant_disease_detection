import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/route_constants.dart';
import '../../providers/prediction_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PredictionProvider>().addListener(_onProviderChange);
    });
  }

  @override
  void dispose() {
    context.read<PredictionProvider>().removeListener(_onProviderChange);
    super.dispose();
  }

  void _onProviderChange() {
    final prov = context.read<PredictionProvider>();
    if (prov.state == PredictionState.success && mounted) {
      Navigator.pushNamed(context, Routes.result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PredictionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('🌿 Plant DD AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, Routes.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFC8E6C9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('🌿', style: TextStyle(fontSize: 60)),
                  Text('Take a photo of an affected leaf',
                      style: TextStyle(color: Color(0xFF2E7D32))),
                  Text('Get instant AI diagnosis',
                      style: TextStyle(color: Color(0xFF388E3C), fontSize: 12)),
                ]),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: provider.isProcessing
                    ? null
                    : () => context.read<PredictionProvider>().captureFromCamera(),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Scan Leaf', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: provider.isProcessing
                    ? null
                    : () => context.read<PredictionProvider>().uploadFromGallery(),
                icon: const Icon(Icons.photo_library),
                label: const Text('Upload from Gallery', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, Routes.history),
                icon: const Icon(Icons.history),
                label: const Text('View History', style: TextStyle(fontSize: 16)),
              ),
            ),

            if (provider.isProcessing) ...[
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
              const SizedBox(height: 8),
              const Text('Analysing leaf…'),
            ],

            if (provider.state == PredictionState.error &&
                provider.errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                provider.errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFA5D6A7)),
              ),
              child: const Text(
                '💡 Tip: Photograph a single leaf in good daylight, filling the frame.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
