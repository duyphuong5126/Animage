import 'dart:convert';
import 'package:animage/data/remote/model/post_list.dart';
import 'package:animage/domain/entity/gallery_level.dart';
import 'package:animage/utils/log.dart';
import 'package:http/http.dart';
import 'package:animage/data/remote/api_constant.dart';
import 'package:animage/domain/entity/post.dart';

abstract class PostRemoteDataSource {
  Future<List<Post>> getPostList(int page, GalleryLevel galleryLevel);

  Future<List<Post>> searchPostsByTag(
      List<String> tags, int page, GalleryLevel galleryLevel);
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  static const String basePostUrl =
      '${ApiConstant.baseUrl}/${ApiConstant.post}?${ApiConstant.apiVersionParam}=${ApiConstant.apiVersion}';

  static const int requestTimeOut = 30;

  static const String tag = 'PostRemoteDataSourceImpl';

  static String _getBasePostUrl(GalleryLevel level) {
    Log.d('PostRemoteDataSourceImpl>>>', 'level=${level.level}');
    return basePostUrl +
        (level.level == 0
            ? '&${ApiConstant.tags}=rating:safe'
            : level.level == 1
                ? '&${ApiConstant.tags}=rating:questionable'
                : '');
  }

  @override
  Future<List<Post>> getPostList(int page, GalleryLevel galleryLevel) async {
    String url = '${_getBasePostUrl(galleryLevel)}&${ApiConstant.page}=$page';
    Future<List<Post>> result;
    try {
      Response response = await get(Uri.parse(url))
          .timeout(const Duration(seconds: requestTimeOut));
      PostList postList = PostList.fromJson(jsonDecode(response.body));
      Log.d(tag,
          '\n-------------------\nGET $url\nResult: ${response.statusCode} - ${postList.posts.map((e) => e.id)}\n-------------------');
      result = Future.value(postList.posts);
    } catch (e) {
      Log.d(tag,
          '\n-------------------\nGET $url\nError: $e\n-------------------');
      result = Future.value([]);
    }
    return result;
  }

  @override
  Future<List<Post>> searchPostsByTag(
      List<String> tags, int page, GalleryLevel galleryLevel) async {
    String normalizedTags = tags.map((tagItem) {
      Iterable<String> fragments =
          tagItem.trim().split(' ').where((fragment) => fragment.isNotEmpty);
      return fragments.join('_');
    }).join('+');

    String url =
        '${_getBasePostUrl(galleryLevel)}${galleryLevel.level == 2 ? '&${ApiConstant.tags}=' : '+'}$normalizedTags&${ApiConstant.page}=$page';
    Future<List<Post>> result;
    try {
      Response response = await get(Uri.parse(url))
          .timeout(const Duration(seconds: requestTimeOut));
      int code = response.statusCode;
      final message = response.body;
      Log.d(tag, 'Test>>> code=$code, message=$message');
      PostList postList = PostList.fromJson(jsonDecode(response.body));
      Log.d(tag,
          '\n-------------------\nGET $url\nResult: ${response.statusCode} - ${postList.posts.map((e) => e.id)}\n-------------------');
      result = Future.value(postList.posts);
    } catch (e) {
      Log.d(tag,
          '\n-------------------\nGET $url\nError: $e\n-------------------');
      result = Future.value([]);
    }
    return result;
  }
}
