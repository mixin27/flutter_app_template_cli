import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/app_notification_records.dart';

part 'app_notification_dao.g.dart';

@DriftAccessor(tables: [AppNotificationRecords])
class AppNotificationDao extends DatabaseAccessor<AppDatabase>
    with _$AppNotificationDaoMixin {
  AppNotificationDao(super.db);

  Future<List<AppNotificationRecord>> getAllNotifications() {
    return (select(
      appNotificationRecords,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
  }

  Future<void> upsertNotification(
    AppNotificationRecordsCompanion notification,
  ) {
    return into(appNotificationRecords).insertOnConflictUpdate(notification);
  }

  Future<void> markAsRead(String id) {
    return (update(appNotificationRecords)..where((t) => t.id.equals(id)))
        .write(const AppNotificationRecordsCompanion(isRead: Value(true)));
  }
}
