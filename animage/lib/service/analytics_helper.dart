import 'package:animage/utils/log.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsHelper {
  static const String _tag = 'AnalyticsHelper';

  static const String _eventAddFavorite = 'add_favorite';
  static const String _eventRemoveFavorite = 'remove_favorite';
  static const String _eventViewFavoriteList = 'view_favorite_list';
  static const String _eventDownload = 'download';
  static const String _eventDownloadChildren = 'download_children';
  static const String _eventViewGridGallery = 'view_grid_gallery';
  static const String _eventViewListGallery = 'view_list_gallery';
  static const String _eventViewGridFavorite = 'view_grid_favorite';
  static const String _eventViewListFavorite = 'view_list_favorite';

  static const String _paramPostId = 'post_id';

  static void setScreen(String screenName) async {
    Log.d(_tag, 'setScreen - $screenName');
    //FirebaseAnalytics.instance.setCurrentScreen(screenName: screenName);
  }

  static void search(String searchTerm) async {
    String normalizedSearchTerm =
        searchTerm.trim().toLowerCase().replaceAll(' ', '_');
    Log.d(_tag, 'search - $normalizedSearchTerm');
    //FirebaseAnalytics.instance.logSearch(searchTerm: normalizedSearchTerm);
  }

  static void addFavorite() async {
    Log.d(_tag, 'addFavorite');
    //FirebaseAnalytics.instance.logEvent(name: _eventAddFavorite);
  }

  static void removeFavorite() async {
    Log.d(_tag, 'removeFavorite');
    //FirebaseAnalytics.instance.logEvent(name: _eventRemoveFavorite);
  }

  static void viewFavoriteList() async {
    Log.d(_tag, 'viewFavoriteList');
    //FirebaseAnalytics.instance.logEvent(name: _eventViewFavoriteList);
  }

  static void download(int postId) async {
    Log.d(_tag, 'download - $postId');
    /*FirebaseAnalytics.instance
        .logEvent(name: _eventDownload, parameters: {_paramPostId: postId});*/
  }

  static void downloadChildren(int postId) async {
    Log.d(_tag, 'downloadChildren - $postId');
    /*FirebaseAnalytics.instance.logEvent(
        name: _eventDownloadChildren, parameters: {_paramPostId: postId});*/
  }

  static void viewGridGallery() async {
    Log.d(_tag, 'viewGridGallery');
    //FirebaseAnalytics.instance.logEvent(name: _eventViewGridGallery);
  }

  static void viewListGallery() async {
    Log.d(_tag, 'viewListGallery');
    //FirebaseAnalytics.instance.logEvent(name: _eventViewListGallery);
  }

  static void viewGridFavorite() async {
    Log.d(_tag, 'viewGridFavorite');
    //FirebaseAnalytics.instance.logEvent(name: _eventViewGridFavorite);
  }

  static void viewListFavorite() async {
    Log.d(_tag, 'viewListFavorite');
    //FirebaseAnalytics.instance.logEvent(name: _eventViewListFavorite);
  }
}
