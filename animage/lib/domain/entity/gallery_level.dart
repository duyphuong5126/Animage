import 'package:hive/hive.dart';

part 'gallery_level.g.dart';

@HiveType(typeId: 1)
class GalleryLevel {
  @HiveField(0)
  final int level;

  @HiveField(1)
  final int expirationTime;

  const GalleryLevel({required this.level, required this.expirationTime});

  static const Map<int, Duration> levelExpirationMap = {
    1: Duration(minutes: 2),
    2: Duration(minutes: 5)
  };

  static const Map<int, int> levelChallengesMap = {1: 1, 2: 2};

  static const Map<int, int> levelRequiredFavoriteMap = {1: 5, 2: 10};
}
