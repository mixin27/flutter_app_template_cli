import 'package:drift/drift.dart';

class AppNotificationRecords extends Table {
  TextColumn get id => text()();

  TextColumn get title => text()();

  TextColumn get body => text()();

  DateTimeColumn get createdAt => dateTime()();

  BoolColumn get isRead => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
