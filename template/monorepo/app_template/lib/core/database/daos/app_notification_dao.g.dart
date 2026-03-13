// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_notification_dao.dart';

// ignore_for_file: type=lint
mixin _$AppNotificationDaoMixin on DatabaseAccessor<AppDatabase> {
  $AppNotificationRecordsTable get appNotificationRecords =>
      attachedDatabase.appNotificationRecords;
  AppNotificationDaoManager get managers => AppNotificationDaoManager(this);
}

class AppNotificationDaoManager {
  final _$AppNotificationDaoMixin _db;
  AppNotificationDaoManager(this._db);
  $$AppNotificationRecordsTableTableManager get appNotificationRecords =>
      $$AppNotificationRecordsTableTableManager(
        _db.attachedDatabase,
        _db.appNotificationRecords,
      );
}
