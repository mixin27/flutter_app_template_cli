import 'package:drift/drift.dart';

class CouponRecords extends Table {
  TextColumn get id => text()();

  TextColumn get code => text()();

  TextColumn get campaignTitle => text()();

  IntColumn get amount => integer()();

  IntColumn get quantity => integer()();

  DateTimeColumn get expiresAt => dateTime()();

  BoolColumn get isRedeemed => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
