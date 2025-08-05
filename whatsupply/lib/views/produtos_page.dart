import 'package:flutter/material.dart';

class ProdutosPage extends StatefulWidget {
  const ProdutosPage({super.key});

  @override
  State<ProdutosPage> createState() => _ProdutosPageState();
}

class _ProdutosPageState extends State<ProdutosPage> {
  final marcaController = TextEditingController();
  String dropdownValue = 'Marca';

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
                    onPressed: () {},
                    icon: Icon(Icons.add, size: 24),
                    label: Text('Adicionar'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(15, 15, 15, 0),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: Text('Tralalelo Tralala')),
        ),
      ],
    );
  }
}
