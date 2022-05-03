class Artist {
  int id = -1;
  String name = '';
  int? aliasId;
  int? groupId;
  List<String> urls = [];

  Artist(
      {required this.id,
      required this.name,
      this.aliasId,
      this.groupId,
      this.urls = const []});

  Artist.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? -1;
    name = json['name'];
    aliasId = json['alias_id'];
    groupId = json['group_id'];
    urls = json['urls'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['alias_id'] = aliasId;
    data['group_id'] = groupId;
    data['urls'] = urls;
    return data;
  }
}
