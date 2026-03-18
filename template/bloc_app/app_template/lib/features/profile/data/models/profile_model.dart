import '../../../../data/database/app_database.dart';
import '../../domain/entities/profile.dart';

class ProfileModel {
  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final DateTime updatedAt;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  factory ProfileModel.fromRecord(ProfileRecord record) {
    return ProfileModel(
      id: record.id,
      name: record.name,
      email: record.email,
      avatarUrl: record.avatarUrl,
      updatedAt: record.updatedAt,
    );
  }

  Profile toEntity() {
    return Profile(
      id: id,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      updatedAt: updatedAt,
    );
  }

  ProfileRecord toRecord() {
    return ProfileRecord(
      id: id,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      updatedAt: updatedAt,
    );
  }
}
