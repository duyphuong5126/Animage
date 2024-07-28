import 'package:animage/constant.dart';
import 'package:animage/feature/setting/setting_cubit.dart';
import 'package:animage/utils/material_context_extension.dart';
import 'package:animage/utils/url_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';

class SettingsPageAndroid extends StatefulWidget {
  const SettingsPageAndroid({Key? key}) : super(key: key);

  @override
  State<SettingsPageAndroid> createState() => _SettingsPageAndroidState();
}

class _SettingsPageAndroidState extends State<SettingsPageAndroid> {
  RewardedAd? _firstRewardedAd;
  RewardedAd? _secondRewardedAd;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingCubit()..init(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: BlocBuilder<SettingCubit, SettingState>(
            builder: (context, SettingState state) {
              return state is SettingInitializedState
                  ? Text(state.appName)
                  : const Text('Animage');
            },
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: halfSpace,
            vertical: space1,
          ),
          children: const [
            _GeneralInfoSection(),
            SizedBox(height: space2),
            _ContactInfoSection(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _firstRewardedAd?.dispose();
    _secondRewardedAd?.dispose();
  }
}

class _GeneralInfoSection extends StatelessWidget {
  const _GeneralInfoSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingCubit, SettingState>(
      builder: (context, SettingState state) {
        return switch (state) {
          SettingInitialState() => const SizedBox.shrink(),
          SettingInitializedState() => _Section(
              title: 'General Info',
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _widgetsWithDividers([
                  _InfoItem(
                    title: 'About this app',
                    description: state.appName,
                  ),
                  _InfoItem(title: 'Version', description: state.appVersion),
                  _InfoItem(
                    title: 'Gallery art type',
                    description: _galleryLevel(
                      state.galleryLevel,
                      state.galleryLevelExpirationTime,
                    ),
                  ),
                ]),
              ),
            )
        };
      },
    );
  }

  String _galleryLevel(int level, DateTime? expirationTime) {
    final DateFormat formatter = DateFormat('MMM d, yyyy - HH:mm:ss');
    final expirationLabel = expirationTime != null
        ? ' \n(Available until: ${formatter.format(expirationTime)})'
        : '';
    return level >= 2
        ? 'Adult art supported$expirationLabel'
        : level == 1
            ? 'Mature art supported$expirationLabel'
            : 'Normal art';
  }
}

class _ContactInfoSection extends StatelessWidget {
  const _ContactInfoSection();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Contact',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _widgetsWithDividers([
          _ExternalInfoItem(
            title: 'Twitter (X)',
            description: '@nonoka5126',
            onTap: () => openUrl('https://twitter.com/nonoka5126'),
          ),
          BlocBuilder<SettingCubit, SettingState>(
            builder: (context, SettingState state) {
              final versionTag = state is SettingInitializedState
                  ? '[${state.appVersion}]'
                  : '';
              final appNameTag =
                  state is SettingInitializedState ? '[${state.appName}]' : '';
              return _ExternalInfoItem(
                title: 'Email',
                description: 'nonoka9002@gmail.com',
                onTap: () => openEmail(
                  address: 'nonoka9002@gmail.com',
                  subject: '$appNameTag${versionTag}Request for support',
                  body:
                      'What happened:\n\nSteps to reproduce:\n\nOther info:\n\n',
                ),
              );
            },
          ),
        ]),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(left: space1),
          child: Text(title, style: context.subtitle2),
        ),
        Container(
          margin: const EdgeInsets.only(top: quarterSpace),
          padding: const EdgeInsets.symmetric(
            vertical: halfSpace,
            horizontal: space1,
          ),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(space1)),
            color: context.theme.cardColor,
          ),
          child: body,
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.bodyText1),
        const SizedBox(height: quarterSpace),
        Text(description, style: context.caption),
        const SizedBox(height: quarterSpace),
      ],
    );
  }
}

class _ExternalInfoItem extends StatelessWidget {
  const _ExternalInfoItem({
    required this.title,
    required this.description,
    required this.onTap,
  });

  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.bodyText1),
                const SizedBox(height: quarterSpace),
                Text(description, style: context.caption),
                const SizedBox(height: quarterSpace),
              ],
            ),
          ),
          const SizedBox(width: quarterSpace),
          const Icon(Icons.open_in_new, size: space1),
        ],
      ),
    );
  }
}

List<Widget> _widgetsWithDividers(Iterable<Widget> widgets) {
  List<Widget> result = [];
  int widgetCount = widgets.length;
  for (int index = 0; index < widgetCount; index++) {
    result.add(widgets.elementAt(index));
    if (index < widgetCount - 1) {
      result.add(const _InfoSectionDivider());
    }
  }
  return result;
}

class _InfoSectionDivider extends StatelessWidget {
  const _InfoSectionDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: halfSpace),
      child: Divider(
        height: 1,
        color: context.theme.dividerColor,
      ),
    );
  }
}
