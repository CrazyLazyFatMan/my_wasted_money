import 'dart:io';
import 'package:my_wasted_money/Spends.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class WastedDB {
  Database _database;

  Future<Database> get database async {
    if (_database == null) {
      _database = await initialize();
    }
    return _database;
  }

  WastedDB();

  initialize() async {
    Directory documentsDir = await getApplicationDocumentsDirectory();
    var path = join(documentsDir.path, "myWastedMoney.db");
    return openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute("""CREATE TABLE Wasted_money (id INTEGER PRIMARY KEY AUTOINCREMENT, price REAL, date TEXT, name TEXT)""");
      }
    );
  }

  Future<List<Spends>> getEveryWaste([bool part, DateTime fDate, DateTime sDate]) async {
    Database db = await database;
    DateTime leftDate = DateTime.parse('1800-01-01');
    DateTime rightDate = DateTime.parse('3000-12-31');
    if (part != null)
      {
        leftDate = fDate;
        rightDate = sDate;
      }
    List<Map> q = await db.rawQuery("SELECT * FROM Wasted_money WHERE date >= \"$leftDate\" AND date < \"$rightDate\" ORDER BY date DESC");
    var result = List<Spends>();
    q.forEach((r) => result.add(Spends(r["id"], DateTime.parse(r["date"]), r["name"], r["price"])));
    return result;
  }

  Future<void> newSpend(String name, double price, DateTime dateTime) async {
    Database db = await database;
    var dateString = dateTime.toString();
    db.rawInsert("INSERT INTO Wasted_money (name, date, price) VALUES (\"$name\", \"$dateString\", $price)");
  }

  Future<void> deleteSpend(int id) async {
    Database db = await database;
    db.rawDelete("DELETE FROM Wasted_money WHERE id LIKE \"$id%\"");
  }

  Future<void> updateSpend(String name, double price, DateTime date, int id) async {
    Database db = await database;
    db.rawUpdate('UPDATE Wasted_money SET price = ?, date = ?, name = ? WHERE id = ?',
        [price, date.toString(), name, id]);
  }

}