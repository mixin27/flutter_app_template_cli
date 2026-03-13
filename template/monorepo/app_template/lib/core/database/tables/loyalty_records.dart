import 'package:drift/drift.dart';

class LoyaltyRecords extends Table {
  TextColumn get id => text()();

  TextColumn get title => text()();

  IntColumn get points => integer()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
