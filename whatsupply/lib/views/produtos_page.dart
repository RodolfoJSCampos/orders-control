import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsupply/models/product_model.dart';
import 'package:whatsupply/viewmodels/product_view_model.dart';

class ProdutosPage extends StatefulWidget {
  const ProdutosPage({super.key});

  @override
  State<ProdutosPage> createState() => _ProdutosPageState();
}

class _ProdutosPageState extends State<ProdutosPage> {
  String? _selectedBrand;
  String? _selectedCategory;

  // Keys for the filter popup menus
  final GlobalKey<PopupMenuButtonState<String>> _brandMenuKey = GlobalKey();
  final GlobalKey<PopupMenuButtonState<String>> _categoryMenuKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductViewModel>().fetchProducts();
    });
  }

  // A single, reusable dialog for adding and editing products.
  void _showProductDialog({Product? product}) {
    final isEditing = product != null;
    final formKey = GlobalKey<FormState>();
    final imageUrlController = TextEditingController(
      text: isEditing ? product.imageUrl : '',
    );
    final descriptionController = TextEditingController(
      text: isEditing ? product.description : '',
    );

    // Hardcoded options, could be fetched from a view model or service.
    final brandOptions = ['Nestlé', 'Mars', 'Ferrero', 'Lacta', 'Kellogg\'s'];
    final categoryOptions = ['Chocolate', 'Salgadinho', 'Bebida', 'Fini'];

    String? selectedBrand = isEditing ? product.brand : null;
    String? selectedCategory = isEditing ? product.category : null;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Helper to create consistent spacing between form fields.
            const fieldSpacing = SizedBox(height: 15);

            return AlertDialog(
              title: Text(
                isEditing ? 'Editar Produto' : 'Adicionar Novo Produto',
              ),
              content: SizedBox(
                width: 300,
                height: 250,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          value: selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Categoria',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              categoryOptions
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (value) =>
                                  setState(() => selectedCategory = value),
                          validator:
                              (value) =>
                                  value == null
                                      ? 'Selecione uma categoria'
                                      : null,
                        ),
                        fieldSpacing,
                        DropdownButtonFormField<String>(
                          value: selectedBrand,
                          decoration: const InputDecoration(
                            labelText: 'Marca',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              brandOptions
                                  .map(
                                    (b) => DropdownMenuItem(
                                      value: b,
                                      child: Text(b),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (value) => setState(() => selectedBrand = value),
                          validator:
                              (value) =>
                                  value == null ? 'Selecione uma marca' : null,
                        ),
                        fieldSpacing,
                        TextFormField(
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Descrição',
                            border: OutlineInputBorder(),
                          ),
                          validator:
                              (value) =>
                                  (value == null || value.isEmpty)
                                      ? 'Campo obrigatório'
                                      : null,
                        ),
                        fieldSpacing,
                        TextFormField(
                          controller: imageUrlController,
                          decoration: const InputDecoration(
                            labelText: 'URL da Imagem',
                            border: OutlineInputBorder(),
                          ),
                          validator:
                              (value) =>
                                  (value == null || value.isEmpty)
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
                    if (!(formKey.currentState?.validate() ?? false)) return;

                    final productVM = context.read<ProductViewModel>();
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(dialogContext);

                    final successMessage =
                        isEditing
                            ? 'Produto atualizado com sucesso!'
                            : 'Produto adicionado com sucesso!';
                    final errorMessage =
                        isEditing
                            ? 'Erro ao atualizar produto'
                            : 'Erro ao adicionar produto';

                    try {
                      if (isEditing) {
                        await productVM.updateProduct(
                          productId: product.id,
                          imageUrl: imageUrlController.text,
                          brand: selectedBrand!,
                          category: selectedCategory!,
                          description: descriptionController.text,
                        );
                      } else {
                        await productVM.addProduct(
                          imageUrl: imageUrlController.text,
                          brand: selectedBrand!,
                          category: selectedCategory!,
                          description: descriptionController.text,
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

  // Shows a confirmation dialog before deleting a product.
  void _showDeleteConfirmationDialog(BuildContext context, Product product) {
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
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () async {
                  final productVM = context.read<ProductViewModel>();
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.pop(
                    dialogContext,
                  ); // Close the confirmation dialog first.

                  try {
                    await productVM.deleteProduct(product.id);
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Produto excluído com sucesso!'),
                      ),
                    );
                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Erro ao excluir produto: $e')),
                    );
                  }
                },
                child: const Text('Excluir'),
              ),
            ],
          ),
    );
  }

  // New method to show product details in a modal
  void _showProductDetailsDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(product.description),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Marca: ${product.brand}'),
              Text('Categoria: ${product.category}'),
              Text('SKU: ${product.sku}'),
              // Add more product details here as needed
              if (product.imageUrl.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  // A helper widget to build the filter buttons, reducing code duplication.
  Widget _buildFilterButton({
    required GlobalKey<PopupMenuButtonState<String>> menuKey,
    required String hint,
    required String? selectedValue,
    required List<String> items,
    required ValueChanged<String?> onSelected,
  }) {
    final uniqueItems = ['Todas', ...items.toSet()];
    return PopupMenuButton<String>(
      key: menuKey,
      onSelected: (value) {
        onSelected(value.toLowerCase() == 'todas' ? null : value);
      },
      itemBuilder:
          (context) =>
              uniqueItems
                  .map((item) => PopupMenuItem(value: item, child: Text(item)))
                  .toList(),
      child: OutlinedButton.icon(
        onPressed: () => menuKey.currentState?.showButtonMenu(),
        icon: const Icon(Icons.arrow_drop_down),
        label: Text(selectedValue ?? hint),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productVM = context.watch<ProductViewModel>();

    final filteredProducts =
        productVM.products.where((product) {
          final brandMatch =
              _selectedBrand == null ||
              product.brand.toLowerCase() == _selectedBrand!.toLowerCase();
          final categoryMatch =
              _selectedCategory == null ||
              product.category.toLowerCase() ==
                  _selectedCategory!.toLowerCase();
          return brandMatch && categoryMatch;
        }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Lista de Produtos', style: TextStyle(fontSize: 24)),
              Row(
                children: [
                  _buildFilterButton(
                    menuKey: _brandMenuKey,
                    hint: 'Marca',
                    selectedValue: _selectedBrand,
                    items: productVM.products.map((p) => p.brand).toList(),
                    onSelected:
                        (value) => setState(() => _selectedBrand = value),
                  ),
                  const SizedBox(width: 10),
                  _buildFilterButton(
                    menuKey: _categoryMenuKey,
                    hint: 'Categoria',
                    selectedValue: _selectedCategory,
                    items: productVM.products.map((p) => p.category).toList(),
                    onSelected:
                        (value) => setState(() => _selectedCategory = value),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    onPressed: () => _showProductDialog(),
                    icon: const Icon(Icons.add, size: 24),
                    label: const Text('Adicionar'),
                  ),
                ],
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
            child:
                productVM.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredProducts.isEmpty
                    ? const Center(child: Text('Nenhum produto encontrado.'))
                    : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                          dataRowHeight: 60.0,
                          columns: const [
                          DataColumn(label: Text('Imagem')),
                          DataColumn(label: Text('Descrição')),
                          DataColumn(label: Text('Marca')),
                          DataColumn(label: Text('Categoria')),
                          DataColumn(label: Text('SKU')),
                          DataColumn(label: Text('Menor Preço')),
                          DataColumn(label: Text('Último Preço')),
                          DataColumn(label: Text('Ações')),
                        ],
                        rows:
                            filteredProducts.map((product) {
                              return DataRow(
                                onSelectChanged: (isSelected) {
                                  if (isSelected ?? false) {
                                    _showProductDetailsDialog(context, product);
                                  }
                                },
                                cells: [
                                  DataCell(
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 5.0,
                                      ),
                                      child:
                                          product.imageUrl.isNotEmpty
                                              ? CachedNetworkImage(
                                                imageUrl: product.imageUrl,
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                                placeholder:
                                                    (context, url) =>
                                                        const CircularProgressIndicator(),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Icon(Icons.error),
                                              )
                                              : SizedBox(
                                                width: 50,
                                                height: 50,
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  size: 50,
                                                ),
                                              ),
                                    ),
                                  ),
                                  DataCell(
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 5.0,
                                      ),
                                      child: Text(product.description),
                                    ),
                                  ),
                                  DataCell(
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 5.0,
                                      ),
                                      child: Text(product.brand),
                                    ),
                                  ),
                                  DataCell(
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 5.0,
                                      ),
                                      child: Text(product.category),
                                    ),
                                  ),
                                  DataCell(
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 5.0,
                                      ),
                                      child: Text(product.sku),
                                    ),
                                  ),
                                  DataCell(
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 5.0,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: const [
                                          Text(
                                            'Fornecedor A',
                                            style: TextStyle(fontSize: 10.0),
                                          ),
                                          Text(
                                            'R\$ 10,00',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            '07/08/2025',
                                            style: TextStyle(fontSize: 10.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 5.0,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: const [
                                          Text(
                                            'Fornecedor B',
                                            style: TextStyle(fontSize: 10.0),
                                          ),
                                          Text(
                                            'R\$ 12,00',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            '07/08/2025',
                                            style: TextStyle(fontSize: 10.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 5.0,
                                      ),
                                      child: PopupMenuButton<String>(
                                        onSelected: (value) {
                                          if (value == 'editar') {
                                            _showProductDialog(
                                              product: product,
                                            );
                                          } else if (value == 'excluir') {
                                            _showDeleteConfirmationDialog(
                                              context,
                                              product,
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
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                      ),
                    ),
          ),
        ),
      ],
    );
  }
}
