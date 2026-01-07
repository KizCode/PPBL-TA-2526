import '../data/recipe_db.dart';
import '../models/recipe_item_model.dart';

class RecipeRepository {
  final RecipeDb _db;
  RecipeRepository({RecipeDb? db}) : _db = db ?? RecipeDb();

  Future<List<RecipeItemModel>> byProduct(int productId) => _db.byProduct(productId);
}
