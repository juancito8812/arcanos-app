import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'psicotarot.db');
    return openDatabase(path, version: 1, onCreate: (db, v) async {
      await db.execute('CREATE TABLE perfiles (id INTEGER PRIMARY KEY AUTOINCREMENT, nombre TEXT NOT NULL, fechaNacimiento TEXT NOT NULL, arcano1 INTEGER, arcano2 INTEGER, arcano3 INTEGER, arcano4 INTEGER, arcano5 INTEGER, fechaCreacion TEXT NOT NULL)');
      await db.execute('CREATE TABLE tiradas (id INTEGER PRIMARY KEY AUTOINCREMENT, tipo TEXT NOT NULL, fecha TEXT NOT NULL, cartas TEXT NOT NULL, interpretacion TEXT)');
      await db.execute('CREATE TABLE regresiones (id INTEGER PRIMARY KEY AUTOINCREMENT, titulo TEXT NOT NULL, contenido TEXT, fecha TEXT NOT NULL, tipo TEXT NOT NULL)');
    });
  }

  static Future<int> guardarPerfil(Map<String, dynamic> perfil) async { final db = await database; return db.insert('perfiles', perfil); }
  static Future<List<Map<String, dynamic>>> obtenerPerfiles() async { final db = await database; return db.query('perfiles', orderBy: 'fechaCreacion DESC'); }
  static Future<int> guardarTirada(Map<String, dynamic> tirada) async { final db = await database; return db.insert('tiradas', tirada); }
  static Future<List<Map<String, dynamic>>> obtenerHistorialTiradas() async { final db = await database; return db.query('tiradas', orderBy: 'fecha DESC'); }
  static Future<int> guardarRegresion(Map<String, dynamic> regresion) async { final db = await database; return db.insert('regresiones', regresion); }
  static Future<List<Map<String, dynamic>>> obtenerRegresiones() async { final db = await database; return db.query('regresiones', orderBy: 'fecha DESC'); }

  static Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'psicotarot.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
