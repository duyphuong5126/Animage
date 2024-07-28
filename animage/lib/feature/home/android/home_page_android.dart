import 'package:animage/bloc/data_cubit.dart';
import 'package:animage/constant.dart';
import 'package:animage/feature/favorite/android/favorite_page_android.dart';
import 'package:animage/feature/gallery/android/gallery_page_android_v2.dart';
import 'package:animage/feature/setting/settings_page_android.dart';
import 'package:animage/service/analytics_helper.dart';
import 'package:animage/utils/material_context_extension.dart';
import 'package:flutter/material.dart';

class HomePageAndroid extends StatefulWidget {
  const HomePageAndroid({Key? key}) : super(key: key);

  @override
  State<HomePageAndroid> createState() => _HomePageState();
}

class _HomePageState extends State<HomePageAndroid> {
  static const int _defaultTabIndex = 0;
  int _selectedIndex = _defaultTabIndex;

  final DataCubit<int> _scrollToTopCubit = DataCubit(-1);

  @override
  void dispose() {
    super.dispose();
    _scrollToTopCubit.closeAsync();
  }

  @override
  Widget build(BuildContext context) {
    Color selectedColor = context.isDark ? accentColor : accentColorDark;
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const GalleryPageAndroidV2(),
          FavoritePageAndroid(scrollToTopCubit: _scrollToTopCubit),
          const SettingsPageAndroid(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Gallery',
            tooltip: 'Gallery',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
            tooltip: 'Favorite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About',
            tooltip: 'About',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: selectedColor,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: _onTabSelected,
      ),
    );
  }

  void _onTabSelected(int index) {
    if (index == 1) {
      AnalyticsHelper.viewFavoriteList();
    }
    if (index == _selectedIndex) {
      _scrollToTopCubit.push(DateTime.now().millisecondsSinceEpoch);
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }
}
