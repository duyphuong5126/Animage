import 'package:url_launcher/url_launcher.dart';

openUrl(String url) {
  launchUrl(Uri.parse(url));
}

openEmail({
  required String address,
  required String subject,
  required String body,
}) {
  final Uri emailLaunchUri = Uri(
    scheme: 'mailto',
    path: 'address',
    query: _encodeQueryParameters(<String, String>{
      'subject': subject,
      'body': body,
    }),
  );
  launchUrl(emailLaunchUri);
}

String? _encodeQueryParameters(Map<String, String> params) {
  return params.entries
      .map((MapEntry<String, String> e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
}
