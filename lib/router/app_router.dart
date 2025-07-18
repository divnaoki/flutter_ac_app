import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/index.dart';

// ルート名の定数
class AppRoutes {
  static const String home = '/';
  static const String categoryDetail = '/category/:id';
  static const String imageList = '/category/:id/images';
  static const String imageDetail = '/image/:id';
  static const String videoList = '/category/:id/videos';
  static const String videoDetail = '/video/:id';
  static const String addImage = '/category/:id/add-image';
  static const String addVideo = '/category/:id/add-video';
  static const String addCategory = '/add-category';
  static const String editCategory = '/edit-category/:id';
}

// ルーター設定
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      // ホーム画面（カテゴリ一覧）
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      
      // 画像一覧画面
      GoRoute(
        path: AppRoutes.imageList,
        name: 'image-list',
        builder: (context, state) {
          final categoryId = int.parse(state.pathParameters['id']!);
          return ImageListScreen(categoryId: categoryId);
        },
      ),
      
      // 画像詳細画面（TTS読み上げ）
      GoRoute(
        path: AppRoutes.imageDetail,
        name: 'image-detail',
        builder: (context, state) {
          final imageId = int.parse(state.pathParameters['id']!);
          return ImageDetailScreen(imageId: imageId);
        },
      ),
      
      // 動画一覧画面
      GoRoute(
        path: AppRoutes.videoList,
        name: 'video-list',
        builder: (context, state) {
          final categoryId = int.parse(state.pathParameters['id']!);
          return VideoListScreen(categoryId: categoryId);
        },
      ),
      
      // 動画再生画面
      GoRoute(
        path: AppRoutes.videoDetail,
        name: 'video-detail',
        builder: (context, state) {
          final videoId = int.parse(state.pathParameters['id']!);
          return VideoDetailScreen(videoId: videoId);
        },
      ),
      
      // 画像追加画面
      GoRoute(
        path: AppRoutes.addImage,
        name: 'add-image',
        builder: (context, state) {
          final categoryId = int.parse(state.pathParameters['id']!);
          return AddMediaScreen(mediaType: 'image', categoryId: categoryId);
        },
      ),
      
      // 動画追加画面
      GoRoute(
        path: AppRoutes.addVideo,
        name: 'add-video',
        builder: (context, state) {
          final categoryId = int.parse(state.pathParameters['id']!);
          return AddMediaScreen(mediaType: 'video', categoryId: categoryId);
        },
      ),
      
      // カテゴリ追加画面
      GoRoute(
        path: AppRoutes.addCategory,
        name: 'add-category',
        builder: (context, state) => const AddCategoryScreen(),
      ),
      
      // カテゴリ編集画面
      GoRoute(
        path: AppRoutes.editCategory,
        name: 'edit-category',
        builder: (context, state) {
          final categoryId = int.parse(state.pathParameters['id']!);
          return EditCategoryScreen(categoryId: categoryId);
        },
      ),
    ],
  );
}); 