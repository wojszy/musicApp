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

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CategoryModel> categories = <CategoryModel>[];
  List<MySong> songs = <MySong>[];
  // static AudioPlayer _audioPlayer = AudioPlayer();
  @override
  void initState() {
    super.initState();
    setupAlan();
    categories = getCategories();
    fetchSongsList();
  }

  fetchSongsList() async {
    final songJson = await rootBundle.loadString("assets/songs.json");
    songs = MySongList.fromJson(songJson).songs;
    print(songs);
    setState(() {});
  }

  setupAlan() {
    AlanVoice.addButton("a0bfd35a2c6bc34391f94ad34f381b302e956eca572e1d8b807a3e2338fdd0dc/stage",
        buttonAlign: AlanVoice.BUTTON_ALIGN_RIGHT);

    AlanVoice.callbacks.add((command) => _handleCommand(command.data, PlayerModel()));
  }

  void _handleCommand(Map<String, dynamic> response, PlayerModel playerModel) {
    switch (response["command"]) {
      case "play":
        //Provider.of<PlayerModel>(context, listen: false).playMusic();
        break;
      case "pause":
        Provider.of<PlayerModel>(context, listen: false).pauseMusic();
        break;
      case "unpause":
        Provider.of<PlayerModel>(context, listen: false).unPauseMusic();
        break;
      case "next":
        Provider.of<PlayerModel>(context, listen: false).audioPlayer.seekToNext();

        Provider.of<PlayerModel>(context, listen: false).incrementIndex();
        if (Provider.of<PlayerModel>(context, listen: false).index == 0) {
          Provider.of<PlayerModel>(context, listen: false).audioPlayer.seek(Duration.zero, index: 0);
        } else {}
        ;
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
          bottomNavigationBar: const _CustomNavBar(),
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
                    child: Text(
                      'Current Playing: ${playerModel.songs[playerModel.index].artist}'
                      ' - '
                      '${playerModel.songs[playerModel.index].name}',
                      //textAlign: TextAlign.left,
                    ),
                  ),
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
            TextFormField(
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: Colors.white,
                hintText: 'Search song',
                hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey.shade500),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomNavBar extends StatelessWidget {
  const _CustomNavBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.deepPurple.shade800,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mic),
            label: 'Talk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.featured_play_list_outlined),
            label: 'My Playlist',
          ),
        ]);
  }
}

class _CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  const _CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: const Icon(Icons.grid_view_rounded),
    );
  }

  @override
  // TODO: implement preferredSize
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
