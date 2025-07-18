import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../data/database.dart';

// データベースファイルのパスを取得
Future<String> _databasePath() async {
  final documentsDir = await getApplicationDocumentsDirectory();
  return p.join(documentsDir.path, 'accessible_media.db');
}

// データベースプロバイダー
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError();
});

// データベース初期化プロバイダー
final databaseInitializerProvider = FutureProvider<AppDatabase>((ref) async {
  final path = await _databasePath();
  final database = AppDatabase(NativeDatabase(File(path)));
  return database;
});

// 初期化済みデータベースプロバイダー
final initializedDatabaseProvider = Provider<AppDatabase>((ref) {
  final databaseAsync = ref.watch(databaseInitializerProvider);
  return databaseAsync.when(
    data: (database) => database,
    loading: () => throw Exception('Database is still loading'),
    error: (error, stack) => throw Exception('Failed to initialize database: $error'),
  );
}); 