import 'package:flutter/widgets.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class TextWithLinks extends StatefulWidget {
  final String text;
  final TextStyle? textStyle;
  final TextStyle? linkStyle;

  const TextWithLinks(
      {Key? key, required this.text, this.textStyle, this.linkStyle})
      : super(key: key);

  @override
  State<TextWithLinks> createState() => _TextWithLinksState();
}

class _TextWithLinksState extends State<TextWithLinks> {
  @override
  Widget build(BuildContext context) {
    return Linkify(
      onOpen: (link) async {
        Uri uri = Uri.parse(link.url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          throw 'Could not launch $link';
        }
      },
      text: widget.text,
      style: widget.textStyle,
      linkStyle: widget.linkStyle,
    );
  }
}
