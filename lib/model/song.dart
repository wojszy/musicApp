// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:collection/collection.dart';

class MySongList {
  final List<MySong> songs;
  MySongList({
    required this.songs,
  });

  MySongList copyWith({
    List<MySong>? songs,
  }) {
    return MySongList(
      songs: songs ?? this.songs,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'songs': songs.map((x) => x.toMap()).toList(),
    };
  }

  factory MySongList.fromMap(Map<String, dynamic> map) {
    return MySongList(
      songs: List<MySong>.from((map['songs'] as List<int>).map<MySong>((x) => MySong.fromMap(x as Map<String,dynamic>),),),
    );
  }

  String toJson() => json.encode(toMap());

  factory MySongList.fromJson(String source) => MySongList.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'MySongList(songs: $songs)';

  @override
  bool operator ==(covariant MySongList other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;
  
    return 
      listEquals(other.songs, songs);
  }

  @override
  int get hashCode => songs.hashCode;
}

class MySong {
  final int id;
  final String name;
  final String url;
  final String artist;
  final String image;
  final String Category;
  MySong({
    required this.id,
    required this.name,
    required this.url,
    required this.artist,
    required this.image,
    required this.Category,
  });

  MySong copyWith({
    int? id,
    String? name,
    String? url,
    String? artist,
    String? image,
    String? Category,
  }) {
    return MySong(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      artist: artist ?? this.artist,
      image: image ?? this.image,
      Category: Category ?? this.Category,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'url': url,
      'artist': artist,
      'image': image,
      'Category': Category,
    };
  }

  factory MySong.fromMap(Map<String, dynamic> map) {
    return MySong(
      id: map['id'] as int,
      name: map['name'] as String,
      url: map['url'] as String,
      artist: map['artist'] as String,
      image: map['image'] as String,
      Category: map['Category'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory MySong.fromJson(String source) => MySong.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'MySong(id: $id, name: $name, url: $url, artist: $artist, image: $image, Category: $Category)';
  }

  @override
  bool operator ==(covariant MySong other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.url == url &&
        other.artist == artist &&
        other.image == image &&
        other.Category == Category;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ url.hashCode ^ artist.hashCode ^ image.hashCode ^ Category.hashCode;
  }
}
