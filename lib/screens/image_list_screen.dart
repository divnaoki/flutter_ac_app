import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import '../providers/image_providers.dart';
import '../data/database.dart' as db;

class ImageListScreen extends ConsumerWidget {
  final int categoryId;

  const ImageListScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagesAsync = ref.watch(watchImagesByCategoryProvider(categoryId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('画像一覧'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: imagesAsync.when(
        data: (images) => images.isEmpty
            ? const Center(
                child: Text('画像がありません\n画像を追加してください'),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final image = images[index];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        // 画像詳細画面に遷移
                        context.push('/image/${image.id}');
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                              ),
                              child: _buildImageWidget(image.imagePath),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  image.name,
                                  style: Theme.of(context).textTheme.titleSmall,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '追加日: ${image.createdAt.toString().split(' ')[0]}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
          // 画像追加画面にカテゴリIDを渡して遷移
          context.push('/category/$categoryId/add-image');
        },
        tooltip: '画像追加',
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  Widget _buildImageWidget(String imagePath) {
    final file = File(imagePath);
    
    if (!file.existsSync()) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 8),
            Text(
              '画像が見つかりません',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(12),
      ),
      child: Image.file(
        file,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red,
                ),
                SizedBox(height: 8),
                Text(
                  '画像の読み込みに失敗',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 