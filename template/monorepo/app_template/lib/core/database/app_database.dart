import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/app_notification_dao.dart';
import 'daos/campaign_dao.dart';
import 'daos/coupon_dao.dart';
import 'daos/loyalty_dao.dart';
import 'tables/app_notification_records.dart';
import 'tables/campaign_records.dart';
import 'tables/coupon_records.dart';
import 'tables/loyalty_records.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    CampaignRecords,
    CouponRecords,
    LoyaltyRecords,
    AppNotificationRecords,
  ],
  daos: [CampaignDao, CouponDao, LoyaltyDao, AppNotificationDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(couponRecords);
        await migrator.createTable(loyaltyRecords);
        await migrator.createTable(appNotificationRecords);
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final databaseFile = File(p.join(documentsDirectory.path, 'app.sqlite'));

    return NativeDatabase.createInBackground(databaseFile);
  });
}
