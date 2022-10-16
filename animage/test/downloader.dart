import 'dart:io';

import 'package:animage/domain/entity/post.dart';
import 'package:animage/domain/use_case/search_posts_by_tags_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';

SearchPostsByTagsUseCase useCase = SearchPostsByTagsUseCaseImpl();

const String imagesFolder = 'images';
const Iterable<String> artists = [
  'foria_sensei',
  'etsunami_kumita',
  'twinbox',
  'akira_shiun',
  'kusana_(dudqja602)',
  'gweda'
];

void main() {
  test('Fetching all post of tag', () async {
    for (String artist in artists) {
      await _downloadAllPosts(artist: artist);
    }
  });
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
      List<Post> postList = await useCase.execute([artist], page);
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
