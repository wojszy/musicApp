import 'dart:convert';
import 'package:alan_voice/alan_voice.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musicapp/model/player_model.dart';
import 'package:musicapp/screens/home_screen.dart';
import 'package:provider/provider.dart';

import '../helper/data.dart';
import '../model/category.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:musicapp/model/category.dart';
import 'package:musicapp/model/song.dart';

class CategoryMusic extends StatefulWidget {
  final String category;
  final List<MySong> songs;
  final String imageUrl;

  CategoryMusic({required this.category, required this.songs, required this.imageUrl});

  @override
  State<CategoryMusic> createState() => _CategoryMusicState();
}

class _CategoryMusicState extends State<CategoryMusic> {
  late Color _selectedColor;
  bool _isPlaying = false;
  String selectedSong = '';
  String songName = '';
  String songArtist = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerModel>(
      builder: (context, playerModel, child) => Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
            Colors.deepPurple.shade800,
            Colors.deepPurple.shade200,
          ])),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(
                  'Playlist ' + widget.category,
                )),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Image.network(
                      widget.imageUrl,
                      height: MediaQuery.of(context).size.height * 0.3,
                      width: MediaQuery.of(context).size.height * 0.3,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _PlayOrShuffleSwitch(),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: buildSongs(widget.songs, widget.category, playerModel),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  SizedBox(
                      height: 30,
                      child: StreamBuilder(
                        stream: playerModel.audioPlayer.sequenceStream,
                        builder: (context, snapshot) {
                          if (playerModel.audioPlayer.currentIndex == null) {
                            return Text('');
                          } else {
                            songArtist = playerModel.songs[playerModel.audioPlayer.currentIndex!.toInt()].artist;
                            songName = playerModel.songs[playerModel.audioPlayer.currentIndex!.toInt()].name;

                            playerModel.changeMusic();
                            return Text('Current Playing: $songArtist - $songName');
                          }
                        },
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                          onTap: () {
                            if (playerModel.isPlaying) {
                              playerModel.audioPlayer.seekToPrevious();

                              if (playerModel.index == 0) {
                                playerModel.audioPlayer.seek(Duration.zero, index: 0);
                              } else {
                                playerModel.decrementIndex();
                              }
                            }
                          },
                          child: Icon(Icons.arrow_back_ios_outlined)),
                      SizedBox(
                          child: playerModel.audioPlayer.playing
                              ? GestureDetector(
                                  child: Icon(Icons.pause),
                                  onTap: () {
                                    if (playerModel.isPlaying) {
                                      playerModel.pauseMusic();
                                    }
                                  },
                                )
                              : GestureDetector(
                                  child: Icon(Icons.play_arrow),
                                  onTap: () {
                                    playerModel.audioPlayer.play();
                                    setState(() {
                                      playerModel.isPlaying = true;
                                    });
                                  })),
                      InkWell(
                          onTap: () {
                            if (playerModel.isPlaying) {
                              playerModel.audioPlayer.seekToNext();

                              playerModel.incrementIndex();
                              if (playerModel.index == 0) {
                                playerModel.audioPlayer.seek(Duration.zero, index: 0);
                              }
                            }
                          },
                          child: Icon(Icons.arrow_forward_ios_outlined)),
                    ],
                  )
                ]),
              ),
            ),
          )),
    );
  }

  Widget buildSongs(List<MySong> songs, String category, PlayerModel playerModel) {
    List<AudioSource> songPlaylist = [];

    songs.removeWhere((element) => element.category != category);
    for (var song in songs) {
      if (song.category == category) {
        songPlaylist.add(
          AudioSource.uri(Uri.parse(song.url)),
        );
      }
    }

    var playlist = ConcatenatingAudioSource(useLazyPreparation: true, shuffleOrder: DefaultShuffleOrder(), children: songPlaylist);
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: songs.length,
      itemBuilder: (context, index) {
        return songs[index].category == category
            ? Card(
                child: ListTile(
                onTap: () {
                  playerModel.ChangePlayerState(songs, index);

                  playerModel.stopMusic();
                  if (playerModel.audioPlayer.playing) {
                    playerModel.audioPlayer.stop();
                  } else {
                    playerModel.playMusic(playlist, index);
                  }
                },
                tileColor: Colors.purple.shade300,
                leading: CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(songs[index].image),
                ),
                title: Text(songs[index].artist, style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text(songs[index].name),
              ))
            : Container();
      },
    );
  }
}

class _PlayOrShuffleSwitch extends StatefulWidget {
  const _PlayOrShuffleSwitch({
    Key? key,
  }) : super(key: key);

  @override
  State<_PlayOrShuffleSwitch> createState() => _PlayOrShuffleSwitchState();
}

class _PlayOrShuffleSwitchState extends State<_PlayOrShuffleSwitch> {
  bool isPlay = true;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Consumer<PlayerModel>(
        builder: (context, playerModel, child) => GestureDetector(
              onTap: () {
                playerModel.onShuffleButtonPressed();
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 50,
                  width: width,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15.0)),
                  child: Stack(children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 100),
                      left: playerModel.isShuffle == false ? 0 : width * 0.45,
                      child: Container(
                        height: 50,
                        width: width * 0.47,
                        decoration: BoxDecoration(color: Colors.deepPurple, borderRadius: BorderRadius.circular(15.0)),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Center(
                                    child: Text(
                                      'Play',
                                      style:
                                          TextStyle(color: playerModel.isShuffle == false ? Colors.white : Colors.deepPurple, fontSize: 17),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Icon(Icons.play_circle, color: playerModel.isShuffle == false ? Colors.white : Colors.deepPurple)
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Text(
                                  'Shuffle',
                                  style: TextStyle(color: playerModel.isShuffle == false ? Colors.deepPurple : Colors.white, fontSize: 17),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(Icons.shuffle, color: playerModel.isShuffle == false ? Colors.deepPurple : Colors.white)
                            ],
                          ),
                        )
                      ],
                    ),
                  ]),
                ),
              ),
            ));
  }
}
