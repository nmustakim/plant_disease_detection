
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';

class DatabaseManager {
  static Database? _db;

  Future<Database> get database async {
    _db ??= await initDatabase();
    return _db!;
  }

  Future<Database> initDatabase() async {
    final dbPath = p.join(await getDatabasesPath(), AppConstants.databaseName);
    AppLogger.info('Opening database: $dbPath', 'DatabaseManager');
    return await openDatabase(
      dbPath,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    AppLogger.info('Creating schema v$version', 'DatabaseManager');
    await db.execute(_sqlPredictions);
    await db.execute(_sqlPredictionsIdxTimestamp);
    await db.execute(_sqlPredictionsIdxDiseaseId);
    await db.execute(_sqlDiseaseInfo);
    await db.execute(_sqlDiseaseInfoIdxName);
    await db.execute(_sqlReferenceLinks);
    await db.execute(_sqlReferenceLinksIdx);
    await db.execute(_sqlAppSettings);
    await db.execute(_sqlErrorLogs);
    await db.execute(_sqlErrorLogsIdxTimestamp);
    await db.execute(_sqlErrorLogsIdxSeverity);
    await db.execute(_sqlFeedback);
    await db.execute(_sqlFeedbackIdx);
    AppLogger.info('Schema created successfully', 'DatabaseManager');
  }

  Future<void> _onUpgrade(Database db, int oldV, int newV) async {
    AppLogger.info('Upgrading DB from v$oldV to v$newV', 'DatabaseManager');
  }


  static const _sqlPredictions = '''
    CREATE TABLE predictions (
      id            TEXT    PRIMARY KEY NOT NULL,
      disease_id    TEXT    NOT NULL,
      confidence    REAL    NOT NULL CHECK (confidence >= 0.0 AND confidence <= 1.0),
      timestamp     INTEGER NOT NULL,
      image_path    TEXT    NOT NULL,
      model_version TEXT    NOT NULL DEFAULT '1.0',
      device_id     TEXT,
      created_at    INTEGER NOT NULL,
      FOREIGN KEY (disease_id) REFERENCES disease_info(disease_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
    )''';

  static const _sqlPredictionsIdxTimestamp =
      'CREATE INDEX idx_predictions_timestamp ON predictions(timestamp DESC)';
  static const _sqlPredictionsIdxDiseaseId =
      'CREATE INDEX idx_predictions_disease_id ON predictions(disease_id)';

  static const _sqlDiseaseInfo = '''
    CREATE TABLE disease_info (
      disease_id         TEXT NOT NULL PRIMARY KEY,
      disease_name       TEXT NOT NULL UNIQUE,
      symptoms           TEXT NOT NULL,
      cultural_control   TEXT,
      chemical_control   TEXT,
      biological_control TEXT,
      severity_level     TEXT NOT NULL CHECK (severity_level IN ('Low','Medium','High')),
      affected_crops     TEXT NOT NULL,
      created_at         INTEGER NOT NULL,
      updated_at         INTEGER NOT NULL
    )''';

  static const _sqlDiseaseInfoIdxName =
      'CREATE INDEX idx_disease_info_name ON disease_info(disease_name)';

  static const _sqlReferenceLinks = '''
    CREATE TABLE reference_links (
      link_id    INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      disease_id TEXT    NOT NULL,
      link_url   TEXT    NOT NULL,
      link_title TEXT    NOT NULL,
      source     TEXT    NOT NULL,
      created_at INTEGER NOT NULL,
      FOREIGN KEY (disease_id) REFERENCES disease_info(disease_id)
        ON DELETE CASCADE ON UPDATE CASCADE
    )''';

  static const _sqlReferenceLinksIdx =
      'CREATE INDEX idx_reference_links_disease_id ON reference_links(disease_id)';

  static const _sqlAppSettings = '''
    CREATE TABLE app_settings (
      setting_key   TEXT    PRIMARY KEY NOT NULL,
      setting_value TEXT    NOT NULL,
      updated_at    INTEGER NOT NULL
    )''';

  static const _sqlErrorLogs = '''
    CREATE TABLE error_logs (
      error_id      INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      error_code    TEXT    NOT NULL,
      error_message TEXT    NOT NULL,
      error_type    TEXT    CHECK (error_type IN
                    ('Permission','Validation','Model','Database','Network','Unknown')),
      prediction_id TEXT,
      timestamp     INTEGER NOT NULL,
      user_action   TEXT,
      device_info   TEXT,
      severity      TEXT    CHECK (severity IN ('INFO','WARNING','ERROR','CRITICAL')),
      resolved      INTEGER DEFAULT 0,
      FOREIGN KEY (prediction_id) REFERENCES predictions(id) ON DELETE SET NULL
    )''';

  static const _sqlErrorLogsIdxTimestamp =
      'CREATE INDEX idx_error_logs_timestamp ON error_logs(timestamp DESC)';
  static const _sqlErrorLogsIdxSeverity =
      'CREATE INDEX idx_error_logs_severity ON error_logs(severity)';

  static const _sqlFeedback = '''
    CREATE TABLE feedback (
      feedback_id          INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      prediction_id        TEXT    NOT NULL,
      user_feedback        TEXT    CHECK (user_feedback IN ('Correct','Incorrect','Unsure')),
      correct_disease_name TEXT,
      comments             TEXT,
      timestamp            INTEGER NOT NULL,
      FOREIGN KEY (prediction_id) REFERENCES predictions(id) ON DELETE CASCADE
    )''';

  static const _sqlFeedbackIdx =
      'CREATE INDEX idx_feedback_prediction_id ON feedback(prediction_id)';


  Future<String> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
    return data['id'] as String? ?? '';
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await database;
    return db.query(table, where: where, whereArgs: whereArgs,
        orderBy: orderBy, limit: limit);
  }

  Future<int> delete(String table,
      {required String where, required List<dynamic> whereArgs}) async {
    final db = await database;
    return db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<int> update(String table, Map<String, dynamic> data,
      {required String where, required List<dynamic> whereArgs}) async {
    final db = await database;
    return db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> rawQuery(
      String sql, [List<dynamic>? args]) async {
    final db = await database;
    return db.rawQuery(sql, args);
  }

  Future<void> close() async => _db?.close();
}
