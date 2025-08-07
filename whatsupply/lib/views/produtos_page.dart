import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsupply/models/product_model.dart';
import 'package:whatsupply/viewmodels/product_view_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProdutosPage extends StatefulWidget {
  const ProdutosPage({super.key});

  @override
  State<ProdutosPage> createState() => _ProdutosPageState();
}

class _ProdutosPageState extends State<ProdutosPage> {
  String? _selectedBrand;
  String? _selectedCategory;

  final GlobalKey<PopupMenuButtonState<String>> _brandPopupMenuKey = GlobalKey<PopupMenuButtonState<String>>();
  final GlobalKey<PopupMenuButtonState<String>> _categoryPopupMenuKey = GlobalKey<PopupMenuButtonState<String>>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductViewModel>().fetchProducts();
    });
  }

  void _showAddProductDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final imageUrlController = TextEditingController();
    final descriptionController = TextEditingController();

    final List<String> brandOptions = ['Nestlé', 'Mars', 'Ferrero', 'Lacta'];
    final List<String> categoryOptions = [
      'Chocolate',
      'Salgadinho',
      'Bebida',
      'Fini',
    ];

    String? selectedBrand;
    String? selectedCategory;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Adicionar Novo Produto'),
              content: SizedBox(
                width: 300,
                height: 250,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      spacing: 15,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          value: selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Categoria',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              categoryOptions.map((String category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                          onChanged:
                              (newValue) =>
                                  setState(() => selectedCategory = newValue),
                          validator:
                              (value) =>
                                  value == null
                                      ? 'Selecione uma categoria'
                                      : null,
                        ),
                        DropdownButtonFormField<String>(
                          value: selectedBrand,
                          decoration: const InputDecoration(
                            labelText: 'Marca',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              brandOptions.map((String brand) {
                                return DropdownMenuItem<String>(
                                  value: brand,
                                  child: Text(brand),
                                );
                              }).toList(),
                          onChanged:
                              (newValue) =>
                                  setState(() => selectedBrand = newValue),
                          validator:
                              (value) =>
                                  value == null ? 'Selecione uma marca' : null,
                        ),
                        TextFormField(
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Descrição',
                            border: OutlineInputBorder(),
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Campo obrigatório'
                                      : null,
                        ),
                        TextFormField(
                          controller: imageUrlController,
                          decoration: const InputDecoration(
                            labelText: 'URL da Imagem',
                            border: OutlineInputBorder(),
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Campo obrigatório'
                                      : null,
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
                    if (formKey.currentState?.validate() ?? false) {
                      final productVM = context.read<ProductViewModel>();
                      final navigator = Navigator.of(dialogContext);
                      final messenger = ScaffoldMessenger.of(context);

                      try {
                        await productVM.addProduct(
                          imageUrl: imageUrlController.text,
                          brand: selectedBrand!,
                          category: selectedCategory!,
                          description: descriptionController.text,
                        );

                        navigator.pop();
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Produto adicionado com sucesso!'),
                          ),
                        );
                      } catch (e) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Erro ao adicionar produto: $e'),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditProductDialog(BuildContext context, Product product) {
    final formKey = GlobalKey<FormState>();
    final imageUrlController = TextEditingController(text: product.imageUrl);
    final descriptionController = TextEditingController(
      text: product.description,
    );

    final List<String> brandOptions = ['Nestlé', 'Mars', 'Ferrero', 'Lacta'];
    final List<String> categoryOptions = [
      'Chocolate',
      'Salgadinho',
      'Bebida',
      'Fini',
    ];

    String? selectedBrand = product.brand;
    String? selectedCategory = product.category;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Editar Produto'),
              content: SizedBox(
                width: 300,
                height: 250,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      spacing: 15,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          value: selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Categoria',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              categoryOptions.map((String category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                          onChanged:
                              (newValue) =>
                                  setState(() => selectedCategory = newValue),
                          validator:
                              (value) =>
                                  value == null
                                      ? 'Selecione uma categoria'
                                      : null,
                        ),
                        DropdownButtonFormField<String>(
                          value: selectedBrand,
                          decoration: const InputDecoration(
                            labelText: 'Marca',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              brandOptions.map((String brand) {
                                return DropdownMenuItem<String>(
                                  value: brand,
                                  child: Text(brand),
                                );
                              }).toList(),
                          onChanged:
                              (newValue) =>
                                  setState(() => selectedBrand = newValue),
                          validator:
                              (value) =>
                                  value == null ? 'Selecione uma marca' : null,
                        ),
                        TextFormField(
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Descrição',
                            border: OutlineInputBorder(),
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Campo obrigatório'
                                      : null,
                        ),
                        TextFormField(
                          controller: imageUrlController,
                          decoration: const InputDecoration(
                            labelText: 'URL da Imagem',
                            border: OutlineInputBorder(),
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Campo obrigatório'
                                      : null,
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
                    if (formKey.currentState?.validate() ?? false) {
                      final productVM = context.read<ProductViewModel>();
                      final navigator = Navigator.of(dialogContext);
                      final messenger = ScaffoldMessenger.of(context);

                      try {
                        await productVM.updateProduct(
                          productId: product.id,
                          imageUrl: imageUrlController.text,
                          brand: selectedBrand!,
                          category: selectedCategory!,
                          description: descriptionController.text,
                        );

                        navigator.pop();
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Produto atualizado com sucesso!'),
                          ),
                        );
                      } catch (e) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Erro ao atualizar produto: $e'),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Salvar Alterações'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(15, 15, 15, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Lista de Produtos', style: TextStyle(fontSize: 24)),
              Row(
                spacing: 10,
                children: [
                  PopupMenuButton<String>(
                    key: _brandPopupMenuKey,
                    onSelected: (String value) {
                      setState(() {
                        _selectedBrand = value.trim().toLowerCase() == 'todos' ? null : value.trim().toLowerCase();
                      });
                    },
                    itemBuilder: (BuildContext context) {
                      final brands = [
                        'Todos',
                        ...context.read<ProductViewModel>().products.map((p) => p.brand).toSet()
                      ];
                      return brands.map((String brand) {
                        return PopupMenuItem<String>(
                          value: brand,
                          child: Text(brand),
                        );
                      }).toList();
                    },
                    child: OutlinedButton.icon(
                      onPressed: () => _brandPopupMenuKey.currentState?.showButtonMenu(),
                      icon: Icon(Icons.arrow_drop_down),
                      label: Text(_selectedBrand ?? 'Marca'),
                    ),
                  ),
                  PopupMenuButton<String>(
                    key: _categoryPopupMenuKey,
                    onSelected: (String value) {
                      setState(() {
                        _selectedCategory = value.trim().toLowerCase() == 'todas' ? null : value.trim().toLowerCase();
                      });
                    },
                    itemBuilder: (BuildContext context) {
                      final categories = [
                        'Todas',
                        ...context.read<ProductViewModel>().products.map((p) => p.category).toSet()
                      ];
                      return categories.map((String category) {
                        return PopupMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList();
                    },
                    child: OutlinedButton.icon(
                      onPressed: () => _categoryPopupMenuKey.currentState?.showButtonMenu(),
                      icon: Icon(Icons.arrow_drop_down),
                      label: Text(_selectedCategory ?? 'Categoria'),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _showAddProductDialog(context),
                    icon: Icon(Icons.add, size: 24),
                    label: Text('Adicionar'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Consumer<ProductViewModel>(
              builder: (context, productVM, child) {
                if (productVM.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredProducts = productVM.products.where((product) {
                  final brandMatch = _selectedBrand == null || product.brand.trim().toLowerCase() == _selectedBrand!.trim().toLowerCase();
                  final categoryMatch = _selectedCategory == null || (product.category.trim().toLowerCase() == _selectedCategory!.trim().toLowerCase());
                  return brandMatch && categoryMatch;
                }).toList();

                if (filteredProducts.isEmpty) {
                  return const Center(
                    child: Text('Nenhum produto encontrado.'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return ListTile(
                      leading:
                          product.imageUrl.isNotEmpty
                              ? ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: product.imageUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) {
                                      return const Icon(Icons.error);
                                    },
                                  ),
                                )
                              : const Icon(Icons.image_not_supported, size: 50),
                      title: Text(product.description),
                      subtitle: Text(
                        'Marca: ${product.brand} | Categoria: ${product.category} | SKU: ${product.sku}',
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'editar') {
                            _showEditProductDialog(context, product);
                          } else if (value == 'excluir') {
                            showDialog(
                              context: context,
                              builder:
                                  (dialogContext) => AlertDialog(
                                    title: const Text('Confirmar Exclusão'),
                                    content: const Text(
                                      'Tem certeza de que deseja excluir este produto?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(dialogContext),
                                        child: const Text('Cancelar'),
                                      ),
                                      FilledButton(
                                        onPressed: () async {
                                          final productVM =
                                              context.read<ProductViewModel>();
                                          final messenger =
                                              ScaffoldMessenger.of(context);
                                          Navigator.pop(dialogContext);

                                          try {
                                            await productVM.deleteProduct(
                                              product.id,
                                            );
                                            messenger.showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Produto excluído com sucesso!',
                                                ),
                                              ),
                                            );
                                          } catch (e) {
                                            messenger.showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Erro ao excluir produto: $e',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: const Text('Excluir'),
                                      ),
                                    ],
                                  ),
                            );
                          }
                        },
                        itemBuilder:
                            (context) => [
                              const PopupMenuItem(
                                value: 'editar',
                                child: Text('Editar'),
                              ),
                              const PopupMenuItem(
                                value: 'excluir',
                                child: Text('Excluir'),
                              ),
                            ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

