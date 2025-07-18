import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/category_providers.dart';

class AddCategoryScreen extends ConsumerStatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  ConsumerState<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends ConsumerState<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedMediaType = 'image'; // デフォルトは画像用
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // mediaTypeを含めてカテゴリを追加
      await ref.read(addCategoryWithTypeProvider({
        'name': _nameController.text,
        'mediaType': _selectedMediaType,
      }).future);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('「${_nameController.text}」を追加しました')),
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
        title: const Text('カテゴリ追加'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'カテゴリ名',
                  hintText: '例: 家族の写真',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'カテゴリ名を入力してください';
                  }
                  if (value.trim().length > 50) {
                    return 'カテゴリ名は50文字以内で入力してください';
                  }
                  return null;
                },
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _addCategory(),
              ),
              const SizedBox(height: 16),
              // メディア種類選択
              DropdownButtonFormField<String>(
                value: _selectedMediaType,
                decoration: const InputDecoration(
                  labelText: 'メディア種類',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'image',
                    child: Row(
                      children: [
                        Icon(Icons.image),
                        SizedBox(width: 8),
                        Text('画像用'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'video',
                    child: Row(
                      children: [
                        Icon(Icons.video_library),
                        SizedBox(width: 8),
                        Text('動画用'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedMediaType = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _addCategory,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('カテゴリを追加'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 