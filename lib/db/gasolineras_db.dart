import 'package:path/path.dart';
import 'package:proyecto_tfg/models/gasolinera.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class GasolinerasDatabase {
  static final GasolinerasDatabase instance = GasolinerasDatabase._init();

  static Database _database;

  GasolinerasDatabase._init();

  Future<Database> get database async{
    if(_database != null) return _database;

    _database = await _initDB('gasolineras.db');
  }
 
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final num = 'REAL';
    final string = 'TEXT';
    db.execute(
        "CREATE TABLE gasolineras (id $num, codigoPostal $string, rotulo $string,latitud $num, longitud $num,geohash $string, municipio $string, precioGasoleoA $string,precioGasoleoB $string,precioGasolina95 $string,precioGasolina98 $string)");
  }

   Future<Gasolinera> create(Gasolinera g) async {
    final db = await instance.database;

    final id = await db.insert("gasolineras", g.toMap());
  }

  Future<Gasolinera> deleteAll() async {
    final db = await instance.database;
    
    final id = await db.delete("gasolineras");
  }

   Future<List<Map<String,Object>>> readGasolinera(double latitud, double longitud) async {
    final db = await instance.database;
    final map = await db.query("gasolineras",
        columns: GasolineraFields.values,
        where: 'latitud = ? and longitud = ?',
        whereArgs: [latitud, longitud]);
    if(map.isNotEmpty){
      return map;
    }
  }

  Future<List<Gasolinera>> readGasolineras() async{
    final db = await instance.database;
    final result = await db.query("gasolineras");

    return result.map((e) => Gasolinera.fromMap(e)).toList();
  }

  Future<bool> hayGasolineraEnBd(String geohash) async{
    final db = await instance.database;
    final result = await db.query("gasolineras",columns: ['geohash'],where: 'geohash = ?',whereArgs: [geohash]);
    
    
    if(result.isEmpty) return false;
    else return true;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
