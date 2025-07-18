import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import '../providers/category_providers.dart';
import '../providers/dao_providers.dart';
import '../data/database.dart';

class EditCategoryScreen extends ConsumerStatefulWidget {
  final int categoryId;

  const EditCategoryScreen({super.key, required this.categoryId});

  @override
  ConsumerState<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends ConsumerState<EditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  Category? _category;

  @override
  void initState() {
    super.initState();
    _loadCategory();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadCategory() async {
    try {
      final categoryDao = ref.read(categoryDaoProvider);
      final categories = await categoryDao.getAllCategories();
      final category = categories.firstWhere(
        (cat) => cat.id == widget.categoryId,
        orElse: () => throw Exception('カテゴリが見つかりません'),
      );
      setState(() {
        _category = category;
        _nameController.text = category.name;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('カテゴリの読み込みに失敗しました: $e')),
        );
        context.pop();
      }
    }
  }

  Future<void> _updateCategory() async {
    if (!_formKey.currentState!.validate() || _category == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedCategory = _category!.copyWith(
        name: _nameController.text.trim(),
        updatedAt: drift.Value(DateTime.now()),
      );
      
      await ref.read(updateCategoryProvider(updatedCategory).future);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('「${_nameController.text}」を更新しました')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新に失敗しました: $e')),
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
    if (_category == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('カテゴリ編集'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('カテゴリ編集'),
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
                onFieldSubmitted: (_) => _updateCategory(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _updateCategory,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('カテゴリを更新'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 