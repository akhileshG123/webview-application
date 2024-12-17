import 'package:webview_application/models/platform.dart';

class PlatformRepository {
  List<GamePlatform> getPlatforms() {
    return [
      GamePlatform(
        id: '1',
        name: 'Steam',
        url: 'https://store.steampowered.com',
      ),
      GamePlatform(
        id: '2',
        name: 'Epic Games',
        url: 'https://www.epicgames.com',
      ),
      GamePlatform(
        id: '3',
        name: 'GOG',
        url: 'https://www.gog.com',
      ),
    ];
  }
}