import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../providers/video_providers.dart';

class VideoAddScreen extends ConsumerStatefulWidget {
  final int categoryId;
  const VideoAddScreen({super.key, required this.categoryId});

  @override
  ConsumerState<VideoAddScreen> createState() => _VideoAddScreenState();
}

class _VideoAddScreenState extends ConsumerState<VideoAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedFilePath;
  String? _selectedFileName;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _selectedFilePath = file.path;
          _selectedFileName = file.name;
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
    final directory = Directory(path.dirname(destinationPath));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    final sourceFile = File(sourcePath);
    final destinationFile = await sourceFile.copy(destinationPath);
    return destinationFile.path;
  }

  Future<void> _addVideo() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ファイルを選択してください')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final savedPath = await _copyFileToAppDirectory(_selectedFilePath!);
      await ref.read(addVideoProvider((
        name: _nameController.text.trim(),
        videoPath: savedPath,
        categoryId: widget.categoryId,
      )).future);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('動画を追加しました')),
        );
        Navigator.of(context).pop();
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
        title: const Text('動画追加'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ファイル選択', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _pickFile,
                          icon: const Icon(Icons.file_upload),
                          label: const Text('動画ファイルを選択'),
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                        ),
                      ),
                      if (_selectedFileName != null) ...[
                        const SizedBox(height: 8),
                        Text('選択されたファイル: $_selectedFileName', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '動画名',
                  hintText: '例: 家族の動画',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '動画名を入力してください';
                  }
                  if (value.trim().length > 50) {
                    return '動画名は50文字以内で入力してください';
                  }
                  return null;
                },
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _addVideo(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _addVideo,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('動画を追加'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 