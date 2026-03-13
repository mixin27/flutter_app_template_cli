import 'package:drift/drift.dart';

class CampaignRecords extends Table {
  TextColumn get id => text()();

  TextColumn get title => text()();

  TextColumn get description => text()();

  DateTimeColumn get startsAt => dateTime()();

  DateTimeColumn get endsAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
