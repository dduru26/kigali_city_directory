import 'package:url_launcher/url_launcher.dart';

class MapService {
  Future<bool> openDirections({
    required double latitude,
    required double longitude,
  }) async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude',
    );

    if (await canLaunchUrl(url)) {
      return launchUrl(url, mode: LaunchMode.externalApplication);
    }

    return false;
  }
}
