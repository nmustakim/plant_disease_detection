import 'package:flutter/material.dart';
import 'package:plant_dd_ai/screens/history/history_screen.dart';
import 'package:plant_dd_ai/screens/home/home_screen.dart';
import 'package:plant_dd_ai/screens/initial/splash_screen.dart';
import 'package:plant_dd_ai/screens/result/result_screen.dart';
import 'package:plant_dd_ai/screens/settings/settings_screen.dart';
import 'package:plant_dd_ai/services/image/image_processor.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/route_constants.dart';
import 'providers/prediction_provider.dart';
import 'providers/history_provider.dart';
import 'controllers/prediction_controller.dart';
import 'services/image/image_service.dart';
import 'ml/disease_classifier.dart';
import 'data/database/database_manager.dart';
import 'core/errors/error_handler.dart';
import 'data/database/daos/error_logs_dao.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final databaseManager = DatabaseManager();
  final imageService = ImageService();
  final preprocessor = ImagePreprocessor();
  final classifier = DiseaseClassifier();
  final errorHandler = ErrorHandler(ErrorLogsDao());

  await classifier.loadModel();

  final predictionController = PredictionController(
    imageService: imageService,
    preprocessor: preprocessor,
    mlModel: classifier,
    database: databaseManager,
    errorHandler: errorHandler,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PredictionProvider(predictionController),
        ),
        ChangeNotifierProvider(
          create: (_) => HistoryProvider(databaseManager),
        ),
      ],
      child: const PlantDDAI(),
    ),
  );
}

class PlantDDAI extends StatelessWidget {
  const PlantDDAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant DD AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: Routes.splash,
      routes: {
        Routes.splash: (context) => const SplashScreen(),
        Routes.home: (context) => const HomeScreen(),
        Routes.result: (context) => const ResultScreen(),
        Routes.history: (context) => const HistoryScreen(),
        Routes.settings: (context) => const SettingsScreen(),
      },
    );
  }
}