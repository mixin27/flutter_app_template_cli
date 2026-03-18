import '../../../../data/database/app_database.dart';

class ProfileLocalDataSource {
  ProfileLocalDataSource(this._dao);

  final ProfilesDao _dao;

  Future<ProfileRecord?> getProfile(String id) => _dao.getProfile(id);

  Future<void> saveProfile(ProfileRecord record) => _dao.upsertProfile(record);

  Future<void> clearProfile(String id) => _dao.clearProfile(id);
}
