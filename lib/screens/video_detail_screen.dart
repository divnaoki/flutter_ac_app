import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../providers/video_providers.dart';
import 'dart:io';

class VideoDetailScreen extends ConsumerStatefulWidget {
  final int videoId;

  const VideoDetailScreen({super.key, required this.videoId});

  @override
  ConsumerState<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends ConsumerState<VideoDetailScreen> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isCompleted = false;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _listenForEnd() {
    _controller?.addListener(() {
      if (_controller!.value.position >= _controller!.value.duration && !_isCompleted) {
        setState(() {
          _isCompleted = true;
        });
        // 1秒後に前画面に戻る
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.of(context).maybePop();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final videoAsync = ref.watch(videoByIdProvider(widget.videoId));
    return Scaffold(
      appBar: AppBar(
        title: Text('動画再生'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: videoAsync.when(
        data: (video) {
          if (video == null) {
            return const Center(child: Text('動画が見つかりません'));
          }
          if (_controller == null) {
            _controller = VideoPlayerController.file(File(video.videoPath))
              ..initialize().then((_) {
                setState(() {
                  _isInitialized = true;
                });
                _listenForEnd();
                // 自動再生
                _controller!.play();
              });
          }
          return _isInitialized
              ? Column(
                  children: [
                    AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    ),
                    VideoProgressIndicator(_controller!, allowScrubbing: true),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(_controller!.value.isPlaying ? Icons.pause : Icons.play_arrow),
                          onPressed: () {
                            setState(() {
                              if (_controller!.value.isPlaying) {
                                _controller!.pause();
                              } else {
                                _controller!.play();
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    if (_isCompleted)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('再生が終了しました。自動で戻ります...'),
                      ),
                  ],
                )
              : const Center(child: CircularProgressIndicator());
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('エラー: $error')),
      ),
    );
  }
} 