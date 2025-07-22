import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/category_providers.dart';
import '../data/database.dart';

class MainLayout extends ConsumerStatefulWidget {
  final Widget child;
  final String title;
  final Widget? floatingActionButton;

  const MainLayout({
    super.key,
    required this.child,
    required this.title,
    this.floatingActionButton,
  });

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(watchCategoriesProvider);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple[400]!,
                Colors.purple[600]!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.accessible,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                    offset: Offset(2, 2),
                    blurRadius: 4,
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.accessible,
                      color: Colors.white,
                      size: 48,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'アクセシブルメディア',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ホームボタン
            ListTile(
              leading: const Icon(Icons.home, color: Colors.blue),
              title: const Text(
                'ホーム',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: const Text(
                'メイン画面に戻る',
                style: TextStyle(fontSize: 12),
              ),
              onTap: () {
                // ドロワーを閉じる
                Navigator.of(context).pop();
                
                // ホーム画面に遷移
                context.go('/');
              },
            ),
            const Divider(),
            // カテゴリセクションのタイトル
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'カテゴリ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            Expanded(
              child: categoriesAsync.when(
                data: (categories) => categories.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'カテゴリがありません\nカテゴリを追加してください',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return _buildCategoryTile(category);
                        },
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('エラー: $error'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: widget.child,
      floatingActionButton: widget.floatingActionButton,
    );
  }

  Widget _buildCategoryTile(Category category) {
    return ListTile(
      leading: Icon(
        category.mediaType == 'image' ? Icons.image : Icons.video_library,
        color: category.mediaType == 'image' ? Colors.blue : Colors.red,
      ),
      title: Text(
        category.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        category.mediaType == 'image' ? '画像用カテゴリ' : '動画用カテゴリ',
        style: TextStyle(
          color: category.mediaType == 'image' ? Colors.blue : Colors.red,
          fontSize: 12,
        ),
      ),
      onTap: () {
        // ドロワーを閉じる
        Navigator.of(context).pop();
        
        // カテゴリの種別に応じて直接一覧画面へ遷移
        if (category.mediaType == 'image') {
          context.push('/category/${category.id}/images');
        } else {
          context.push('/category/${category.id}/videos');
        }
      },
      trailing: PopupMenuButton<String>(
        onSelected: (value) async {
          switch (value) {
            case 'edit':
              Navigator.of(context).pop(); // ドロワーを閉じる
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
                Icon(Icons.edit, size: 20),
                SizedBox(width: 8),
                Text('編集'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Text('削除', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 