import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:permission_handler/permission_handler.dart';

class DatabaseHelper {
  static Database? _database;
  static const String _dbName = 'toll_stations.db';

  // Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDb();
    return _database!;
  }

  // Request storage permission (for Android 10 and below)
  Future<void> requestStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      print("Storage permission granted.");
    } else {
      print("Storage permission denied.");
    }
  }

  // Get the database path in external storage
  Future<String> getDatabasePath() async {
    Directory? dir;
    
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted) {
        dir = await getExternalStorageDirectory(); // Android external storage
      } else {
        dir = await getApplicationDocumentsDirectory(); // Fallback (Scoped Storage)
      }
    } else {
      dir = await getApplicationDocumentsDirectory(); // iOS storage
    }

    if (dir == null) {
      throw Exception("External storage not available!");
    }

    String path = join(dir.path, _dbName);
    print("Database Path: $path");
    return path;
  }

  // Initialize the database
Future<Database> initDb() async {
  String path = await getDatabasePath();

  return await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      print("Creating database...");
      await db.execute('''
        CREATE TABLE IF NOT EXISTS toll_stations(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          latitude REAL,
          longitude REAL,
          motorway TEXT,
          toll INTEGER,
          cities TEXT
        )
      ''');
      print("Table toll_stations created successfully");
    },
    onOpen: (db) {
      print("Database opened successfully");
    },
  );
}


  // Insert data
  Future<void> insertTollStations(List<Map<String, dynamic>> tollStations) async {
    final db = await database;
    for (var station in tollStations) {
      await db.insert('toll_stations', {
        'name': station['name'],
        'latitude': station['location'].latitude,
        'longitude': station['location'].longitude,
        'motorway': station['motorway'],
        'toll': station['toll'],
        'cities': station['cities'].join(','),
      });
    }
  }

  // Get toll stations with filters
  Future<List<Map<String, dynamic>>> getTollStations({String? motorway, String? city}) async {
    final db = await database;

    // Construct the query with optional filtering
    String query = 'SELECT * FROM toll_stations';
    List<String> whereConditions = [];
    List<dynamic> whereArgs = [];

    if (motorway != null) {
      whereConditions.add('motorway = ?');
      whereArgs.add(motorway);
    }

    if (city != null) {
      whereConditions.add('cities LIKE ?');
      whereArgs.add('%$city%');
    }

    if (whereConditions.isNotEmpty) {
      query += ' WHERE ${whereConditions.join(' AND ')}';
    }

    final result = await db.rawQuery(query, whereArgs);
    return result;
  }

  // Delete the database (for debugging)
  Future<void> deleteDatabaseFile() async {
    String dbPath = await getDatabasePath();
    await deleteDatabase(dbPath);
    print("Database deleted successfully");
  }

  // Check if table exists
  Future<bool> checkTableExists() async {
    final db = await database;
    var res = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='toll_stations'"
    );
    return res.isNotEmpty;
  }
}
