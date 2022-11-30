import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musicapp/screens/home_screen.dart';

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
  //List<CategoryModel> categories = <CategoryModel>[];
  String currentPlaying = '';
  getUrl(url) {
    setState(() {
      currentPlaying = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    AudioPlayer audioPlayer = AudioPlayer();
    // String? currentPlaying;
    return Container(
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
              // Text('Category: ' + widget.category, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
                child: buildSongs(widget.songs, widget.category, getUrl),
              ),
              const SizedBox(
                height: 30,
                child: Text(
                  'Current Playing:',
                  //textAlign: TextAlign.left,
                ),
              ),
              SizedBox(
                child: _CustomPlayer(),
              ),
              SizedBox(
                child: GestureDetector(
                    onTap: () {
                      print(currentPlaying);
                      
                    },
                    child: Icon(Icons.play_arrow)),
              ),
            ]),
          ))),
    );
  }

  Widget buildSongs(List<MySong> songs, String category, getUrl) {
    List<AudioSource> songPlaylist = [];
    for (var song in songs) {
      if (song.category == category) {
        songPlaylist.add(
          AudioSource.uri(Uri.parse(song.url)),
        );
       //   print(song.name);
      }
    }
    final playlist = ConcatenatingAudioSource(
        // Start loading next item just before reaching it
        useLazyPreparation: true,
        // Customise the shuffle algorithm
        shuffleOrder: DefaultShuffleOrder(),
        // Specify the playlist items
        children: songPlaylist);
    return ListView.builder(
      // physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: songs.length,
      itemBuilder: (context, index) {
        return songs[index].category == category
            ? Card(
                child: ListTile(
                onTap: () {
                  getUrl(songs[index].url);
                  
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
    return GestureDetector(
      onTap: () {
        setState(() {
          isPlay = !isPlay;
        });
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
              left: isPlay ? 0 : width * 0.45,
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
                              style: TextStyle(color: isPlay ? Colors.white : Colors.deepPurple, fontSize: 17),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(Icons.play_circle, color: isPlay ? Colors.white : Colors.deepPurple)
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
                          style: TextStyle(color: isPlay ? Colors.deepPurple : Colors.white, fontSize: 17),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.shuffle, color: isPlay ? Colors.deepPurple : Colors.white)
                    ],
                  ),
                )
              ],
            ),
          ]),
        ),
      ),
    );
  }
}

class _CustomPlayer extends StatelessWidget {
  const _CustomPlayer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.1,
        alignment: AlignmentDirectional.bottomEnd,
        decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(0.5)),
        child: Column(
          children: [
            Slider.adaptive(
              value: 0,
              onChanged: (value) {},
            ),
          ],
        ));
  }
}
