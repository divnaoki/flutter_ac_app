import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/category_providers.dart';
import '../data/database.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(watchCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('アクセシブルメディア'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: categoriesAsync.when(
        data: (categories) => categories.isEmpty
            ? const Center(
                child: Text('カテゴリがありません\nカテゴリを追加してください'),
              )
            : ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      leading: Icon(
                        category.mediaType == 'image' ? Icons.image : Icons.video_library,
                        color: category.mediaType == 'image' ? Colors.blue : Colors.red,
                        size: 28,
                      ),
                      title: Text(category.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.mediaType == 'image' ? '画像用カテゴリ' : '動画用カテゴリ',
                            style: TextStyle(
                              color: category.mediaType == 'image' ? Colors.blue : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('作成日: ${category.createdAt.toString().split(' ')[0]}'),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          switch (value) {
                            case 'edit':
                              // カテゴリ編集画面に遷移
                              context.push('/edit-category/${category.id}');
                              break;
                            case 'delete':
                              // 削除確認ダイアログ
                              final shouldDelete = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('カテゴリ削除'),
                                  content: Text('「${category.name}」を削除しますか？\nこのカテゴリ内の画像・動画も削除されます。'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text('キャンセル'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: const Text('削除'),
                                    ),
                                  ],
                                ),
                              );
                              
                              if (shouldDelete == true) {
                                try {
                                  await ref.read(deleteCategoryProvider(category.id).future);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('「${category.name}」を削除しました')),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('削除に失敗しました: $e')),
                                    );
                                  }
                                }
                              }
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('編集'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('削除', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        // カテゴリの種別に応じて直接一覧画面へ遷移
                        if (category.mediaType == 'image') {
                          context.push('/category/${category.id}/images');
                        } else {
                          context.push('/category/${category.id}/videos');
                        }
                      },
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('エラー: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // カテゴリ追加画面に遷移
          context.push('/add-category');
        },
        tooltip: 'カテゴリ追加',
        child: const Icon(Icons.add),
      ),
    );
  }
} 