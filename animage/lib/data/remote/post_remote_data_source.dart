import 'dart:convert';
import 'package:animage/data/remote/model/post_list.dart';
import 'package:animage/utils/log.dart';
import 'package:http/http.dart';
import 'package:animage/data/remote/api_constant.dart';
import 'package:animage/domain/entity/post.dart';

abstract class PostRemoteDataSource {
  Future<List<Post>> getPostList(int page);

  Future<List<Post>> searchPostsByTag(String tag, int page);
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  static const String basePostUrl =
      '${ApiConstant.baseUrl}/${ApiConstant.post}?${ApiConstant.apiVersionParam}=${ApiConstant.apiVersion}';

  static const int requestTimeOut = 60;

  static const String tag = 'PostRemoteDataSourceImpl';

  @override
  Future<List<Post>> getPostList(int page) async {
    String url = '$basePostUrl&${ApiConstant.page}=$page';
    Future<List<Post>> result;
    try {
      Response response = await get(Uri.parse(url))
          .timeout(const Duration(seconds: requestTimeOut));
      PostList postList = PostList.fromJson(jsonDecode(response.body));
      Log.d(tag,
          '\n-------------------\nGET $url\nResult: ${response.statusCode} - ${postList.posts.map((e) => e.id)}\n-------------------');
      result = Future.value(postList.posts);
    } catch (e) {
      Log.d(
          tag, '\n-------------------\nGET $url\nError: $e\n-------------------');
      result = Future.value([]);
    }
    return result;
  }

  @override
  Future<List<Post>> searchPostsByTag(String tag, int page) async {
    String url = '$basePostUrl&${ApiConstant.tags}=$tag&${ApiConstant.page}=$page';
    Future<List<Post>> result;
    try {
      Response response = await get(Uri.parse(url))
          .timeout(const Duration(seconds: requestTimeOut));
      PostList postList = PostList.fromJson(jsonDecode(response.body));
      Log.d(tag,
          '\n-------------------\nGET $url\nResult: ${response.statusCode} - ${postList.posts.map((e) => e.id)}\n-------------------');
      result = Future.value(postList.posts);
    } catch (e) {
      Log.d(
          tag, '\n-------------------\nGET $url\nError: $e\n-------------------');
      result = Future.value([]);
    }
    return result;
  }
}
