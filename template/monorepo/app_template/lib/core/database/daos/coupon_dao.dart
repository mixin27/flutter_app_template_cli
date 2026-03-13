import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/coupon_records.dart';

part 'coupon_dao.g.dart';

@DriftAccessor(tables: [CouponRecords])
class CouponDao extends DatabaseAccessor<AppDatabase> with _$CouponDaoMixin {
  CouponDao(super.db);

  Future<List<CouponRecord>> getAllCoupons() {
    return (select(
      couponRecords,
    )..orderBy([(t) => OrderingTerm.asc(t.expiresAt)])).get();
  }

  Future<void> upsertCoupon(CouponRecordsCompanion coupon) {
    return into(couponRecords).insertOnConflictUpdate(coupon);
  }
}
