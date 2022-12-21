import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musicapp/model/song.dart';
import 'package:volume_control/volume_control.dart';

class PlayerModel extends ChangeNotifier {
  List<MySong> songs = [MySong(id: 0, name: '', url: '', artist: '', image: '', category: '')];
  int index = 0;
  AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  // Widget buildSongs(List<MySong> songs, String category, playerModel)
  //   List<AudioSource> songPlaylist = [];
  //   for (var song in songs) {
  //     if (song.category == category) {
  //       songPlaylist.add(
  //         AudioSource.uri(Uri.parse(song.url)),
  //       );
  //       //   print(song.name);
  //     }
  //   }

  // final playlist = ConcatenatingAudioSource(
  //     // Start loading next item just before reaching it
  //     useLazyPreparation: true,
  //     // Customise the shuffle algorithm
  //     shuffleOrder: DefaultShuffleOrder(),
  //     // Specify the playlist items
  //     children: categoryPlaylist);


  void stopMusic() {
    isPlaying = false;
    audioPlayer.stop();
    notifyListeners();
  }

  void pauseMusic() {
    isPlaying = false;
    audioPlayer.pause();
    notifyListeners();
  }

  void unPauseMusic() {
    isPlaying = true;
    audioPlayer.play();
    notifyListeners();
  }

  void playMusic(playlist, newIndex) {
    index = newIndex;
    isPlaying = true;
    audioPlayer.setAudioSource(playlist, initialIndex: index, initialPosition: Duration.zero);
    audioPlayer.play();

    notifyListeners();
  }

  void playMusicCategory(playlist) {
    //_audioPlayer.setUrl(url);
    isPlaying = true;
    audioPlayer.setAudioSource(playlist, initialPosition: Duration.zero);
    audioPlayer.play();

    notifyListeners();
  }

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
