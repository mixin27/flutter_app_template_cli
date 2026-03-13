// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campaign_dao.dart';

// ignore_for_file: type=lint
mixin _$CampaignDaoMixin on DatabaseAccessor<AppDatabase> {
  $CampaignRecordsTable get campaignRecords => attachedDatabase.campaignRecords;
  CampaignDaoManager get managers => CampaignDaoManager(this);
}

class CampaignDaoManager {
  final _$CampaignDaoMixin _db;
  CampaignDaoManager(this._db);
  $$CampaignRecordsTableTableManager get campaignRecords =>
      $$CampaignRecordsTableTableManager(
        _db.attachedDatabase,
        _db.campaignRecords,
      );
}
