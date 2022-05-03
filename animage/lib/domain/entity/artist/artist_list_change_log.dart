class ArtistListChangeLog {
  int currentVersionId = -1;
  String updatedAt = '';

  ArtistListChangeLog(
      {required this.currentVersionId, required this.updatedAt});

  ArtistListChangeLog.fromJson(Map<String, dynamic> json) {
    currentVersionId = json['current_version_id'] ?? -1;
    updatedAt = json['updated_at'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_version_id'] = currentVersionId;
    data['updated_at'] = updatedAt;
    return data;
  }
}
