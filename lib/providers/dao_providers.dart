import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/daos/category_dao.dart';
import '../data/daos/image_dao.dart';
import '../data/daos/video_dao.dart';
import 'database_provider.dart';

// CategoryDaoプロバイダー
final categoryDaoProvider = Provider<CategoryDao>((ref) {
  final database = ref.watch(initializedDatabaseProvider);
  return CategoryDao(database);
});

// ImageDaoプロバイダー
final imageDaoProvider = Provider<ImageDao>((ref) {
  final database = ref.watch(initializedDatabaseProvider);
  return ImageDao(database);
});

// VideoDaoプロバイダー
final videoDaoProvider = Provider<VideoDao>((ref) {
  final database = ref.watch(initializedDatabaseProvider);
  return VideoDao(database);
}); 