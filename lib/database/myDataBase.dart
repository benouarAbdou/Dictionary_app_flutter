import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqlDb {
  static Database? _db;

  Future<Database?> get db async {
    if (_db == null) {
      _db = await intialDb();
      return _db;
    } else {
      return _db;
    }
  }

  intialDb() async {
    String databasepath = await getDatabasesPath();
    String path = join(databasepath, 'notes.db');
    Database mydb = await openDatabase(path,
        onCreate: _onCreate,
        version: 7,
        onUpgrade: _onUpgrade,
        onOpen: _onOpen);
    return mydb;
  }

  _onUpgrade(Database db, int oldversion, int newversion) async {
    print("onUpgrade =====================================");
  }

  _onOpen(Database db) async {
    await db.execute("PRAGMA foreign_keys = ON");
  }

  _onCreate(Database db, int version) async {
    await db.execute("PRAGMA foreign_keys = ON");

    await db.execute(
        '''
CREATE TABLE "word" (
   "wordId" INTEGER  NOT NULL PRIMARY KEY  AUTOINCREMENT, 
    "value" TEXT NOT NULL,
    "description" TEXT NOT NULL
  ) ''');

    print("word created");

    print(" onCreate =====================================");
  }

  readData(String sql) async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery(sql);
    return response;
  }

  insertData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawInsert(sql);
    return response;
  }

  updateData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawUpdate(sql);
    return response;
  }

  deleteData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawDelete(sql);
    return response;
  }

// SELECT
// DELETE
// UPDATE
// INSERT

  Future<void> saveRecentLine(String value, String description) async {
    // Check if a row with the same value already exists
    bool exists = await checkIfValueExists(value);

    if (!exists) {
      // Insert the new line
      await insertData(
          "INSERT INTO word (value, description) VALUES ('$value', '$description')");

      print("line added");

      // Get the total count of rows in the table
      int rowCount = await countRows();
      print("count : $rowCount");

      // If more than 5 rows, delete the oldest rows
      if (rowCount > 5) {
        await deleteOldestRows(rowCount - 5);
      }
    } else {
      print("Value already exists, skipping insertion");
    }
  }

// Helper function to check if a row with given value exists in "word" table
  Future<bool> checkIfValueExists(String value) async {
    Database? mydb = await db;
    List<Map<String, dynamic>> rows = await mydb!.rawQuery(
      'SELECT * FROM word WHERE value = ?',
      [value],
    );

    return rows.isNotEmpty; // Return true if any rows are found
  }

  // Helper function to count total rows in "word" table
  Future<int> countRows() async {
    Database? mydb = await db;
    int count = Sqflite.firstIntValue(
        await mydb!.rawQuery('SELECT COUNT(*) FROM word'))!;
    return count;
  }

  // Helper function to delete oldest rows from "word" table
  Future<void> deleteOldestRows(int deleteCount) async {
    Database? mydb = await db;
    await mydb!.transaction((txn) async {
      // Select the oldest rows based on wordId
      List<Map<String, dynamic>> oldestRows = await txn.rawQuery(
        'SELECT wordId FROM word ORDER BY wordId ASC LIMIT $deleteCount',
      );

      // Extract wordIds of oldest rows
      List<int> wordIds =
          oldestRows.map((row) => row['wordId'] as int).toList();

      // Delete the oldest rows
      for (int wordId in wordIds) {
        await txn.rawDelete('DELETE FROM word WHERE wordId = ?', [wordId]);
      }
    });
  }
}
