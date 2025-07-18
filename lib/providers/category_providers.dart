import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database.dart';
import 'dao_providers.dart';

// 全カテゴリ取得プロバイダー
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final categoryDao = ref.watch(categoryDaoProvider);
  return await categoryDao.getAllCategories();
});

// 全カテゴリ監視プロバイダー
final watchCategoriesProvider = StreamProvider<List<Category>>((ref) {
  final categoryDao = ref.watch(categoryDaoProvider);
  return categoryDao.watchAllCategories();
});

// カテゴリ追加プロバイダー（旧版）
final addCategoryProvider = FutureProvider.family<int, String>((ref, name) async {
  final categoryDao = ref.watch(categoryDaoProvider);
  final companion = CategoriesCompanion(
    name: Value(name),
    mediaType: Value('image'), // デフォルトは画像用
    createdAt: Value(DateTime.now()),
  );
  return await categoryDao.insertCategory(companion);
});

// カテゴリ追加プロバイダー（新版 - mediaType対応）
final addCategoryWithTypeProvider = FutureProvider.family<void, Map<String, String>>((ref, params) async {
  final categoryDao = ref.watch(categoryDaoProvider);
  await categoryDao.addCategory(
    name: params['name']!,
    mediaType: params['mediaType']!,
  );
});

// カテゴリ更新プロバイダー
final updateCategoryProvider = FutureProvider.family<bool, Category>((ref, category) async {
  final categoryDao = ref.watch(categoryDaoProvider);
  final updatedCategory = category.copyWith(
    updatedAt: Value(DateTime.now()),
  );
  return await categoryDao.updateCategory(updatedCategory);
});

// カテゴリ削除プロバイダー
final deleteCategoryProvider = FutureProvider.family<int, int>((ref, id) async {
  final categoryDao = ref.watch(categoryDaoProvider);
  return await categoryDao.deleteCategory(id);
});

// 画像用カテゴリ取得プロバイダー
final imageCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final categoryDao = ref.watch(categoryDaoProvider);
  return await categoryDao.getImageCategories();
});

// 動画用カテゴリ取得プロバイダー
final videoCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final categoryDao = ref.watch(categoryDaoProvider);
  return await categoryDao.getVideoCategories();
});

// 画像用カテゴリ監視プロバイダー
final watchImageCategoriesProvider = StreamProvider<List<Category>>((ref) {
  final categoryDao = ref.watch(categoryDaoProvider);
  return categoryDao.watchImageCategories();
});

// 動画用カテゴリ監視プロバイダー
final watchVideoCategoriesProvider = StreamProvider<List<Category>>((ref) {
  final categoryDao = ref.watch(categoryDaoProvider);
  return categoryDao.watchVideoCategories();
}); 