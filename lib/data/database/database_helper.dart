import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);

    AppLogger.info('Initializing database at: $path', 'DatabaseHelper');

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create all tables (from Deliverable 2 Section 6)
  Future<void> _onCreate(Database db, int version) async {
    AppLogger.info('Creating database tables...', 'DatabaseHelper');

    await db.execute('''
      CREATE TABLE disease_info (
        disease_id TEXT PRIMARY KEY NOT NULL UNIQUE,
        disease_name TEXT NOT NULL UNIQUE,
        symptoms TEXT NOT NULL,
        cultural_control TEXT,
        chemical_control TEXT,
        biological_control TEXT,
        severity_level TEXT NOT NULL CHECK (severity_level IN ('Low', 'Medium', 'High')),
        affected_crops TEXT NOT NULL,
        created_at INTEGER NOT NULL DEFAULT ${DateTime.now().millisecondsSinceEpoch ~/ 1000},
        updated_at INTEGER NOT NULL DEFAULT ${DateTime.now().millisecondsSinceEpoch ~/ 1000}
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_disease_info_name ON disease_info(disease_name)
    ''');

    // Table: predictions
    await db.execute('''
      CREATE TABLE predictions (
        id TEXT PRIMARY KEY NOT NULL UNIQUE,
        disease_id TEXT NOT NULL,
        confidence REAL NOT NULL CHECK (confidence >= 0.0 AND confidence <= 1.0),
        timestamp INTEGER NOT NULL,
        image_path TEXT NOT NULL,
        model_version TEXT NOT NULL DEFAULT '1.0',
        device_id TEXT,
        created_at INTEGER NOT NULL DEFAULT ${DateTime.now().millisecondsSinceEpoch ~/ 1000},
        FOREIGN KEY (disease_id) REFERENCES disease_info(disease_id) ON DELETE RESTRICT ON UPDATE CASCADE
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_predictions_timestamp ON predictions(timestamp DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_predictions_disease_id ON predictions(disease_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_predictions_device_id ON predictions(device_id)
    ''');

    await db.execute('''
      CREATE TABLE reference_links (
        link_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        disease_id TEXT NOT NULL,
        link_url TEXT NOT NULL,
        link_title TEXT NOT NULL,
        source TEXT NOT NULL,
        created_at INTEGER NOT NULL DEFAULT ${DateTime.now().millisecondsSinceEpoch ~/ 1000},
        FOREIGN KEY (disease_id) REFERENCES disease_info(disease_id) ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_reference_links_disease_id ON reference_links(disease_id)
    ''');

    await db.execute('''
      CREATE TABLE app_settings (
        setting_key TEXT PRIMARY KEY NOT NULL UNIQUE,
        setting_value TEXT NOT NULL,
        updated_at INTEGER NOT NULL DEFAULT ${DateTime.now().millisecondsSinceEpoch ~/ 1000}
      )
    ''');

    await db.execute('''
      CREATE TABLE error_logs (
        error_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        error_code TEXT NOT NULL,
        error_message TEXT NOT NULL,
        error_type TEXT CHECK (error_type IN ('Permission', 'Validation', 'Model', 'Database', 'Network', 'Unknown')),
        prediction_id TEXT,
        timestamp INTEGER NOT NULL,
        user_action TEXT,
        device_info TEXT,
        severity TEXT CHECK (severity IN ('INFO', 'WARNING', 'ERROR', 'CRITICAL')),
        resolved INTEGER DEFAULT 0,
        FOREIGN KEY (prediction_id) REFERENCES predictions(id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_error_logs_timestamp ON error_logs(timestamp DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_error_logs_error_code ON error_logs(error_code)
    ''');

    await db.execute('''
      CREATE INDEX idx_error_logs_severity ON error_logs(severity)
    ''');

    await db.execute('''
  CREATE TABLE feedback (
    feedback_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    prediction_id TEXT NOT NULL,
    user_feedback TEXT CHECK (user_feedback IN ('Correct', 'Incorrect', 'Unsure')),
    correct_disease_name TEXT,
    comments TEXT,
    timestamp INTEGER NOT NULL,
    is_synced INTEGER DEFAULT 0,
    FOREIGN KEY (prediction_id) REFERENCES predictions(id) ON DELETE CASCADE
  )
''');

    await db.execute('''
      CREATE INDEX idx_feedback_prediction_id ON feedback(prediction_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_feedback_user_feedback ON feedback(user_feedback)
    ''');

    AppLogger.info('Database tables created successfully', 'DatabaseHelper');

    await _insertDefaultDiseaseData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    AppLogger.info(
      'Upgrading database from version $oldVersion to $newVersion',
      'DatabaseHelper',
    );
  }

  Future<void> _insertDefaultDiseaseData(Database db) async {
    AppLogger.info('Inserting default disease data...', 'DatabaseHelper');

    final defaultDiseases = [
      {
        'disease_id': 'healthy_001',
        'disease_name': 'Healthy',
        'symptoms': 'No visible symptoms. Leaves appear green and healthy.',
        'cultural_control': 'Maintain good agricultural practices.',
        'chemical_control': null,
        'biological_control': null,
        'severity_level': 'Low',
        'affected_crops': '["Tomato", "Potato", "Pepper"]',
      },
      {
        'disease_id': 'early_blight_001',
        'disease_name': 'Early Blight',
        'symptoms':
            'Water-soaked spots on leaves with concentric rings (bullseye pattern). Lower leaves affected first.',
        'cultural_control':
            'Remove infected leaves, improve air circulation, avoid overhead irrigation, practice crop rotation.',
        'chemical_control':
            'Apply copper fungicide every 7 days starting from disease onset. Use chlorothalonil or mancozeb.',
        'biological_control': 'Use Bacillus subtilis-based bioagent.',
        'severity_level': 'High',
        'affected_crops': '["Tomato", "Potato"]',
      },
      {
        'disease_id': 'late_blight_001',
        'disease_name': 'Late Blight',
        'symptoms':
            'Grayish-green water-soaked lesions on leaves. White fungal growth on leaf undersides. Rapid spread in humid conditions.',
        'cultural_control':
            'Destroy infected plants immediately, ensure good drainage, avoid overhead watering.',
        'chemical_control':
            'Apply metalaxyl or mancozeb preventatively. Repeat every 5-7 days during wet weather.',
        'biological_control': 'Limited biological control options available.',
        'severity_level': 'High',
        'affected_crops': '["Tomato", "Potato"]',
      },
    ];

    for (final disease in defaultDiseases) {
      await db.insert('disease_info', disease);
    }

    AppLogger.info('Default disease data inserted', 'DatabaseHelper');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
