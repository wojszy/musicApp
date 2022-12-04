import 'package:flutter/cupertino.dart';
import 'package:musicapp/model/song.dart';

class PlayerModel extends ChangeNotifier {
  List<MySong> songs = [MySong(id: 0, name: '', url: '', artist: '', image: '', category: '')];
  int index = 0;
  void ChangePlayerState(newSongs, newIndex) {
    songs = newSongs;
    index = newIndex;

    notifyListeners();
  }

  void incrementIndex() {
    if (index < songs.length - 1) {
      index = index + 1;
    } else {
      index = 0;
    }
    notifyListeners();
  }

  void decrementIndex() {
    if (index < 0) {
      index = 0;
    } else {
      index = index - 1;
    }
    notifyListeners();
  }
}
