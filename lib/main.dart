import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/history/history_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/initial/splash_screen.dart';
import 'screens/result/result_screen.dart';
import 'screens/settings/settings_screen.dart';

import 'package:provider/provider.dart';
import 'providers/prediction_provider.dart';
import 'providers/history_provider.dart';
import 'providers/feedback_provider.dart';
import 'providers/settings_provider.dart';

import 'controllers/prediction_controller.dart';
import 'controllers/history_controller.dart';
import 'controllers/settings_controller.dart';

import 'services/image/image_service.dart';
import 'services/image/image_preprocessor.dart';
import 'ml/disease_classifier.dart';

import 'data/database/database_manager.dart';

import 'core/errors/error_handler.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/route_constants.dart';
import 'data/database/daos/error_logs_dao.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final databaseManager = DatabaseManager();
  await databaseManager.initDatabase();

  final imageService = ImageService();
  final preprocessor = ImagePreprocessor();

  final classifier = DiseaseClassifier();
  await classifier.loadModel();

  final errorHandler = ErrorHandler(ErrorLogsDao(databaseManager));

  final predictionController = PredictionController(
    imageService: imageService,
    preprocessor: preprocessor,
    mlModel: classifier,
    database: databaseManager,
    errorHandler: errorHandler,
  );

  final historyController = HistoryController(database: databaseManager);

  final settingsController = SettingsController(database: databaseManager);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PredictionProvider(predictionController),
        ),
        ChangeNotifierProvider(
          create: (_) => HistoryProvider(historyController),
        ),
        ChangeNotifierProvider(
          create: (_) => FeedbackProvider(databaseManager),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(settingsController),
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

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('bn')],

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
