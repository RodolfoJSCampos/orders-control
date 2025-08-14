import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsupply/models/contact_model.dart';
import 'package:whatsupply/viewmodels/contact_view_model.dart';

class ContatosPage extends StatefulWidget {
  const ContatosPage({super.key});

  @override
  State<ContatosPage> createState() => _ContatosPageState();
}

class _ContatosPageState extends State<ContatosPage> {
  final Set<String> _selectedContactIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContactViewModel>().fetchContacts();
    });
  }

  void _showContactDialog({Contact? contact}) {
    final isEditing = contact != null;
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(
      text: isEditing ? contact.name : '',
    );
    final companyController = TextEditingController(
      text: isEditing ? contact.company : '',
    );
    final siteController = TextEditingController(
      text: isEditing ? contact.site : '',
    );
    final whatsappController = TextEditingController(
      text: isEditing ? contact.whatsapp : '',
    );
    final appController = TextEditingController(
      text: isEditing ? contact.app : '',
    );
    bool isWholesaler = isEditing ? contact.isWholesaler : false;
    List<String> selectedBrands = isEditing ? List<String>.from(contact.brands) : [];

    // Hardcoded options for now, will be fetched from Firebase.
    final brandOptions = ['Marca A', 'Marca B', 'Marca C'];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            const fieldSpacing = SizedBox(height: 15);

            return AlertDialog(
              title: Text(
                isEditing ? 'Editar Contato' : 'Adicionar Novo Contato',
              ),
              content: SizedBox(
                width: 400,
                height: 500,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nome',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              (value == null || value.isEmpty)
                                  ? 'Campo obrigatório'
                                  : null,
                        ),
                        fieldSpacing,
                        TextFormField(
                          controller: companyController,
                          decoration: const InputDecoration(
                            labelText: 'Empresa',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        fieldSpacing,
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Marcas',
                            border: OutlineInputBorder(),
                          ),
                          items: brandOptions
                              .map(
                                (b) => DropdownMenuItem(
                                  value: b,
                                  child: Text(b),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null && !selectedBrands.contains(value)) {
                              setState(() {
                                selectedBrands.add(value);
                              });
                            }
                          },
                        ),
                        Wrap(
                          children: selectedBrands
                              .map((brand) => Chip(
                                    label: Text(brand),
                                    onDeleted: () {
                                      setState(() {
                                        selectedBrands.remove(brand);
                                      });
                                    },
                                  ))
                              .toList(),
                        ),
                        fieldSpacing,
                        Row(
                          children: [
                            Checkbox(
                              value: isWholesaler,
                              onChanged: (value) {
                                setState(() {
                                  isWholesaler = value ?? false;
                                });
                              },
                            ),
                            const Text('Atacadista/Distribuidor'),
                          ],
                        ),
                        fieldSpacing,
                        TextFormField(
                          controller: siteController,
                          decoration: const InputDecoration(
                            labelText: 'Site',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        fieldSpacing,
                        TextFormField(
                          controller: whatsappController,
                          decoration: const InputDecoration(
                            labelText: 'Whatsapp',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        fieldSpacing,
                        TextFormField(
                          controller: appController,
                          decoration: const InputDecoration(
                            labelText: 'Aplicativo',
                            border: OutlineInputBorder(),
                          ),
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

                    final contactVM = context.read<ContactViewModel>();
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(dialogContext);

                    final successMessage = isEditing
                        ? 'Contato atualizado com sucesso!'
                        : 'Contato adicionado com sucesso!';
                    final errorMessage = isEditing
                        ? 'Erro ao atualizar contato'
                        : 'Erro ao adicionar contato';

                    try {
                      if (isEditing) {
                        await contactVM.updateContact(
                          contactId: contact.id,
                          name: nameController.text,
                          company: companyController.text,
                          brands: selectedBrands,
                          isWholesaler: isWholesaler,
                          site: siteController.text,
                          whatsapp: whatsappController.text,
                          app: appController.text,
                        );
                      } else {
                        await contactVM.addContact(
                          name: nameController.text,
                          company: companyController.text,
                          brands: selectedBrands,
                          isWholesaler: isWholesaler,
                          site: siteController.text,
                          whatsapp: whatsappController.text,
                          app: appController.text,
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

  void _showDeleteConfirmationDialog(BuildContext context, Contact contact) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text(
          'Tem certeza de que deseja excluir este contato?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final contactVM = context.read<ContactViewModel>();
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(
                dialogContext,
              ); 

              try {
                await contactVM.deleteContact(contact.id);
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Contato excluído com sucesso!'),
                  ),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Erro ao excluir contato: $e')),
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
    final contactVM = context.watch<ContactViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Lista de Contatos', style: TextStyle(fontSize: 24)),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: () => _showContactDialog(),
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
            child: contactVM.isLoading
                ? const Center(child: CircularProgressIndicator())
                : contactVM.contacts.isEmpty
                    ? const Center(child: Text('Nenhum contato encontrado.'))
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Nome')),
                            DataColumn(label: Text('Empresa')),
                            DataColumn(label: Text('Marcas')),
                            DataColumn(label: Text('Atacadista/Distribuidor')),
                            DataColumn(label: Text('Site')),
                            DataColumn(label: Text('Whatsapp')),
                            DataColumn(label: Text('Aplicativo')),
                            DataColumn(label: Text('Ações')),
                          ],
                          rows: contactVM.contacts.map((contact) {
                            final isSelected =
                                _selectedContactIds.contains(contact.id);
                            return DataRow(
                              selected: isSelected,
                              onSelectChanged: (isSelected) {
                                setState(() {
                                  if (isSelected ?? false) {
                                    _selectedContactIds.add(contact.id);
                                  } else {
                                    _selectedContactIds.remove(contact.id);
                                  }
                                });
                              },
                              cells: [
                                DataCell(Text(contact.name)),
                                DataCell(Text(contact.company)),
                                DataCell(Text(contact.brands.join(', '))),
                                DataCell(Text(contact.isWholesaler ? 'Sim' : 'Não')),
                                DataCell(Text(contact.site)),
                                DataCell(Text(contact.whatsapp)),
                                DataCell(Text(contact.app)),
                                DataCell(
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'editar') {
                                        _showContactDialog(
                                          contact: contact,
                                        );
                                      } else if (value == 'excluir') {
                                        _showDeleteConfirmationDialog(
                                          context,
                                          contact,
                                        );
                                      }
                                    },
                                    itemBuilder: (context) => [
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