import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../providers/image_providers.dart';
import '../providers/video_providers.dart';
import '../providers/category_providers.dart';
import '../data/database.dart';

class AddMediaScreen extends ConsumerStatefulWidget {
  final String mediaType; // 'image' または 'video'
  final int categoryId; // 追加: 親画面からカテゴリIDを受け取る

  const AddMediaScreen({super.key, required this.mediaType, required this.categoryId});

  @override
  ConsumerState<AddMediaScreen> createState() => _AddMediaScreenState();
}

class _AddMediaScreenState extends ConsumerState<AddMediaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedFilePath;
  String? _selectedFileName;
  bool _isLoading = false;

  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    // カテゴリIDをセット
    _selectedCategoryId = widget.categoryId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: widget.mediaType == 'image' ? FileType.image : FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _selectedFilePath = file.path;
          _selectedFileName = file.name;
          // ファイル名をデフォルトの名前として設定
          if (_nameController.text.isEmpty) {
            _nameController.text = path.basenameWithoutExtension(file.name);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ファイル選択に失敗しました: $e')),
        );
      }
    }
  }

  Future<String> _copyFileToAppDirectory(String sourcePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = path.basename(sourcePath);
    final destinationPath = path.join(appDir.path, 'media', fileName);
    
    // ディレクトリが存在しない場合は作成
    final directory = Directory(path.dirname(destinationPath));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    
    // ファイルをコピー
    final sourceFile = File(sourcePath);
    final destinationFile = await sourceFile.copy(destinationPath);
    
    return destinationFile.path;
  }

  Future<void> _addMedia() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ファイルを選択してください')),
      );
      return;
    }
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('カテゴリを選択してください')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // ファイルをアプリディレクトリにコピー
      final savedPath = await _copyFileToAppDirectory(_selectedFilePath!);
      
      if (widget.mediaType == 'image') {
        // 画像を追加
        await ref.read(addImageProvider((
          name: _nameController.text.trim(),
          imagePath: savedPath,
          categoryId: _selectedCategoryId!,
        )).future);
      } else {
        // 動画を追加
        await ref.read(addVideoProvider((
          name: _nameController.text.trim(),
          videoPath: savedPath,
          categoryId: _selectedCategoryId!,
        )).future);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.mediaType == 'image' ? '画像' : '動画'}を追加しました')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('追加に失敗しました: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.mediaType == 'image' ? '画像' : '動画'}追加'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // カテゴリ選択フォームは削除
              // ファイル選択
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ファイル選択',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _pickFile,
                          icon: const Icon(Icons.file_upload),
                          label: Text('${widget.mediaType == 'image' ? '画像' : '動画'}ファイルを選択'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                      if (_selectedFileName != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          '選択されたファイル: $_selectedFileName',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 名前入力
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'メディア名',
                  hintText: '例: 家族の写真',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'メディア名を入力してください';
                  }
                  if (value.trim().length > 50) {
                    return 'メディア名は50文字以内で入力してください';
                  }
                  return null;
                },
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _addMedia(),
              ),
              const SizedBox(height: 24),
              // 追加ボタン
              ElevatedButton(
                onPressed: _isLoading ? null : _addMedia,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('${widget.mediaType == 'image' ? '画像' : '動画'}を追加'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 