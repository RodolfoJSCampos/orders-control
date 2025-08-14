import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsupply/models/brand_model.dart';
import 'package:whatsupply/viewmodels/brand_view_model.dart';
import 'package:whatsupply/viewmodels/category_view_model.dart';

class ManageBrandsPage extends StatefulWidget {
  const ManageBrandsPage({super.key});

  @override
  State<ManageBrandsPage> createState() => _ManageBrandsPageState();
}

class _ManageBrandsPageState extends State<ManageBrandsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BrandViewModel>().fetchBrands();
      context.read<CategoryViewModel>().fetchCategories(); // Fetch categories for selection
    });
  }

  void _showBrandDialog({Brand? brand}) {
    final isEditing = brand != null;
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(
      text: isEditing ? brand.name : '',
    );
    List<String> selectedCategories = isEditing ? List<String>.from(brand.categories) : [];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final categoryVM = context.watch<CategoryViewModel>();
            final availableCategories = categoryVM.categories.map((c) => c.name).toList();

            return AlertDialog(
              title: Text(
                isEditing ? 'Editar Marca' : 'Adicionar Nova Marca',
              ),
              content: SizedBox(
                width: 300,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nome da Marca',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Campo obrigatório'
                              : null,
                        ),
                        const SizedBox(height: 15),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Categorias',
                            border: OutlineInputBorder(),
                          ),
                          items: availableCategories
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null && !selectedCategories.contains(value)) {
                              setState(() {
                                selectedCategories.add(value);
                              });
                            }
                          },
                        ),
                        Wrap(
                          children: selectedCategories
                              .map((category) => Chip(
                                    label: Text(category),
                                    onDeleted: () {
                                      setState(() {
                                        selectedCategories.remove(category);
                                      });
                                    },
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
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

                    final brandVM = context.read<BrandViewModel>();
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(dialogContext);

                    final successMessage = isEditing
                        ? 'Marca atualizada com sucesso!'
                        : 'Marca adicionada com sucesso!';
                    final errorMessage = isEditing
                        ? 'Erro ao atualizar marca'
                        : 'Erro ao adicionar marca';

                    try {
                      if (isEditing) {
                        await brandVM.updateBrand(
                          brandId: brand.id,
                          name: nameController.text,
                          categories: selectedCategories,
                        );
                      } else {
                        await brandVM.addBrand(
                          name: nameController.text,
                          categories: selectedCategories,
                        );
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
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Brand brand) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text(
          'Tem certeza de que deseja excluir esta marca?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final brandVM = context.read<BrandViewModel>();
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(dialogContext);

              try {
                await brandVM.deleteBrand(brand.id);
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Marca excluída com sucesso!'),
                  ),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Erro ao excluir marca: $e')),
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
    final brandVM = context.watch<BrandViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Marcas'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 600;

          Widget content = Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row( // Changed from Align to Row
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space
                  children: [
                    Text( // Header for the list
                      'Marcas Cadastradas',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    FilledButton.icon(
                      onPressed: () => _showBrandDialog(),
                      icon: const Icon(Icons.add, size: 24),
                      label: const Text('Adicionar Marca'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: brandVM.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : brandVM.brands.isEmpty
                          ? const Center(child: Text('Nenhuma marca encontrada.'))
                          : ListView.builder(
                              itemCount: brandVM.brands.length,
                              itemBuilder: (context, index) {
                                final brand = brandVM.brands[index];
                                return ListTile(
                                  title: Text(brand.name),
                                  subtitle: Text(brand.categories.join(', ')),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () => _showBrandDialog(brand: brand),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () => _showDeleteConfirmationDialog(context, brand),
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
