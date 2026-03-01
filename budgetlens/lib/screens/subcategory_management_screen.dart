import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../build_provider.dart';

class SubcategoryManagementScreen extends StatefulWidget {
  const SubcategoryManagementScreen({super.key});

  @override
  State<SubcategoryManagementScreen> createState() =>
      _SubcategoryManagementScreenState();
}

class _SubcategoryManagementScreenState
    extends State<SubcategoryManagementScreen> {
  final TextEditingController _addController = TextEditingController();

  void _showRenameDialog(BuildContext context, String oldName) {
    final TextEditingController renameController = TextEditingController(
      text: oldName,
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename Subcategory'),
          content: TextField(
            controller: renameController,
            decoration: const InputDecoration(
              labelText: 'New Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newName = renameController.text.trim();
                if (newName.isNotEmpty && newName != oldName) {
                  context.read<BudgetProvider>().renameSubCategory(
                    oldName,
                    newName,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = context.watch<BudgetProvider>();
    final subCategories = budgetProvider.state.subCategories;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Subcategories')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addController,
                    decoration: const InputDecoration(
                      labelText: 'Add New Subcategory',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () {
                    final name = _addController.text.trim();
                    if (name.isNotEmpty) {
                      budgetProvider.addSubCategory(name);
                      _addController.clear();
                    }
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: subCategories.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final category = subCategories[index];
                return ListTile(
                  title: Text(category),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _showRenameDialog(context, category),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: colorScheme.error,
                        onPressed: () {
                          if (subCategories.length <= 1) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'At least one subcategory must remain.',
                                ),
                              ),
                            );
                            return;
                          }
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Subcategory'),
                              content: Text(
                                'Are you sure you want to delete "$category"? Transactions in this subcategory will keep their original name but you won\'t be able to select this subcategory for new transactions.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    budgetProvider.removeSubCategory(category);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
