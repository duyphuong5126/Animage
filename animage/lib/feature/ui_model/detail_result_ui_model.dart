class DetailResultUiModel {
  final Map<int, bool> favoriteMap;
  final List<String> selectedTags;

  const DetailResultUiModel(
      {required this.favoriteMap, required this.selectedTags});
}

class DetailResultBuilder {
  final Map<int, bool> favoriteMap = {};
  final List<String> selectedTags = [];

  DetailResultBuilder putFavoriteEntry(int postId, bool isFavorite) {
    favoriteMap[postId] = isFavorite;
    return this;
  }

  DetailResultBuilder putSelectedTag(String tag) {
    if (tag.isNotEmpty && !selectedTags.contains(tag)) {
      selectedTags.add(tag);
    }
    return this;
  }

  DetailResultUiModel build() =>
      DetailResultUiModel(favoriteMap: favoriteMap, selectedTags: selectedTags);
}
