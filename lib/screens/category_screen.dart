import 'dart:convert';
import 'package:flutter/services.dart';

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
  CategoryMusic({required this.category, required this.songs});
  @override
  State<CategoryMusic> createState() => _CategoryMusicState();
}

class _CategoryMusicState extends State<CategoryMusic> {
  //List<CategoryModel> categories = <CategoryModel>[];

  @override
  Widget build(BuildContext context) {
    // Category category = CategoryMusic(category: category)
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: buildSongs(widget.songs, widget.category),
      ),
    );
  }

  Widget buildSongs(List<MySong> songs, String category) => ListView.builder(
        itemCount: songs.length,
        itemBuilder: (context, index) {
          //  final song = songs[index];
          return songs[index].category == category
              ? Card(
                  child: ListTile(
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(songs[index].image),
                  ),
                  title: Text(songs[index].artist, style: TextStyle(color: Colors.black)),
                ))
              : Container();
        },
      );
}
