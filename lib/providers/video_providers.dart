import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database.dart';
import 'dao_providers.dart';

// 全動画取得プロバイダー
final videosProvider = FutureProvider<List<Video>>((ref) async {
  final videoDao = ref.watch(videoDaoProvider);
  return await videoDao.getAllVideos();
});

// カテゴリ別動画監視プロバイダー
final watchVideosByCategoryProvider = StreamProvider.family<List<Video>, int>((ref, categoryId) {
  final videoDao = ref.watch(videoDaoProvider);
  return videoDao.watchVideosByCategory(categoryId);
});

// 動画追加プロバイダー
final addVideoProvider = FutureProvider.family<int, ({String name, String videoPath, int categoryId})>((ref, params) async {
  final videoDao = ref.watch(videoDaoProvider);
  final companion = VideosCompanion(
    name: Value(params.name),
    videoPath: Value(params.videoPath),
    categoryId: Value(params.categoryId),
    createdAt: Value(DateTime.now()),
  );
  return await videoDao.insertVideo(companion);
});

// 動画更新プロバイダー
final updateVideoProvider = FutureProvider.family<bool, Video>((ref, video) async {
  final videoDao = ref.watch(videoDaoProvider);
  final updatedVideo = video.copyWith(
    updatedAt: Value(DateTime.now()),
  );
  return await videoDao.updateVideo(updatedVideo);
});

// 動画削除プロバイダー
final deleteVideoProvider = FutureProvider.family<int, int>((ref, id) async {
  final videoDao = ref.watch(videoDaoProvider);
  return await videoDao.deleteVideo(id);
});

// 動画IDで1件取得プロバイダー
final videoByIdProvider = FutureProvider.family<Video?, int>((ref, id) async {
  final videoDao = ref.watch(videoDaoProvider);
  return await videoDao.getVideoById(id);
}); 