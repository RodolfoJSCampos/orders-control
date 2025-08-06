import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsupply/viewmodels/product_view_model.dart';

class ProdutosPage extends StatefulWidget {
  const ProdutosPage({super.key});

  @override
  State<ProdutosPage> createState() => _ProdutosPageState();
}

class _ProdutosPageState extends State<ProdutosPage> {
  void _showAddProductDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final imageUrlController = TextEditingController();
    final brandController = TextEditingController();
    final categoryController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Adicionar Novo Produto'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: imageUrlController,
                    decoration: const InputDecoration(labelText: 'URL da Imagem'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  TextFormField(
                    controller: brandController,
                    decoration: const InputDecoration(labelText: 'Marca'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  TextFormField(
                    controller: categoryController,
                    decoration: const InputDecoration(labelText: 'Categoria'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Descrição'),
                    maxLines: 3,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo obrigatório' : null,
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
                if (formKey.currentState!.validate()) {
                  final productVM = context.read<ProductViewModel>();
                  try {
                    await productVM.addProduct(
                      imageUrl: imageUrlController.text,
                      brand: brandController.text,
                      category: categoryController.text,
                      description: descriptionController.text,
                    );
                    Navigator.pop(dialogContext); // Fecha o modal em caso de sucesso
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Produto adicionado com sucesso!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao adicionar produto: $e')),
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
                    onSelected: (value) {},
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(value: 'editar', child: Text('Editar')),
                          PopupMenuItem(
                            value: 'excluir',
                            child: Text('Excluir'),
                          ),
                        ],
                  ),                  
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.arrow_drop_down),
                    label: Text('Marca'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.arrow_drop_down),
                    label: Text('Categoria'),
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
            child: const Center(child: Text('Tralalelo Tralala')),
          ),
        ),
      ],
    );
  }
}
