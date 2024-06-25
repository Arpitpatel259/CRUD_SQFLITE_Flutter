import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {

  /// Table Create Function
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE data(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      title TEXT NOT NULL,
      desc TEXT NOT NULL,
      createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      );""");
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase("database_name.db", version: 1,
        onCreate: (sql.Database database, int version) async {
          await createTables(database);
        });
  }

  // Data Create
  static Future<int> createData(String title, String? desc) async {
    final db = await SQLHelper.db();

    final data = {'title': title, 'desc': desc};

    final id = await db.insert("data", data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }

  //Get All Data
  static Future<List<Map<String, dynamic>>> getAllData() async {
    final db = await SQLHelper.db();
    return db.query('data', orderBy: 'id');
  }

  //Data Update
  static Future<int> updateData(int id, String title, String? desc) async {
    final db = await SQLHelper.db();
    final data = {
      'title': title,
      'desc': desc,
      'createdAt': DateTime.now().toString()
    };

    final result =
    await db.update("data", data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  //Data delete
  static Future<void> deleteData(int id) async {
    final db = await SQLHelper.db();

    try {
      await db.delete("data", where: "id = ?", whereArgs: [id]);
    } catch (e) {
      e.toString();
    }
  }
}
