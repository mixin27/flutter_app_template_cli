import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/campaign_records.dart';

part 'campaign_dao.g.dart';

@DriftAccessor(tables: [CampaignRecords])
class CampaignDao extends DatabaseAccessor<AppDatabase>
    with _$CampaignDaoMixin {
  CampaignDao(super.db);

  Future<List<CampaignRecord>> getAllCampaigns() {
    return (select(
      campaignRecords,
    )..orderBy([(t) => OrderingTerm.desc(t.startsAt)])).get();
  }

  Future<void> upsertCampaign(CampaignRecordsCompanion campaign) {
    return into(campaignRecords).insertOnConflictUpdate(campaign);
  }
}
