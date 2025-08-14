import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsupply/models/category_model.dart';
import 'package:whatsupply/viewmodels/category_view_model.dart';

class ManageCategoriesPage extends StatefulWidget {
  const ManageCategoriesPage({super.key});

  @override
  State<ManageCategoriesPage> createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends State<ManageCategoriesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryViewModel>().fetchCategories();
    });
  }

  void _showCategoryDialog({Category? category}) {
    final isEditing = category != null;
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(
      text: isEditing ? category.name : '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            isEditing ? 'Editar Categoria' : 'Adicionar Nova Categoria',
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nome da Categoria',
                border: OutlineInputBorder(),
              ),
              validator:
                  (value) =>
                      (value == null || value.isEmpty)
                          ? 'Campo obrigatório'
                          : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            OutlinedButton(
              onPressed: () async {
                if (!(formKey.currentState?.validate() ?? false)) return;

                final categoryVM = context.read<CategoryViewModel>();
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(dialogContext);

                final successMessage =
                    isEditing
                        ? 'Categoria atualizada com sucesso!'
                        : 'Categoria adicionada com sucesso!';
                final errorMessage =
                    isEditing
                        ? 'Erro ao atualizar categoria'
                        : 'Erro ao adicionar categoria';

                try {
                  if (isEditing) {
                    await categoryVM.updateCategory(
                      categoryId: category.id,
                      name: nameController.text,
                    );
                  } else {
                    await categoryVM.addCategory(name: nameController.text);
                  }
                  navigator.pop();
                  messenger.showSnackBar(
                    SnackBar(content: Text(successMessage)),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('$errorMessage: $e')),
                  );
                }
              },
              child: Text(isEditing ? 'Salvar Alterações' : 'Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Confirmar Exclusão'),
            content: const Text(
              'Tem certeza de que deseja excluir esta categoria?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () async {
                  final categoryVM = context.read<CategoryViewModel>();
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.pop(dialogContext);

                  try {
                    await categoryVM.deleteCategory(category.id);
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Categoria excluída com sucesso!'),
                      ),
                    );
                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Erro ao excluir categoria: $e')),
                    );
                  }
                },
                child: const Text('Excluir'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryVM = context.watch<CategoryViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar Categorias')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 600;

          Widget content = Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  // Changed from Align to Row
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // Distribute space
                  children: [
                    Text(
                      'Categorias Cadastradas',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    FilledButton.icon(
                      onPressed: () => _showCategoryDialog(),
                      icon: const Icon(Icons.add, size: 24),
                      label: const Text('Adicionar Categoria'),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      categoryVM.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : categoryVM.categories.isEmpty
                          ? const Center(
                            child: Text('Nenhuma categoria encontrada.'),
                          )
                          : ListView.builder(
                            itemCount: categoryVM.categories.length,
                            itemBuilder: (context, index) {
                              final category = categoryVM.categories[index];
                              return ListTile(
                                title: Text(category.name),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed:
                                          () => _showCategoryDialog(
                                            category: category,
                                          ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed:
                                          () => _showDeleteConfirmationDialog(
                                            context,
                                            category,
                                          ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                ),
              ),
            ],
          );

          if (isWide) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800.0),
                child: content,
              ),
            );
          } else {
            return content;
          }
        },
      ),
    );
  }
}
