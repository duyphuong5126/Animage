import 'package:animage/domain/entity/post.dart';

class ViewOriginalUiModel {
  final List<Post> posts;

  const ViewOriginalUiModel({required this.posts});
}

class ViewOriginalUiModelBuilder {
  final List<Post> posts = [];

  void addPost(Post post) {
    posts.add(post);
  }

  void addPosts(Iterable<Post> postList) {
    posts.addAll(postList);
  }

  ViewOriginalUiModel build() => ViewOriginalUiModel(posts: posts);
}
