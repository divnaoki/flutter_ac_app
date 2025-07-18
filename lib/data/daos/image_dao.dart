import 'package:drift/drift.dart';
import '../tables/image.dart';
import '../database.dart';

part 'image_dao.g.dart';

@DriftAccessor(tables: [Images])
class ImageDao extends DatabaseAccessor<AppDatabase> with _$ImageDaoMixin {
  ImageDao(AppDatabase db) : super(db);

  // 全画像取得
  Future<List<Image>> getAllImages() => select(images).get();

  // カテゴリごとの画像を監視
  Stream<List<Image>> watchImagesByCategory(int categoryId) =>
      (select(images)..where((tbl) => tbl.categoryId.equals(categoryId))).watch();

  // 追加
  Future<int> insertImage(ImagesCompanion entry) => into(images).insert(entry);

  // 更新
  Future<bool> updateImage(Image entry) => update(images).replace(entry);

  // 削除
  Future<int> deleteImage(int id) => (delete(images)..where((tbl) => tbl.id.equals(id))).go();
}
