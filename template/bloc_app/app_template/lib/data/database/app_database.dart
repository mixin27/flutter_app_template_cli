import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DataClassName('TaskRecord')
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('AuthTokenRecord')
class AuthTokens extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get token => text()();
  TextColumn get userId => text()();
  TextColumn get userName => text()();
  TextColumn get userEmail => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('ProfileRecord')
class Profiles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get avatarUrl => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [Tasks, AuthTokens, Profiles],
  daos: [TasksDao, AuthDao, ProfilesDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

@DriftAccessor(tables: [Tasks])
class TasksDao extends DatabaseAccessor<AppDatabase> with _$TasksDaoMixin {
  TasksDao(super.db);

  Stream<List<TaskRecord>> watchAllTasks() {
    return (select(
      tasks,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
  }

  Future<int> createTask({required String title}) {
    return into(tasks).insert(TasksCompanion.insert(title: title));
  }

  Future<void> updateTaskStatus({required int id, required bool isDone}) async {
    await (update(tasks)..where((tbl) => tbl.id.equals(id))).write(
      TasksCompanion(isDone: Value(isDone)),
    );
  }

  Future<int> deleteTask(int id) {
    return (delete(tasks)..where((tbl) => tbl.id.equals(id))).go();
  }
}

@DriftAccessor(tables: [AuthTokens])
class AuthDao extends DatabaseAccessor<AppDatabase> with _$AuthDaoMixin {
  AuthDao(super.db);

  Future<AuthTokenRecord?> getToken() {
    return (select(authTokens)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> saveToken({
    required String token,
    required String userId,
    required String userName,
    required String userEmail,
  }) async {
    await into(authTokens).insert(
      AuthTokensCompanion.insert(
        token: token,
        userId: userId,
        userName: userName,
        userEmail: userEmail,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> clearToken() async {
    await delete(authTokens).go();
  }
}

@DriftAccessor(tables: [Profiles])
class ProfilesDao extends DatabaseAccessor<AppDatabase>
    with _$ProfilesDaoMixin {
  ProfilesDao(super.db);

  Future<ProfileRecord?> getProfile(String id) {
    return (select(
      profiles,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<void> upsertProfile(ProfileRecord record) async {
    await into(profiles).insertOnConflictUpdate(record);
  }

  Future<void> clearProfile(String id) async {
    await (delete(profiles)..where((tbl) => tbl.id.equals(id))).go();
  }
}
