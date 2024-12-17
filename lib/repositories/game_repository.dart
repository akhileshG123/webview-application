import 'package:webview_application/models/game.dart';

class GameRepository {
  List<Game> getDummyGames() {
    return [
      Game(id: '1', name: 'Super Adventure', description: 'An epic adventure game'),
      Game(id: '2', name: 'Space Warriors', description: 'Intergalactic battle royale'),
      Game(id: '3', name: 'Fantasy Quest', description: 'Medieval fantasy RPG'),
      Game(id: '4', name: 'Racing Legends', description: 'High-speed racing simulation'),
    ];
  }
}