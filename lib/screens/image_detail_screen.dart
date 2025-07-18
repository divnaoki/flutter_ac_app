import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io';
import '../providers/image_providers.dart';
import '../providers/dao_providers.dart';
import '../data/database.dart' as db;

class ImageDetailScreen extends ConsumerStatefulWidget {
  final int imageId;

  const ImageDetailScreen({super.key, required this.imageId});

  @override
  ConsumerState<ImageDetailScreen> createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends ConsumerState<ImageDetailScreen> {
  final FlutterTts flutterTts = FlutterTts();
  db.Image? _image;
  bool _isLoading = true;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _loadImage();
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _initializeTts() async {
    await flutterTts.setLanguage('ja-JP');
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  Future<void> _loadImage() async {
    try {
      final imageDao = ref.read(imageDaoProvider);
      final images = await imageDao.getAllImages();
      final image = images.firstWhere(
        (img) => img.id == widget.imageId,
        orElse: () => throw Exception('画像が見つかりません'),
      );
      setState(() {
        _image = image;
        _isLoading = false;
      });
      
      // 画像読み込み時に自動でTTS読み上げ
      await _speakImageName();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('画像の読み込みに失敗しました: $e')),
        );
        context.pop();
      }
    }
  }

  Future<void> _speakImageName() async {
    if (_image == null) return;

    setState(() {
      _isSpeaking = true;
    });

    try {
      await flutterTts.speak(_image!.name);
      // 3秒後に前ページへ自動で戻る
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.of(context).maybePop();
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('音声読み上げに失敗しました: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
      }
    }
  }

  Future<void> _deleteImage() async {
    if (_image == null) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('画像削除'),
        content: Text('「${_image!.name}」を削除しますか？'),
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
        await ref.read(deleteImageProvider(_image!.id).future);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('「${_image!.name}」を削除しました')),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('削除に失敗しました: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('画像詳細'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_image == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('画像詳細'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(child: Text('画像が見つかりません')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_image!.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _isSpeaking ? null : _speakImageName,
            icon: Icon(_isSpeaking ? Icons.volume_up : Icons.volume_up_outlined),
            tooltip: '音声読み上げ',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  // TODO: 画像編集機能
                  break;
                case 'delete':
                  _deleteImage();
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
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 画像表示エリア
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _buildImageWidget(_image!.imagePath),
              ),
            ),
            const SizedBox(height: 24),
            
            // 画像情報カード
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '画像情報',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('名前: ${_image!.name}'),
                    Text('追加日: ${_image!.createdAt.toString().split(' ')[0]}'),
                    if (_image!.updatedAt != null)
                      Text('更新日: ${_image!.updatedAt!.toString().split(' ')[0]}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 音声読み上げボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSpeaking ? null : _speakImageName,
                icon: Icon(_isSpeaking ? Icons.volume_up : Icons.volume_up_outlined),
                label: Text(_isSpeaking ? '読み上げ中...' : '画像名を読み上げ'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
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
              size: 120,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '画像が見つかりません',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        file,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 120,
                  color: Colors.red,
                ),
                SizedBox(height: 16),
                Text(
                  '画像の読み込みに失敗',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
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