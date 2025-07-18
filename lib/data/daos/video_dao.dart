import 'package:drift/drift.dart';
import '../tables/video.dart';
import '../database.dart';

part 'video_dao.g.dart';

@DriftAccessor(tables: [Videos])
class VideoDao extends DatabaseAccessor<AppDatabase> with _$VideoDaoMixin {
  VideoDao(AppDatabase db) : super(db);

  // 全動画取得
  Future<List<Video>> getAllVideos() => select(videos).get();

  // カテゴリごとの動画を監視
  Stream<List<Video>> watchVideosByCategory(int categoryId) =>
      (select(videos)..where((tbl) => tbl.categoryId.equals(categoryId))).watch();

  // 追加
  Future<int> insertVideo(VideosCompanion entry) => into(videos).insert(entry);

  // 更新
  Future<bool> updateVideo(Video entry) => update(videos).replace(entry);

  // 削除
  Future<int> deleteVideo(int id) => (delete(videos)..where((tbl) => tbl.id.equals(id))).go();

  // 動画IDで1件取得
  Future<Video?> getVideoById(int id) async {
    return (select(videos)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }
}
