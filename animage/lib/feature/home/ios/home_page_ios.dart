import 'package:animage/bloc/data_cubit.dart';
import 'package:animage/constant.dart';
import 'package:animage/feature/favorite/ios/favorite_page_ios.dart';
import 'package:animage/feature/gallery/ios/gallery_page_ios.dart';
import 'package:animage/utils/cupertino_context_extension.dart';
import 'package:flutter/cupertino.dart';

class HomePageIOS extends StatefulWidget {
  const HomePageIOS({Key? key}) : super(key: key);

  @override
  State<HomePageIOS> createState() => _HomePageIOSState();
}

class _HomePageIOSState extends State<HomePageIOS> {
  final DataCubit<int> _scrollToTopCubit = DataCubit(-1);

  int _currentIndex = 0;

  @override
  void dispose() {
    super.dispose();
    _scrollToTopCubit.closeAsync();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _tabs = [
      GalleryPageIOS(
        scrollToTopCubit: _scrollToTopCubit,
      ),
      // see the HomeTab class below
      const FavoritePageIOS()
      // see the SettingsTab class below
    ];
    Color selectedColor = context.isDark ? accentColorLight : accentColor;

    return CupertinoPageScaffold(
        child: CupertinoTabScaffold(
            tabBar: CupertinoTabBar(
              activeColor: selectedColor,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(
                    CupertinoIcons.home,
                    size: 24,
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                    icon: Icon(
                      CupertinoIcons.heart_fill,
                      size: 24,
                    ),
                    label: 'Favorite')
              ],
              onTap: (int index) {
                if (index == _currentIndex) {
                  _scrollToTopCubit.push(DateTime.now().millisecondsSinceEpoch);
                }
                _currentIndex = index;
              },
            ),
            tabBuilder: (context, int index) {
              return _tabs[index];
            }));
  }
}
