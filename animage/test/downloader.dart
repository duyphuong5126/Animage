import 'dart:io';

import 'package:animage/data/post_repository_impl.dart';
import 'package:animage/domain/entity/gallery_level.dart';
import 'package:animage/domain/entity/post.dart';
import 'package:animage/domain/post_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';

PostRepository repo = PostRepositoryImpl();

const String imagesFolder = 'images';
const Iterable<String> artists = [
  /*'gweda',
  'twinbox',
  'akira_shiun',
  'kusana_(dudqja602)',
  're:shimashima',
  'osisio',
  'foria_sensei',
  'etsunami_kumita',
  'mokomono',
  'norino',
  'ramchi',*/
  'ginhaha'
];

void main() async {
  for (String artist in artists) {
    await _downloadAllPosts(artist: artist);
  }
}

Future<void> _downloadAllPosts({required String artist}) async {
  print(
      '------------------- Start downloading all posts from artist $artist -------------------');
  bool hasData = false;
  int page = 1;
  List<Post> retryList = [];
  int total = 0;
  do {
    try {
      List<Post> postList = await repo.searchPostsByTagDebug(
        [artist],
        page,
        GalleryLevel(
          level: 2,
          expirationTime:
              GalleryLevel.levelExpirationMap[2]?.inMilliseconds ?? 0,
        ),
      );
      hasData = postList.isNotEmpty;
      print('Page $page - item=${postList.length}');
      for (Post post in postList) {
        bool success = await _downloadFile(post, artist);
        if (success) {
          total++;
        } else {
          retryList.add(post);
        }
      }
    } catch (e) {
      print('Could not download page $page from artist $artist with error $e');
    }
    page++;
  } while (hasData);

  if (retryList.isNotEmpty) {
    print('Retry downloading ${retryList.length} item(s)');
    for (Post post in retryList) {
      bool success = await _downloadFile(post, artist);
      if (success) {
        total++;
      }
    }
  }

  print(
      '------------------- End downloading all posts from artist $artist - Total: $total -------------------');
}

Future<bool> _downloadFile(Post post, String artist) async {
  String? fileUrl = post.fileUrl;
  bool result = false;
  if (fileUrl != null && fileUrl.isNotEmpty) {
    try {
      Response response =
          await get(Uri.parse(fileUrl)).timeout(const Duration(minutes: 5));
      if (response.statusCode == HttpStatus.ok) {
        String fileName = fileUrl.split('/').last;
        if (fileName.isEmpty) {
          fileName = '${post.id}.png';
        }

        String filePath = '$imagesFolder/$artist/$fileName';
        File targetFile = await File(filePath).create(recursive: true);
        targetFile.writeAsBytesSync(response.bodyBytes, flush: true);
        result = true;

        print('Post ${post.id} is stored in file $filePath');
      } else {
        print(
            'Could not download post with status code ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Could not download post ${post.id} with error $e');
      result = false;
    }
  }
  return result;
}
