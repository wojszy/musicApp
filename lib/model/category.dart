class Category {
  final String title;
  final String image;
  Category({
    required this.title,
    required this.image,
  });

  static List<Category> categories = [
    Category(
        title: 'Electronic',
        image:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Jean-Michel_Jarre_Coachella18W1-112_%2841337879334%29.jpg/1920px-Jean-Michel_Jarre_Coachella18W1-112_%2841337879334%29.jpg'),
    Category(
        title: 'Rock',
        image: 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/Rock-guitar-player.jpg/220px-Rock-guitar-player.jpg'),
  ];
}
