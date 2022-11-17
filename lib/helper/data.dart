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
  categoryModel.imageUrl = "https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/Rock-guitar-player.jpg/220px-Rock-guitar-player.jpg";
  categories.add(categoryModel);
  return categories;
}
