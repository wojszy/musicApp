import 'package:musicapp/model/category.dart';

List<CategoryModel> getCategories() {
  List<CategoryModel> categories = <CategoryModel>[];
  CategoryModel categoryModel = new CategoryModel();

//1
  categoryModel.categoryName = "Electronic";
  categoryModel.imageUrl =
      "https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Jean-Michel_Jarre_Coachella18W1-112_%2841337879334%29.jpg/1920px-Jean-Michel_Jarre_Coachella18W1-112_%2841337879334%29.jpg";
  categories.add(categoryModel);
//2
  categoryModel = new CategoryModel();
  categoryModel.categoryName = "Rock";
  categoryModel.imageUrl = "https://images.saymedia-content.com/.image/t_share/MTc0NDg3MzAyOTgxMzYzMzM0/100-best-rock-songs-of-the-80s.jpg";
  categories.add(categoryModel);

  //3
  categoryModel = new CategoryModel();
  categoryModel.categoryName = "Jazz";
  categoryModel.imageUrl = "https://laboratoriummf.com/wp-content/uploads/2014/03/dixie_jazz_5-3.jpg";
  categories.add(categoryModel);

  return categories;
}
