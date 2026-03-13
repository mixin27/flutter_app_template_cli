import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/loyalty_records.dart';

part 'loyalty_dao.g.dart';

@DriftAccessor(tables: [LoyaltyRecords])
class LoyaltyDao extends DatabaseAccessor<AppDatabase> with _$LoyaltyDaoMixin {
  LoyaltyDao(super.db);

  Future<List<LoyaltyRecord>> getAllEntries() {
    return (select(
      loyaltyRecords,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
  }

  Future<void> upsertEntry(LoyaltyRecordsCompanion entry) {
    return into(loyaltyRecords).insertOnConflictUpdate(entry);
  }
}
