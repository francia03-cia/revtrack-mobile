import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/startup_repository.dart';
import '../../../../data/models/category.dart';
import '../../../../data/models/startup.dart';
import '../../../../core/theme/colors.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final CategoryRepository _categoryRepository = CategoryRepository();
  final StartupRepository _startupRepository = StartupRepository();
  
  List<CategoryModel> _categories = [];
  List<StartupModel> _startups = [];
  bool _isLoading = true;
  int? _selectedStartupId;
  String _errorMessage = '';

  // Couleurs prédéfinies
  final List<String> _presetColors = [
    '#4F46E5', '#10B981', '#F59E0B', '#EF4444', '#8B5CF6',
    '#EC4899', '#14B8A6', '#F97316', '#6366F1', '#22D3EE',
    '#A78BFA', '#34D399', '#FB923C', '#F472B6', '#60A5FA',
  ];

  // ✅ CORRECTION : Utiliser un Map simple sans codePoint
  final Map<String, IconData> _iconMap = {
    'shopping_bag': Icons.shopping_bag,
    'briefcase': Icons.business_center,
    'repeat': Icons.repeat,
    'gift': Icons.card_giftcard,
    'more-horizontal': Icons.more_horiz,
    'computer': Icons.computer,
    'phone': Icons.phone,
    'build': Icons.build,
    'star': Icons.star,
    'favorite': Icons.favorite,
    'home': Icons.home,
    'work': Icons.work,
    'school': Icons.school,
    'store': Icons.store,
    'restaurant': Icons.restaurant,
    'code': Icons.code,
    'smartphone': Icons.smartphone,
    'cpu': Icons.memory,
    'server': Icons.storage,
    'trending-up': Icons.trending_up,
    'zap': Icons.flash_on,
    'wifi': Icons.wifi,
    'shield': Icons.shield,
    'graduation-cap': Icons.school,
  };

  // Liste des noms d'icônes pour l'affichage
  final List<String> _presetIcons = [
    'shopping_bag', 'briefcase', 'repeat', 'gift', 'more-horizontal',
    'computer', 'phone', 'build', 'star', 'favorite',
    'home', 'work', 'school', 'store', 'restaurant',  'code',           // Développement web
  'smartphone',     // Développement mobile
  'cpu',            // IA & automatisation
  'server',         // Administration systèmes
  'trending-up',    // Conseil stratégie IT
  'zap',            // Électronique
  'cpu',            // Systèmes embarqués
  'wifi',           // IoT
  'shield',         // Cybersécurité
  'graduation-cap',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      _startups = await _startupRepository.getStartups();
      if (_startups.isNotEmpty && _selectedStartupId == null) {
        _selectedStartupId = _startups.first.id;
      }

      if (_selectedStartupId != null) {
        _categories = await _categoryRepository.getCategories(
          startupId: _selectedStartupId,
        );
        print('📂 Categories: ${_categories.length}');
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Categories Error: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  void _showAddCategoryDialog({CategoryModel? categoryToEdit}) {
    final isEditing = categoryToEdit != null;
    final nameController = TextEditingController(text: categoryToEdit?.name ?? '');
    String selectedColor = categoryToEdit?.color ?? _presetColors.first;
    String selectedIcon = categoryToEdit?.icon ?? _presetIcons.first;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(
                isEditing ? 'Modifier la catégorie' : 'Nouvelle catégorie',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Nom de la catégorie',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.category),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Couleur
                      const Text(
                        'Couleur',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _presetColors.map((color) {
                          final isSelected = selectedColor == color;
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                selectedColor = color;
                              });
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Color(int.parse(color.substring(1), radix: 16) + 0xFF000000),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? Colors.black : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      
                      // Icône
                      const Text(
                        'Icône',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _presetIcons.map((iconName) {
                          final isSelected = selectedIcon == iconName;
                          final iconData = _iconMap[iconName] ?? Icons.category;
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                selectedIcon = iconName;
                              });
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                iconData,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    AppStrings.cancel,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Veuillez saisir un nom'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    try {
                      Navigator.pop(context);
                      
                      if (isEditing) {
                        await _categoryRepository.updateCategory(
                          id: categoryToEdit.id,
                          name: name,
                          color: selectedColor,
                          icon: selectedIcon,
                          startupId: _selectedStartupId!,
                          parentId: categoryToEdit.parentId,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Catégorie modifiée avec succès'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        await _categoryRepository.createCategory(
                          name: name,
                          color: selectedColor,
                          icon: selectedIcon,
                          startupId: _selectedStartupId!,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Catégorie créée avec succès'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                      
                      await _refreshData();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('❌ Erreur: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(isEditing ? 'Modifier' : 'Créer'),
                )
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(CategoryModel category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer la catégorie'),
        content: Text(
          'Voulez-vous vraiment supprimer la catégorie "${category.name}" ?\n\n'
          '⚠️ Attention : Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                Navigator.pop(context);
                await _categoryRepository.deleteCategory(category.id);
                await _refreshData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Catégorie supprimée avec succès'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Erreur: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(_errorMessage, textAlign: TextAlign.center),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshData,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des catégories'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: _categories.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.category_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune catégorie',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showAddCategoryDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Créer une catégorie'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final iconData = _iconMap[category.icon] ?? Icons.category;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(int.parse(
                            category.color.substring(1),
                            radix: 16,
                          ) + 0xFF000000).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          iconData,
                          color: Color(int.parse(
                            category.color.substring(1),
                            radix: 16,
                          ) + 0xFF000000),
                        ),
                      ),
                      title: Text(
                        category.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        category.isDefault ? 'Catégorie par défaut' : '',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!category.isDefault) ...[
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showAddCategoryDialog(
                                categoryToEdit: category,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(category),
                            ),
                          ],
                          if (category.isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Défaut',
                                style: TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}