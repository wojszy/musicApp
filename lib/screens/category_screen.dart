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

  @override
  Widget build(BuildContext context) {
    AudioPlayer audioPlayer = AudioPlayer();

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

            // Text('Category: ' + widget.category, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            buildSongs(widget.songs, widget.category),

            // CachedNetworkImage(imageUrl: widget.imageUrl, fit: BoxFit.cover),
          ]))),
      //buildSongs(widget.songs, widget.category),
      //  _CustomPlayer()
    );
  }

  Widget buildSongs(List<MySong> songs, String category) => ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: songs.length,
        itemBuilder: (context, index) {
          return songs[index].category == category
              ? Card(
                  child: ListTile(
                  onTap: () {
                    print(songs[index].url);
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

class _CustomPlayer extends StatelessWidget {
  const _CustomPlayer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 100,
        alignment: AlignmentDirectional.bottomEnd,
        decoration: BoxDecoration(color: Colors.grey.shade600.withOpacity(0.5)),
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
