import 'package:animage/bloc/data_cubit.dart';
import 'package:animage/domain/entity/post.dart';
import 'package:animage/feature/ui_model/navigation_bar_expand_status.dart';
import 'package:animage/utils/cupertino_context_extension.dart';
import 'package:animage/widget/favorite_checkbox.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class PostDetailsPageIOS extends StatefulWidget {
  const PostDetailsPageIOS({Key? key}) : super(key: key);

  @override
  State<PostDetailsPageIOS> createState() => _PostDetailsPageIOSState();
}

class _PostDetailsPageIOSState extends State<PostDetailsPageIOS> {
  final DataCubit<NavigationBarExpandStatus> _expandStatusCubit =
      DataCubit(NavigationBarExpandStatus.expanded);

  static const double _defaultGalleryHeight = 100;

  @override
  Widget build(BuildContext context) {
    Post post = ModalRoute.of(context)?.settings.arguments as Post;

    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: PlatformText('ID: ${post.id}'),
          trailing: BlocBuilder(
              bloc: _expandStatusCubit,
              builder: (context, expandStatus) {
                return FavoriteCheckbox(
                    size: 28,
                    color: context.primaryColor,
                    isFavorite: false,
                    onFavoriteChanged: (newFavStatus) {});
              }),
        ),
        child: SafeArea(
          child: ListView(
            children: [
              CachedNetworkImage(
                imageUrl: post.sampleUrl ?? '',
                width: double.infinity,
                height: post.sampleHeight?.toDouble() ?? _defaultGalleryHeight,
                alignment: Alignment.topCenter,
                fit: BoxFit.fitWidth,
              ),
            ],
          ),
        ));
  }
}
