// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loyalty_dao.dart';

// ignore_for_file: type=lint
mixin _$LoyaltyDaoMixin on DatabaseAccessor<AppDatabase> {
  $LoyaltyRecordsTable get loyaltyRecords => attachedDatabase.loyaltyRecords;
  LoyaltyDaoManager get managers => LoyaltyDaoManager(this);
}

class LoyaltyDaoManager {
  final _$LoyaltyDaoMixin _db;
  LoyaltyDaoManager(this._db);
  $$LoyaltyRecordsTableTableManager get loyaltyRecords =>
      $$LoyaltyRecordsTableTableManager(
        _db.attachedDatabase,
        _db.loyaltyRecords,
      );
}
