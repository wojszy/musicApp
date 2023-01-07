import 'dart:developer';

import 'package:alan_voice/alan_voice.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musicapp/helper/data.dart';
import 'package:musicapp/screens/category_screen.dart';
import 'package:provider/provider.dart';
import '../model/player_model.dart';
import '../widgets/section_header.dart';
import '../model/category.dart';
import '../model/song.dart';
import 'package:volume_control/volume_control.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CategoryModel> categories = <CategoryModel>[];
  List<MySong> songs = <MySong>[];
  String songName = '';
  String songArtist = '';
  // static AudioPlayer _audioPlayer = AudioPlayer();
  @override
  void initState() {
    super.initState();
    setupAlan();
    categories = getCategories();
    fetchSongsList();
    initVolumeState();
  }

//init volume_control plugin
  Future<void> initVolumeState() async {
    if (!mounted) return;

    //read the current volume
    _val = await VolumeControl.volume;
    setState(() {});
  }

  late double _val;
  fetchSongsList() async {
    final songJson = await rootBundle.loadString("assets/songs.json");
    songs = MySongList.fromJson(songJson).songs;
    print(songs);
    setState(() {});
  }

  setupAlan() {
    AlanVoice.addButton("a0bfd35a2c6bc34391f94ad34f381b302e956eca572e1d8b807a3e2338fdd0dc/stage",
        buttonAlign: AlanVoice.BUTTON_ALIGN_RIGHT);

    AlanVoice.onCommand.add((command) => _handleCommand(command.data, PlayerModel(), CategoryModel()));
  }

  void _handleCommand(Map<String, dynamic> response, PlayerModel playerModel, CategoryModel categoryModel) async {
    switch (response["command"]) {
      case "pause":
        Provider.of<PlayerModel>(context, listen: false).pauseMusic();
        break;
      case "unpause":
        Provider.of<PlayerModel>(context, listen: false).unPauseMusic();
        break;
      case "shuffle":
        Provider.of<PlayerModel>(context, listen: false).enable = true;
        if (Provider.of<PlayerModel>(context, listen: false).enable) {
          await Provider.of<PlayerModel>(context, listen: false).audioPlayer.shuffle();
        }
        await Provider.of<PlayerModel>(context, listen: false)
            .audioPlayer
            .setShuffleModeEnabled(Provider.of<PlayerModel>(context, listen: false).enable);
        Provider.of<PlayerModel>(context, listen: false).isShuffle = true;
        Provider.of<PlayerModel>(context, listen: false).notifyListeners();
        break;
      case "unshuffle":
        Provider.of<PlayerModel>(context, listen: false).enable = false;
        if (Provider.of<PlayerModel>(context, listen: false).enable) {
          await Provider.of<PlayerModel>(context, listen: false).audioPlayer.shuffle();
        }
        await Provider.of<PlayerModel>(context, listen: false)
            .audioPlayer
            .setShuffleModeEnabled(Provider.of<PlayerModel>(context, listen: false).enable);
        Provider.of<PlayerModel>(context, listen: false).isShuffle = false;
        Provider.of<PlayerModel>(context, listen: false).notifyListeners();
        break;
      case "volumeUp":
        double val = _val * 1.2;
        VolumeControl.setVolume(val);
        print("current val: $_val");

        break;
      case "volumeDown":
        double val = _val * 0.8;
        VolumeControl.setVolume(val);
        print("current val: $_val");

        break;
      case "next":
        Provider.of<PlayerModel>(context, listen: false).audioPlayer.seekToNext();
        Provider.of<PlayerModel>(context, listen: false).incrementIndex();
        if (Provider.of<PlayerModel>(context, listen: false).index == 0) {
          Provider.of<PlayerModel>(context, listen: false).audioPlayer.seek(Duration.zero, index: 0);
        } else {}
        if (Provider.of<PlayerModel>(context, listen: false).audioPlayer.playing == false) {
          Provider.of<PlayerModel>(context, listen: false).isPlaying = true;
          Provider.of<PlayerModel>(context, listen: false).audioPlayer.play();
        }
        break;
      case "previous":
        Provider.of<PlayerModel>(context, listen: false).audioPlayer.seekToPrevious();

        if (Provider.of<PlayerModel>(context, listen: false).index == 0) {
          Provider.of<PlayerModel>(context, listen: false).audioPlayer.seek(Duration.zero, index: 0);
          Provider.of<PlayerModel>(context, listen: false).isPlaying = true;
          //_audioPlayer.seek(Duration.zero, index: 0);
        } else {
          Provider.of<PlayerModel>(context, listen: false).decrementIndex();
          if (Provider.of<PlayerModel>(context, listen: false).audioPlayer.playing == false) {
            Provider.of<PlayerModel>(context, listen: false).isPlaying = true;
            Provider.of<PlayerModel>(context, listen: false).audioPlayer.play();
          }
        }
        break;

      case "play_category":
        await fetchSongsList();
        final categoryAi = response["category"];
        List<AudioSource> categoryPlaylist_list = [];

        final CategoryModel cat = categories.firstWhere((element) => element.categoryName.toLowerCase() == categoryAi);
        if (cat == null) {
          print("Nie znaleziono");
        } else {
          final categoryImage = cat.imageUrl;
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => CategoryMusic(songs: songs, category: categoryAi, imageUrl: categoryImage)));

          Provider.of<PlayerModel>(context, listen: false).audioPlayer.pause();
          songs.removeWhere((element) => element.category != categoryAi);
          for (var song in songs) {
            if (song.category.toLowerCase() == categoryAi) {
              categoryPlaylist_list.add(AudioSource.uri(Uri.parse(song.url)));
            }
          }

          final categoryPlaylist =
              ConcatenatingAudioSource(useLazyPreparation: true, shuffleOrder: DefaultShuffleOrder(), children: categoryPlaylist_list);
          if (Provider.of<PlayerModel>(context, listen: false).isPlaying == true) {
            Provider.of<PlayerModel>(context, listen: false).stopMusic();
            Provider.of<PlayerModel>(context, listen: false).ChangePlayerState(songs, 0);
            Provider.of<PlayerModel>(context, listen: false).playMusic(categoryPlaylist, 0);
          } else {
            Provider.of<PlayerModel>(context, listen: false).ChangePlayerState(songs, 0);
            Provider.of<PlayerModel>(context, listen: false).playMusic(categoryPlaylist, 0);
          }
        }

        break;
      case "play_music":
        await fetchSongsList();
        final musicAi = response["music"];

        List<AudioSource> searchPlayList_list = [];
        Provider.of<PlayerModel>(context, listen: false).audioPlayer.pause();

        songs.removeWhere((element) => element.name != musicAi);

        for (var song in songs) {
          {
            searchPlayList_list.add(AudioSource.uri(Uri.parse(song.url)));
          }
        }

        final searchPlayList = ConcatenatingAudioSource(children: searchPlayList_list);
        if (Provider.of<PlayerModel>(context, listen: false).isPlaying == true) {
          Provider.of<PlayerModel>(context, listen: false).stopMusic();
          Provider.of<PlayerModel>(context, listen: false).ChangePlayerState(songs, 0);
          Provider.of<PlayerModel>(context, listen: false).playMusic(searchPlayList, 0);
        } else {
          Provider.of<PlayerModel>(context, listen: false).ChangePlayerState(songs, 0);
          Provider.of<PlayerModel>(context, listen: false).playMusic(searchPlayList, 0);
        }

        break;
    }
  }

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
          appBar: const _CustomAppBar(),
          //bottomNavigationBar: const _CustomNavBar(),
          body: SingleChildScrollView(
              child: Column(children: [
            const _DiscoverMusic(),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 20.0, bottom: 20.0),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(
                      right: 20.0,
                    ),
                    child: SectionHeader(title: 'Choose music category'),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 0.27,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          itemBuilder: ((context, index) {
                            return CategoryTile(
                              imageUrl: categories[index].imageUrl,
                              categoryName: categories[index].categoryName,
                            );
                          }))),
                  SizedBox(
                    height: 100,
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
                  SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                            onTap: () {
                              playerModel.audioPlayer.seekToPrevious();

                              if (playerModel.index == 0) {
                                playerModel.audioPlayer.seek(Duration.zero, index: 0);
                              } else {
                                playerModel.decrementIndex();
                              }
                            },
                            child: Icon(Icons.arrow_back_ios_outlined)),
                        SizedBox(
                            child: playerModel.audioPlayer.playing
                                ? GestureDetector(
                                    child: Icon(Icons.pause),
                                    onTap: () {
                                      playerModel.pauseMusic();
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
                              playerModel.audioPlayer.seekToNext();

                              playerModel.incrementIndex();
                              if (playerModel.index == 0) {
                                playerModel.audioPlayer.seek(Duration.zero, index: 0);
                              }
                            },
                            child: Icon(Icons.arrow_forward_ios_outlined)),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ])),
        ),
      ),
    );
  }
}

class _DiscoverMusic extends StatelessWidget {
  const _DiscoverMusic({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    return Consumer<PlayerModel>(
      builder: (context, playerModel, child) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome',
                    style: Theme.of(context).textTheme.headline6!.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Enjoy your favorite music!',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AutocompleteBasic(),
          ],
        ),
      ),
    );
  }
}

class AutocompleteBasic extends StatefulWidget {
  AutocompleteBasic({super.key});
  static List<String> _kOptions = <String>[];
  static List<String> searchName = <String>[];

  @override
  State<AutocompleteBasic> createState() => _AutocompleteBasicState();
}

class _AutocompleteBasicState extends State<AutocompleteBasic> {
  List<MySong> songs = <MySong>[];
  List<MySong> autoCompleteSongs = <MySong>[];
  @override
  void initState() {
    fetchSongsList();
    autoCompleteFetch();
    super.initState();
  }

  fetchSongsList() async {
    // List<MySong> songs = <MySong>[];
    final songJson = await rootBundle.loadString("assets/songs.json");
    songs = MySongList.fromJson(songJson).songs;
  }

  autoCompleteFetch() async {
    // List<MySong> songs = <MySong>[];
    final songJson = await rootBundle.loadString("assets/songs.json");
    autoCompleteSongs = MySongList.fromJson(songJson).songs;

    for (var song in autoCompleteSongs) {
      AutocompleteBasic._kOptions.add(song.artist + ' - ' + song.name);
      AutocompleteBasic.searchName.add(song.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerModel>(
        builder: (context, playerModel, child) => Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.toLowerCase() == '') {
                  return const Iterable<String>.empty();
                }
                return AutocompleteBasic._kOptions.where((String option) {
                  return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                });
              },
              optionsViewBuilder: (BuildContext context, void Function(String) onSelected, Iterable<String> options) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 47, 0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 300, maxWidth: 350),
                        child: ListView(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          children: options.map((opt) {
                            return InkWell(
                                onTap: () async {
                                  await fetchSongsList();

                                  List<AudioSource> searchPlayList_list = [];
                                  playerModel.audioPlayer.pause();

                                  songs.removeWhere((element) =>
                                      !(element.artist.toLowerCase() + ' - ' + element.name.toLowerCase()).contains(opt.toLowerCase()));

                                  for (var song in songs) {
                                    {
                                      searchPlayList_list.add(AudioSource.uri(Uri.parse(song.url)));
                                    }
                                  }

                                  final searchPlayList = ConcatenatingAudioSource(children: searchPlayList_list);
                                  if (playerModel.isPlaying == true) {
                                    playerModel.stopMusic();
                                    playerModel.ChangePlayerState(songs, 0);
                                    playerModel.playMusic(searchPlayList, 0);
                                  } else {
                                    playerModel.ChangePlayerState(songs, 0);
                                    playerModel.playMusic(searchPlayList, 0);
                                  }
                                  onSelected(opt);
                                },
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Container(
                                    //  width: double.infinity,
                                    padding: EdgeInsets.all(10),
                                    child: Text(
                                      opt,
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ));
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                );
              },
              fieldViewBuilder: (
                context,
                controller,
                focusNode,
                onEditingComplete,
              ) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onEditingComplete: onEditingComplete,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      hintText: "Search music",
                      hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey.shade500),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Color.fromARGB(255, 101, 165, 238),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        color: Color.fromARGB(255, 101, 165, 238),
                        onPressed: () {
                          controller.clear();
                          focusNode.unfocus();
                        },
                      )),
                );
              },
            ));
  }
}

class _CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  const _CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      // leading: const Icon(Icons.grid_view_rounded),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56.0);
}

class CategoryTile extends StatefulWidget {
  final String imageUrl, categoryName;
  CategoryTile({required this.imageUrl, required this.categoryName});

  @override
  State<CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<CategoryTile> {
  List<CategoryModel> categories = <CategoryModel>[];
  List<MySong> songs = <MySong>[];
  @override
  void initState() {
    super.initState();
    //categories = getCategories();
    fetchSongsList();
  }

  fetchSongsList() async {
    final songJson = await rootBundle.loadString("assets/songs.json");
    songs = MySongList.fromJson(songJson).songs;
    // print(songs);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CategoryMusic(songs: songs, category: widget.categoryName.toLowerCase(), imageUrl: widget.imageUrl)));
      },
      child: Container(
          width: MediaQuery.of(context).size.width * 0.45,
          margin: EdgeInsets.only(right: 16),
          child: Stack(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  width: 220,
                  height: 224,
                  imageUrl: widget.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                alignment: Alignment.center,
                width: 220,
                height: 224,
                color: Colors.black38,
                child: Text(
                  widget.categoryName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              )
            ],
          )),
    );
  }
}
