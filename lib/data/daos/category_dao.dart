import 'package:drift/drift.dart';
import '../tables/category.dart';
import '../database.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase> with _$CategoryDaoMixin {
  CategoryDao(AppDatabase db) : super(db);

  // 全カテゴリ取得
  Future<List<Category>> getAllCategories() => select(categories).get();

  // ストリームで全カテゴリ監視
  Stream<List<Category>> watchAllCategories() => select(categories).watch();

  // 追加
  Future<int> insertCategory(CategoriesCompanion entry) => into(categories).insert(entry);

  // mediaTypeを含むカテゴリ追加
  Future<int> addCategory({required String name, required String mediaType}) {
    return into(categories).insert(
      CategoriesCompanion.insert(
        name: name,
        mediaType: mediaType,
      ),
    );
  }

  // 更新
  Future<bool> updateCategory(Category entry) => update(categories).replace(entry);

  // 削除
  Future<int> deleteCategory(int id) => (delete(categories)..where((tbl) => tbl.id.equals(id))).go();

  // 画像用カテゴリのみ取得
  Future<List<Category>> getImageCategories() {
    return (select(categories)..where((c) => c.mediaType.equals('image'))).get();
  }

  // 動画用カテゴリのみ取得
  Future<List<Category>> getVideoCategories() {
    return (select(categories)..where((c) => c.mediaType.equals('video'))).get();
  }

  // 画像用カテゴリのストリーム
  Stream<List<Category>> watchImageCategories() {
    return (select(categories)..where((c) => c.mediaType.equals('image'))).watch();
  }

  // 動画用カテゴリのストリーム
  Stream<List<Category>> watchVideoCategories() {
    return (select(categories)..where((c) => c.mediaType.equals('video'))).watch();
  }
}
