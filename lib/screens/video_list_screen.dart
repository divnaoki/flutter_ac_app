import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'video_add_screen.dart';
import 'package:video_player/video_player.dart';
import '../providers/video_providers.dart';
import 'dart:io';
import 'video_detail_screen.dart';

class VideoListScreen extends ConsumerWidget {
  final int categoryId;

  const VideoListScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videosAsync = ref.watch(watchVideosByCategoryProvider(categoryId));
    return Scaffold(
      appBar: AppBar(
        title: Text('動画一覧 - カテゴリID: $categoryId'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: videosAsync.when(
        data: (videos) => videos.isEmpty
            ? const Center(child: Text('動画がありません\n動画を追加してください'))
            : ListView.builder(
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  final video = videos[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: SizedBox(
                        width: 80,
                        height: 56,
                        child: _VideoThumbnail(videoPath: video.videoPath),
                      ),
                      title: Text(video.name),
                      subtitle: Text('追加日: ${video.createdAt.toString().split(' ')[0]}'),
                      onTap: () {
                        // 動画再生画面に遷移
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => VideoDetailScreen(videoId: video.id),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('エラー: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 動画追加画面にカテゴリIDを渡して遷移
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => VideoAddScreen(categoryId: categoryId),
            ),
          );
        },
        tooltip: '動画追加',
        child: const Icon(Icons.video_library),
      ),
    );
  }
}

class _VideoThumbnail extends StatefulWidget {
  final String videoPath;
  const _VideoThumbnail({required this.videoPath});

  @override
  State<_VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<_VideoThumbnail> {
  VideoPlayerController? _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
        });
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: VideoPlayer(_controller!),
    );
  }
} 