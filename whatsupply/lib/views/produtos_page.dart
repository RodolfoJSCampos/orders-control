import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:whatsupply/models/product_model.dart';
import 'package:whatsupply/viewmodels/brand_view_model.dart';
import 'package:whatsupply/viewmodels/category_view_model.dart';
import 'package:whatsupply/viewmodels/product_view_model.dart';

class ProdutosPage extends StatefulWidget {
  const ProdutosPage({super.key});

  @override
  State<ProdutosPage> createState() => _ProdutosPageState();
}

class _ProdutosPageState extends State<ProdutosPage> {
  String? _selectedBrand;
  String? _selectedCategory;
  final Set<String> _selectedProductIds = {};

  @override
  void initState() {
    super.initState();
    // Fetch initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductViewModel>().fetchProducts();
      context.read<BrandViewModel>().fetchBrands();
      context.read<CategoryViewModel>().fetchCategories();
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedProductIds.clear();
    });
  }

  void _showProductDialog({Product? product}) {
    final isEditing = product != null;
    final formKey = GlobalKey<FormState>();
    final imageUrlController = TextEditingController(
      text: isEditing ? product.imageUrl : '',
    );
    final descriptionController = TextEditingController(
      text: isEditing ? product.description : '',
    );

    final brandVM = context.read<BrandViewModel>();
    final categoryVM = context.read<CategoryViewModel>();

    String? selectedBrand = isEditing ? product.brand : null;
    String? selectedCategory = isEditing ? product.category : null;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                isEditing ? 'Editar Produto' : 'Adicionar Novo Produto',
              ),
              content: Form(
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
                            categoryVM.categories
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c.name,
                                    child: Text(c.name),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (value) => setState(() => selectedCategory = value),
                        validator:
                            (value) =>
                                value == null
                                    ? 'Selecione uma categoria'
                                    : null,
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: selectedBrand,
                        decoration: const InputDecoration(
                          labelText: 'Marca',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            brandVM.brands
                                .map(
                                  (b) => DropdownMenuItem(
                                    value: b.name,
                                    child: Text(b.name),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (value) => setState(() => selectedBrand = value),
                        validator:
                            (value) =>
                                value == null ? 'Selecione uma marca' : null,
                      ),
                      const SizedBox(height: 15),
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
                      const SizedBox(height: 15),
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
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
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
                  child: Text(isEditing ? 'Salvar' : 'Adicionar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Product product) {
    final productVM = context.read<ProductViewModel>();
    final messenger = ScaffoldMessenger.of(context);

    showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Confirmar Exclusão'),
            content: const Text(
              'Tem certeza de que deseja excluir este produto?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Excluir'),
              ),
            ],
          ),
    ).then((confirmed) {
      if (confirmed == true) {
        productVM
            .deleteProduct(product.id)
            .then((_) {
              messenger.showSnackBar(
                const SnackBar(
                  content: Text(
                    'Produto excluído com sucesso!',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            })
            .catchError((e) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    'Erro ao excluir produto: $e',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            });
      }
    });
  }

  void _showBulkDeleteDialog() {
    final productVM = context.read<ProductViewModel>();
    final messenger = ScaffoldMessenger.of(context);

    showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Confirmar Exclusão em Massa'),
            content: Text(
              'Tem certeza de que deseja excluir os ${_selectedProductIds.length} produtos selecionados?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Excluir'),
              ),
            ],
          ),
    ).then((confirmed) {
      if (confirmed == true) {
        productVM
            .deleteProducts(_selectedProductIds.toList())
            .then((_) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    '${_selectedProductIds.length} produtos excluídos com sucesso!',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.green,
                ),
              );
              _clearSelection();
            })
            .catchError((e) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    'Erro ao excluir produtos: $e',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            });
      }
    });
  }

  void _showBulkReportDialog() {
    final productVM = context.read<ProductViewModel>();
    final selectedProducts =
        productVM.products
            .where((p) => _selectedProductIds.contains(p.id))
            .toList();

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Relatório de Produtos Selecionados'),
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: ListBody(
                  children:
                      selectedProducts
                          .map(
                            (product) => Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.description,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text('Marca: ${product.brand}'),
                                    Text('Categoria: ${product.category}'),
                                    Text('SKU: ${product.sku}'),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Fechar'),
              ),
              FilledButton(
                onPressed: () {
                  // TODO: Implement report generation logic (e.g., PDF, CSV)
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Funcionalidade de relatório ainda não implementada.',
                      ),
                    ),
                  );
                },
                child: const Text('Exportar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productVM = context.watch<ProductViewModel>();
    final brandVM = context.watch<BrandViewModel>();
    final categoryVM = context.watch<CategoryViewModel>();

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

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(brandVM, categoryVM),
          Expanded(
            child:
                productVM.isLoading
                    ? _buildShimmerLoading()
                    : filteredProducts.isEmpty
                    ? _buildEmptyState()
                    : _buildProductGrid(filteredProducts),
          ),
        ],
      ),
      floatingActionButton:
          _selectedProductIds.isEmpty
              ? FloatingActionButton(
                onPressed: () => _showProductDialog(),
                tooltip: 'Adicionar Produto',
                child: const Icon(Icons.add),
              )
              : null,
      bottomNavigationBar:
          _selectedProductIds.isNotEmpty ? _buildBottomAppBar() : null,
    );
  }

  Widget _buildHeader(BrandViewModel brandVM, CategoryViewModel categoryVM) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16.0,
        runSpacing: 16.0,
        children: [
          if (brandVM.brands.isNotEmpty || categoryVM.categories.isNotEmpty)
            _buildFilterBar(brandVM, categoryVM),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BrandViewModel brandVM, CategoryViewModel categoryVM) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16.0,
          runSpacing: 8.0,
          children: [
            SizedBox(
              width: 210,
              height: 40,
              child: DropdownButtonFormField<String>(
                value: _selectedBrand,
                hint: const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text('Filtrar por Marca'),
                ),
                isDense: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 12,
                  ),
                ),
                onChanged: (value) => setState(() => _selectedBrand = value),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text('Todas as Marcas'),
                    ),
                  ),
                  ...brandVM.brands.map(
                    (b) => DropdownMenuItem(
                      value: b.name,
                      child: Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text(b.name),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 210,
              height: 40,
              child: DropdownButtonFormField<String>(
                value: _selectedCategory,
                hint: const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text('Filtrar por Categoria'),
                ),
                isDense: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 12,
                  ),
                ),
                onChanged: (value) => setState(() => _selectedCategory = value),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text('Todas as Categorias'),
                    ),
                  ),
                  ...categoryVM.categories.map(
                    (c) => DropdownMenuItem(
                      value: c.name,
                      child: Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text(c.name),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0), // Spacing between filters and clear button
        if (_selectedBrand != null || _selectedCategory != null)
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _selectedBrand = null;
                _selectedCategory = null;
              });
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            ),
            icon: const Icon(Icons.clear),
            label: const Text('Limpar Filtros'),
          ),
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Nenhum produto encontrado',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(List<Product> products) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = (constraints.maxWidth / 250).floor().clamp(1, 6);
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            final isSelected = _selectedProductIds.contains(product.id);
            return ProductCard(
              product: product,
              isSelected: isSelected,
              onSelected: (value) {
                setState(() {
                  if (value == true) {
                    _selectedProductIds.add(product.id);
                  } else {
                    _selectedProductIds.remove(product.id);
                  }
                });
              },
              onEdit: () => _showProductDialog(product: product),
              onDelete: () => _showDeleteConfirmationDialog(context, product),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomAppBar() {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.close), onPressed: _clearSelection),
          Text('${_selectedProductIds.length} selecionado(s)'),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.report),
                onPressed: _showBulkReportDialog,
                tooltip: 'Gerar Relatório',
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _showBulkDeleteDialog,
                tooltip: 'Excluir Selecionados',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final bool isSelected;
  final ValueChanged<bool?> onSelected;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCard({
    super.key,
    required this.product,
    required this.isSelected,
    required this.onSelected,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: isSelected ? 8 : 4,
      color: isSelected ? theme.colorScheme.primaryContainer : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => onSelected(!isSelected),
        borderRadius: BorderRadius.circular(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                      errorWidget:
                          (context, url, error) =>
                              const Icon(Icons.image_not_supported, size: 50),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          onEdit();
                        } else if (value == 'delete') {
                          onDelete();
                        }
                      },
                      itemBuilder:
                          (BuildContext context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Text('Editar'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Text('Excluir'),
                            ),
                          ],
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(100),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.more_vert, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.description,
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.brand,
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'SKU: ${product.sku}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 0.0, bottom: 2.0),
              child: const Divider(height: 1,),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPriceInfo(
                    context,
                    label: 'Menor Preço',
                    priceString: 'R\$ 10,00',
                  ),
                  _buildPriceDifferenceIndicator(context, 12.0, 15.5), // Placeholder values
                  _buildPriceInfo(
                    context,
                    label: 'Último Preço',
                    priceString: 'R\$ 12,50',
                    alignment: CrossAxisAlignment.end,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceDifferenceIndicator(BuildContext context, double lowestPricePlaceholder, double lastPricePlaceholder) {
    final theme = Theme.of(context); // Get theme to access colorScheme
    if (lastPricePlaceholder > lowestPricePlaceholder) {
      final percentage = ((lastPricePlaceholder - lowestPricePlaceholder) / lowestPricePlaceholder) * 100;
      return Column( // Changed from Chip to Column
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.keyboard_arrow_up, color: theme.colorScheme.error, size: 12), // Material color
          Text(
            '+${percentage.toStringAsFixed(0)}%',
            style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold, fontSize: 10), // Material color
          ),
        ],
      );
    } else {
      return Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 24); // Using primary as a "verified" color
    }
  }

  Widget _buildPriceInfo(
    BuildContext context, {
    required String label,
    required String priceString,
    CrossAxisAlignment alignment = CrossAxisAlignment.start,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          priceString,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}