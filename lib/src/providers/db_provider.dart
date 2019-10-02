import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:qrreaderapp/src/models/scan_model.dart';
export 'package:qrreaderapp/src/models/scan_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBProvider {
  static Database _database;
  static final DBProvider db = DBProvider._();

//Constructor privado
  DBProvider._();

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    final path = join(documentsDirectory.path, 'ScansDB.db');

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('CREATE TABLE Scans ('
            ' id INTEGER PRIMARY KEY,'
            ' tipo TEXT,'
            ' valor TEXT'
            ')');
      },
    );
  }

  //CREAR registros

  Future<int> nuevoScanRaw(ScanModel nuevoScan) async {
    final db = await database;

    final res = await db.rawInsert(
        "INSERT INTO Scans (id, tipo, valor) " //Necesita el espacio
        "VALUES (${nuevoScan.id}, '${nuevoScan.tipo}', '${nuevoScan.valor}')");
    return res; //Cantidad de filas modificadas.
  }

  Future<int> nuevoScan(ScanModel nuevoScan) async {
    final db = await database;

    final res = await db.insert('Scans', nuevoScan.toJson());

    return res;
  }

  //SELECT - Obtener información

  Future<ScanModel> getScanId(int id) async {
    final db = await database;

    final res = await db.query('Scans',
        where: 'id = ?',
        whereArgs: [id]); //El ? debe respetarse la posición en el whereargs

    return res.isNotEmpty ? ScanModel.fromJson(res.first) : null;
  }

  Future<List<ScanModel>> getTodosScans() async {
    List<ScanModel> lista = new List();
    final db = await database;

    final res = await db
        .query('Scans'); //El ? debe respetarse la posición en el whereargs

    lista =
        res.isNotEmpty ? res.map((s) => ScanModel.fromJson(s)).toList() : [];

    return lista;
  }

  Future<List<ScanModel>> getScansPorTipo(String tipo) async {
    List<ScanModel> lista = new List();
    final db = await database;

    final res = await db.rawQuery("SELECT * FROM Scans WHERE tipo = '$tipo'");

    lista =
        res.isNotEmpty ? res.map((s) => ScanModel.fromJson(s)).toList() : [];

    return lista;
  }

  //Actualizar registros

  Future<int> updateScan(ScanModel scan) async {
    final db = await database;

    final res = await db
        .update('Scans', scan.toJson(), where: 'id = ?', whereArgs: [scan.id]);

    return res;
  }

  //Eliminar registros

  Future<int> deleteScan(int id) async {
    final db = await database;

    final res = await db.delete('Scans', where: 'id = ?', whereArgs: [id]);

    return res;
  }

  Future<int> deleteAll() async {
    final db = await database;

    final res = await db.delete('Scans');

    return res;
  }
}
