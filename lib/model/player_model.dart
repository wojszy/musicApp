import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musicapp/model/song.dart';
import 'package:volume_control/volume_control.dart';

class PlayerModel extends ChangeNotifier {
  List<MySong> songs = [MySong(id: 0, name: '', url: '', artist: '', image: '', category: '')];
  int index = 0;
  AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool enable = false;
  bool isShuffle = false;

  void changeMusic() async {
    audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {}

      notifyListeners();
    });
  }

  void onShuffleButtonPressed() async {
    enable = !audioPlayer.shuffleModeEnabled;
    if (enable) {
      await audioPlayer.shuffle();
    }
    await audioPlayer.setShuffleModeEnabled(enable);
    isShuffle = !isShuffle;
    notifyListeners();
  }

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
