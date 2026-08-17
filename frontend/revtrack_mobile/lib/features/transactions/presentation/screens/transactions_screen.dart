import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../data/repositories/transaction_repository.dart';
import '../../../../data/repositories/startup_repository.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/project_repository.dart';
import '../../../../data/models/transaction.dart';
import '../../../../data/models/startup.dart';
import '../../../../data/models/category.dart';
import '../../../../data/models/project.dart';
import '../../../../core/theme/colors.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TransactionRepository _transactionRepository = TransactionRepository();
  final StartupRepository _startupRepository = StartupRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();
  final ProjectRepository _projectRepository = ProjectRepository();
  
  List<TransactionModel> _transactions = [];
  List<CategoryModel> _categories = [];
  List<StartupModel> _startups = [];
  bool _isLoading = true;
  String _searchQuery = '';
  int? _selectedCategoryId;
  int? _selectedStartupId;
  String _errorMessage = '';

  // États pour le regroupement
  bool _showGroupedView = true;
  Map<String, CategoryGroup> _groupedTransactions = {};

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
      print('🏢 Startups: ${_startups.length}');
      
      if (_startups.isNotEmpty && _selectedStartupId == null) {
        _selectedStartupId = _startups.first.id;
      }

      if (_selectedStartupId != null) {
        _categories = await _categoryRepository.getCategories(
          startupId: _selectedStartupId,
        );
        print('📂 Categories: ${_categories.length}');
      }

      if (_selectedStartupId != null) {
        _transactions = await _transactionRepository.getTransactions(
          startupId: _selectedStartupId,
          search: _searchQuery.isNotEmpty ? _searchQuery : null,
          categoryId: _selectedCategoryId,
        );
        print('📋 Transactions: ${_transactions.length}');
      }

      _groupTransactions();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Transactions Error: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _groupTransactions() {
    _groupedTransactions = {};
    
    print('📊 Groupement des ${_transactions.length} transactions...');
    
    for (var transaction in _transactions) {
      String categoryName = transaction.categoryName ?? 'Sans catégorie';
      String categoryColor = transaction.categoryColor ?? '#6B7280';
      
      print('🔍 Transaction: id=${transaction.id}, source=${transaction.source}, category=$categoryName');
      
      if (!_groupedTransactions.containsKey(categoryName)) {
        _groupedTransactions[categoryName] = CategoryGroup(
          categoryName: categoryName,
          categoryColor: categoryColor,
          transactions: [],
          total: 0,
        );
      }
      
      _groupedTransactions[categoryName]!.transactions.add(transaction);
      _groupedTransactions[categoryName]!.total += transaction.amount;
    }
    
    print('📊 Groupes créés: ${_groupedTransactions.keys.join(', ')}');
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  void _openFilterDrawer() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.filterTransactions,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppStrings.category,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildFilterChip('Tous', null, setModalState),
                      ..._categories.map((cat) => 
                        _buildFilterChip(cat.name, cat.id, setModalState)
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Vue groupée par catégorie',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Switch(
                        value: _showGroupedView,
                        onChanged: (value) {
                          setModalState(() {
                            _showGroupedView = value;
                          });
                          setState(() {
                            _showGroupedView = value;
                          });
                        },
                        activeColor: AppTheme.primaryColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _loadData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(
                      AppStrings.applyFilters,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip(String label, int? categoryId, StateSetter setModalState) {
    final isSelected = _selectedCategoryId == categoryId;
    return GestureDetector(
      onTap: () {
        setModalState(() {
          _selectedCategoryId = isSelected ? null : categoryId;
        });
      },
      child: Chip(
        backgroundColor: isSelected ? AppTheme.primaryColor : const Color(0xFFF0F3FF),
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 12,
          ),
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  void _showCategoryDetails(CategoryGroup group) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Color(int.parse(
                            group.categoryColor.substring(1),
                            radix: 16,
                          ) + 0xFF000000),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        group.categoryName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Total: ${_formatAmount(group.total)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: group.total >= 0 
                              ? const Color(0xFF10B981) 
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Text(
                    '${group.transactions.length} transaction${group.transactions.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: group.transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = group.transactions[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: transaction.amount >= 0
                                  ? const Color(0xFF6CF8BB).withOpacity(0.2)
                                  : const Color(0xFFFFDAD6),
                              child: Icon(
                                transaction.amount >= 0 
                                    ? Icons.arrow_downward 
                                    : Icons.arrow_upward,
                                color: transaction.amount >= 0 
                                    ? const Color(0xFF006C49) 
                                    : const Color(0xFFBA1A1A),
                                size: 18,
                              ),
                            ),
                            title: Text(
                              transaction.source,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              transaction.note ?? 
                              _formatDate(transaction.date),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _formatAmount(transaction.amount),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: transaction.amount >= 0 
                                        ? const Color(0xFF10B981) 
                                        : Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  _formatDate(transaction.date),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<List<ProjectModel>> _loadProjects() async {
    try {
      final projects = await _projectRepository.getProjects(
        startupId: _selectedStartupId,
      );
      return projects;
    } catch (e) {
      print('❌ Load Projects Error: $e');
      return [];
    }
  }

  void _openQuickEntry() {
    if (_categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez charger les catégories avant d\'ajouter une transaction.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final sourceController = TextEditingController();
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    
    int? selectedCategoryId = _categories.first.id;
    int? selectedProjectId;
    List<ProjectModel> projects = [];
    bool loadingProjects = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            _loadProjects().then((value) {
              setDialogState(() {
                projects = value;
                loadingProjects = false;
              });
            });

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(
                AppStrings.newTransaction,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: sourceController,
                      decoration: InputDecoration(
                        labelText: AppStrings.source,
                        hintText: 'Ex: Client, Vente, etc.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.business_center),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: AppStrings.amountDollar,
                        hintText: '0.00 (négatif pour les dépenses)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.attach_money),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description (optionnel)',
                        hintText: 'Description de la transaction...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.description),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                    loadingProjects
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : DropdownButtonFormField<int?>(
                            decoration: InputDecoration(
                              labelText: 'Projet (optionnel)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.folder),
                            ),
                            value: selectedProjectId,
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('Aucun projet'),
                              ),
                              ...projects.map((project) {
                                return DropdownMenuItem(
                                  value: project.id,
                                  child: Text(project.name),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              setDialogState(() {
                                selectedProjectId = value;
                              });
                            },
                            isExpanded: true,
                          ),
                  ],
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
                    if (sourceController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Veuillez saisir une source'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    
                    if (amountController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Veuillez saisir un montant'),
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
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Enregistrement en cours...'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                      
                      await _transactionRepository.createTransaction(
                        amount: double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0,
                        date: DateTime.now(),
                        source: sourceController.text.trim(),
                        description: descriptionController.text.trim().isNotEmpty 
                            ? descriptionController.text.trim() 
                            : null,
                        categoryId: selectedCategoryId!,
                        startupId: _selectedStartupId ?? 1,
                        projectId: selectedProjectId,
                      );
                      
                      await _refreshData();
                      
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Transaction enregistrée avec succès !'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).clearSnackBars();
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
                  child: Text(AppStrings.save),
                )
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildGroupedView() {
    if (_groupedTransactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              AppStrings.noTransactionsFound,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _openQuickEntry,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter une transaction'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    final sortedEntries = _groupedTransactions.entries.toList()
      ..sort((a, b) => b.value.total.abs().compareTo(a.value.total.abs()));

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sortedEntries.length,
        itemBuilder: (context, index) {
          final entry = sortedEntries[index];
          final group = entry.value;
          final color = Color(int.parse(
            group.categoryColor.substring(1),
            radix: 16,
          ) + 0xFF000000);

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => _showCategoryDetails(group),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.category,
                        color: color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.categoryName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${group.transactions.length} transaction${group.transactions.length > 1 ? 's' : ''}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatAmount(group.total),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: group.total >= 0 
                                ? const Color(0xFF10B981) 
                                : Colors.red,
                          ),
                        ),
                        const Text(
                          'Cliquez pour voir les détails',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
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
    );
  }

  Widget _buildListView() {
    if (_transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              AppStrings.noTransactionsFound,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _openQuickEntry,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter une transaction'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final current = _transactions[index];
          
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: current.amount >= 0
                    ? const Color(0xFF6CF8BB).withOpacity(0.2)
                    : const Color(0xFFFFDAD6),
                child: Icon(
                  current.amount >= 0 ? Icons.arrow_downward : Icons.arrow_upward,
                  color: current.amount >= 0 ? const Color(0xFF006C49) : const Color(0xFFBA1A1A),
                  size: 18,
                ),
              ),
              title: Text(
                current.source,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Text(
                current.note ?? current.categoryName ?? '',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatAmount(current.amount),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: current.amount >= 0 ? const Color(0xFF10B981) : Colors.red,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    _formatDate(current.date),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
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
                child: Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                ),
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
        title: Text(AppStrings.transactions),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _refreshData,
          ),
          IconButton(
            icon: Icon(
              _showGroupedView ? Icons.list : Icons.grid_view,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                _showGroupedView = !_showGroupedView;
              });
            },
            tooltip: _showGroupedView ? 'Voir en liste' : 'Voir groupé par catégorie',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F3FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      onChanged: (val) {
                        _searchQuery = val;
                        _loadData();
                      },
                      decoration: InputDecoration(
                        hintText: AppStrings.searchTransactions,
                        prefixIcon: const Icon(Icons.search, size: 18, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _openFilterDrawer,
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.filter_list, color: Color(0xFF464555)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      body: _showGroupedView ? _buildGroupedView() : _buildListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: _openQuickEntry,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  String _formatAmount(double value) {
    if (value == 0) return '0 Ar';
    final sign = value < 0 ? '-' : '';
    final absValue = value.abs();
    
    if (absValue >= 1000000) {
      return '$sign${(absValue / 1000000).toStringAsFixed(1)}M Ar';
    } else if (absValue >= 1000) {
      return '$sign${(absValue / 1000).toStringAsFixed(1)}K Ar';
    }
    return '$sign${absValue.toStringAsFixed(0)} Ar';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return "Aujourd'hui ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } else if (date.day == now.day - 1 && date.month == now.month && date.year == now.year) {
      return 'Hier';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class CategoryGroup {
  final String categoryName;
  final String categoryColor;
  final List<TransactionModel> transactions;
  double total;

  CategoryGroup({
    required this.categoryName,
    required this.categoryColor,
    required this.transactions,
    this.total = 0,
  });
}