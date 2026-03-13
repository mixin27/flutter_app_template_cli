// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coupon_dao.dart';

// ignore_for_file: type=lint
mixin _$CouponDaoMixin on DatabaseAccessor<AppDatabase> {
  $CouponRecordsTable get couponRecords => attachedDatabase.couponRecords;
  CouponDaoManager get managers => CouponDaoManager(this);
}

class CouponDaoManager {
  final _$CouponDaoMixin _db;
  CouponDaoManager(this._db);
  $$CouponRecordsTableTableManager get couponRecords =>
      $$CouponRecordsTableTableManager(_db.attachedDatabase, _db.couponRecords);
}
