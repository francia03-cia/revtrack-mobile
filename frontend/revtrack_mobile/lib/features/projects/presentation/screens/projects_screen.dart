import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../data/repositories/project_repository.dart';
import '../../../../data/repositories/startup_repository.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/models/project.dart';
import '../../../../data/models/startup.dart';
import '../../../../data/models/category.dart';
import '../../../../core/theme/colors.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final ProjectRepository _projectRepository = ProjectRepository();
  final StartupRepository _startupRepository = StartupRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();
  
  List<ProjectModel> _projects = [];
  List<CategoryModel> _categories = [];
  List<StartupModel> _startups = [];
  bool _isLoading = true;
  String _searchQuery = '';
  int? _selectedCategoryId;
  int? _selectedStartupId;
  String? _selectedProgressStatus;
  String? _selectedBudgetStatus;
  String _errorMessage = '';

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
        
        _projects = await _projectRepository.getProjects(
          startupId: _selectedStartupId,
          search: _searchQuery.isNotEmpty ? _searchQuery : null,
          categoryId: _selectedCategoryId,
          progressStatus: _selectedProgressStatus,
          budgetStatus: _selectedBudgetStatus,
        );
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Projects Error: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  void _showProjectDialog({ProjectModel? project}) {
    final isEditing = project != null;
    final nameController = TextEditingController(text: project?.name ?? '');
    final descriptionController = TextEditingController(text: project?.description ?? '');
    
    // ✅ Initialiser avec des valeurs non nullables
    DateTime startDate = project?.startDate ?? DateTime.now();
    DateTime? endDate = project?.endDate;
    double? budget = project?.budget;
    int? selectedCategoryId = project?.categoryId ?? _categories.firstOrNull?.id;
    String? selectedProgressStatus = project?.progressStatus ?? 'ongoing';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(
                isEditing ? 'Modifier le projet' : 'Nouveau projet',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Nom
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Nom du projet',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.folder),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Date de début
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: startDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setDialogState(() {
                              startDate = date;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Date de début',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            '${startDate.day}/${startDate.month}/${startDate.year}',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Date de fin
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: endDate ?? startDate,
                            firstDate: startDate, // ✅ startDate est non-nullable ici
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setDialogState(() {
                              endDate = date;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Date de fin (estimation)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            endDate != null
                                ? '${endDate!.day}/${endDate!.month}/${endDate!.year}'
                                : 'Sélectionner une date (optionnel)',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Budget
                      TextField(
                        controller: TextEditingController(
                          text: budget != null ? budget.toString() : '',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          budget = double.tryParse(value);
                        },
                        decoration: InputDecoration(
                          labelText: 'Budget (Ar)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.attach_money),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Catégorie
                      DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          labelText: AppStrings.category,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.category),
                        ),
                        value: selectedCategoryId,
                        items: _categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat.id,
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Color(int.parse(
                                      cat.color.substring(1),
                                      radix: 16,
                                    ) + 0xFF000000),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(cat.name),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedCategoryId = value;
                          });
                        },
                        isExpanded: true,
                      ),
                      const SizedBox(height: 16),
                      
                      // Description
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Description (optionnel)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.description),
                        ),
                      ),
                      
                      if (isEditing) ...[
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Statut d\'avancement',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.timeline),
                          ),
                          value: selectedProgressStatus,
                          items: const [
                            DropdownMenuItem(
                              value: 'ongoing',
                              child: Text('🔄 En cours'),
                            ),
                            DropdownMenuItem(
                              value: 'completed',
                              child: Text('✅ Terminé'),
                            ),
                            DropdownMenuItem(
                              value: 'delayed',
                              child: Text('⚠️ En retard'),
                            ),
                          ],
                          onChanged: (value) {
                            setDialogState(() {
                              selectedProgressStatus = value;
                            });
                          },
                        ),
                      ],
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
                    
                    // ✅ CORRECTION : Vérification budget
                    if (budget == null || budget! <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Veuillez saisir un budget valide'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    
                    if (selectedCategoryId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Veuillez sélectionner une catégorie'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    try {
                      Navigator.pop(context);
                      
                      if (isEditing) {
                        await _projectRepository.updateProject(
                          id: project.id,
                          name: name,
                          startDate: startDate,
                          endDate: endDate,
                          budget: budget,
                          categoryId: selectedCategoryId,
                          description: descriptionController.text.trim(),
                          progressStatus: selectedProgressStatus,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Projet modifié avec succès'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        await _projectRepository.createProject(
                          name: name,
                          startDate: startDate,
                          endDate: endDate,
                          budget: budget!,
                          categoryId: selectedCategoryId!,
                          startupId: _selectedStartupId!,
                          description: descriptionController.text.trim(),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Projet créé avec succès'),
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
                ),
              ],
            );
          },
        );
      },
    );
  }
  void _confirmDelete(ProjectModel project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer le projet'),
        content: Text(
          'Voulez-vous vraiment supprimer le projet "${project.name}" ?\n\n'
          '⚠️ Les transactions rattachées seront détachées.',
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
                await _projectRepository.deleteProject(project.id);
                await _refreshData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Projet supprimé avec succès'),
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

  Widget _buildStatusChip(String status) {
    final Map<String, Map<String, dynamic>> statusMap = {
      'ongoing': {'label': '🔄 En cours', 'color': Colors.orange, 'bg': Colors.orange.withOpacity(0.1)},
      'completed': {'label': '✅ Terminé', 'color': Colors.green, 'bg': Colors.green.withOpacity(0.1)},
      'delayed': {'label': '⚠️ En retard', 'color': Colors.red, 'bg': Colors.red.withOpacity(0.1)},
    };
    
    final data = statusMap[status] ?? statusMap['ongoing']!;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: data['bg'],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        data['label'],
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: data['color'],
        ),
      ),
    );
  }

  Widget _buildBudgetStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status == 'paid' 
            ? Colors.green.withOpacity(0.1) 
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status == 'paid' ? '💳 Payé' : '⏳ Non payé',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: status == 'paid' ? Colors.green : Colors.orange,
        ),
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
        title: const Text('Projets'),
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
      body: _projects.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.folder_open, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucun projet',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showProjectDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Créer un projet'),
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
                itemCount: _projects.length,
                itemBuilder: (context, index) {
                  final project = _projects[index];
                  final color = project.categoryColor != null
                      ? Color(int.parse(
                          project.categoryColor!.substring(1),
                          radix: 16,
                        ) + 0xFF000000)
                      : Colors.grey;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        // Voir les détails du projet
                        _showProjectDialog(project: project);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        project.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        project.categoryName ?? 'Sans catégorie',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _buildStatusChip(project.progressStatus),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Budget',
                                        style: TextStyle(fontSize: 10, color: Colors.grey),
                                      ),
                                      Text(
                                        '${project.budget.toStringAsFixed(0)} Ar',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Payé',
                                        style: TextStyle(fontSize: 10, color: Colors.grey),
                                      ),
                                      Text(
                                        '${project.amountPaid.toStringAsFixed(0)} Ar',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: project.isOverBudget ? Colors.red : Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      _buildBudgetStatusChip(project.budgetStatus),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${project.progressPercentage}%',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: project.progressPercentage / 100,
                              backgroundColor: Colors.grey.shade200,
                              color: project.isOverBudget ? Colors.red : AppTheme.primaryColor,
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${project.transactions?.length ?? 0} paiements',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                                      onPressed: () => _showProjectDialog(project: project),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                      onPressed: () => _confirmDelete(project),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProjectDialog(),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}