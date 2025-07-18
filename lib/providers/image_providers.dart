import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database.dart';
import 'dao_providers.dart';

// 全画像取得プロバイダー
final imagesProvider = FutureProvider<List<Image>>((ref) async {
  final imageDao = ref.watch(imageDaoProvider);
  return await imageDao.getAllImages();
});

// カテゴリ別画像監視プロバイダー
final watchImagesByCategoryProvider = StreamProvider.family<List<Image>, int>((ref, categoryId) {
  final imageDao = ref.watch(imageDaoProvider);
  return imageDao.watchImagesByCategory(categoryId);
});

// 画像追加プロバイダー
final addImageProvider = FutureProvider.family<int, ({String name, String imagePath, int categoryId})>((ref, params) async {
  final imageDao = ref.watch(imageDaoProvider);
  final companion = ImagesCompanion(
    name: Value(params.name),
    imagePath: Value(params.imagePath),
    categoryId: Value(params.categoryId),
    createdAt: Value(DateTime.now()),
  );
  return await imageDao.insertImage(companion);
});

// 画像更新プロバイダー
final updateImageProvider = FutureProvider.family<bool, Image>((ref, image) async {
  final imageDao = ref.watch(imageDaoProvider);
  final updatedImage = image.copyWith(
    updatedAt: Value(DateTime.now()),
  );
  return await imageDao.updateImage(updatedImage);
});

// 画像削除プロバイダー
final deleteImageProvider = FutureProvider.family<int, int>((ref, id) async {
  final imageDao = ref.watch(imageDaoProvider);
  return await imageDao.deleteImage(id);
}); 