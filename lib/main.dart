import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'controllers/history_controller.dart';
import 'controllers/prediction_controller.dart';
import 'controllers/settings_controller.dart';
import 'core/constants/route_constants.dart';
import 'core/errors/error_handler.dart';
import 'core/theme/app_theme.dart';
import 'data/database/daos/error_logs_dao.dart';
import 'data/database/database_manager.dart';
import 'firebase_options.dart';
import 'ml/disease_classifier.dart';
import 'providers/history_provider.dart';
import 'providers/prediction_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/help&faq/help_and_faq.dart';
import 'screens/history/history_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/initial/splash_screen.dart';
import 'screens/result/result_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'services/image/image_processor.dart';
import 'services/image/image_service.dart';
import 'services/translation/translation_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await TranslationService.instance.init();

  final settingsController = SettingsController();

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

  final historyController = HistoryController(database: databaseManager);

  runApp(
    MultiProvider(
      providers: [

        ChangeNotifierProvider<TranslationService>.value(
          value: TranslationService.instance,
        ),
        ChangeNotifierProvider(
          create: (_) => PredictionProvider(predictionController),
        ),
        ChangeNotifierProvider(
          create: (_) => HistoryProvider(historyController),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(
            settingsController,
            classifier: classifier,
          ),
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

    final translationService = context.watch<TranslationService>();

    return MaterialApp(
      title: 'Plant DD AI',
      debugShowCheckedModeBanner: false,

      locale: translationService.currentLocale,
      supportedLocales: kSupportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      initialRoute: Routes.splash,
      routes: {
        Routes.splash: (_) => const SplashScreen(),
        Routes.home: (_) => const HomeScreen(),
        Routes.result: (_) => const ResultScreen(),
        Routes.history: (_) => const HistoryScreen(),
        Routes.settings: (_) => const SettingsScreen(),
        Routes.helpAndFaq: (_) => const HelpFaqScreen(),
      },
    );
  }
}