import 'package:animage/domain/entity/post.dart';

class PostList {
  late List<Post> posts;

  PostList({required this.posts});

  PostList.fromJson(Map<String, dynamic> json) {
    posts = [];
    json['posts'].forEach((v) {
      posts.add(Post.fromJson(v));
    });
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['posts'] = posts.map((v) => v.toJson()).toList();
    return data;
  }
}
