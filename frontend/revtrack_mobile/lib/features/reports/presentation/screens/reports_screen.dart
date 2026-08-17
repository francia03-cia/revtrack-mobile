import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:revtrack_mobile/core/theme/app_theme.dart';
import 'package:revtrack_mobile/core/constants/app_strings.dart';
import 'package:revtrack_mobile/services/api_service.dart';
import 'package:revtrack_mobile/data/repositories/startup_repository.dart';
import '../../../../core/theme/colors.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ApiService _apiService = ApiService();
  final StartupRepository _startupRepository = StartupRepository();
  
  bool _autoGenerateInsights = true;
  bool _isLoading = false;
  int? _selectedStartupId;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadStartups();
  }

  Future<void> _loadStartups() async {
    try {
      final startups = await _startupRepository.getStartups();
      if (startups.isNotEmpty) {
        setState(() {
          _selectedStartupId = startups.first.id;
        });
      }
    } catch (e) {
      // Ignorer
    }
  }

  Future<void> _triggerExport(String type) async {
    if (_selectedStartupId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une startup'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('${AppStrings.exportingTo} $type'),
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text('${AppStrings.generatingFile} $type...'),
          ],
        ),
      ),
    );

    try {
      final startDateStr = _startDate.toIso8601String().split('T')[0];
      final endDateStr = _endDate.toIso8601String().split('T')[0];

      if (type == 'PDF') {
        final response = await _apiService.exportPdf(
          startupId: _selectedStartupId!,
          startDate: startDateStr,
          endDate: endDateStr,
        );
        
        // Sauvegarder le PDF
        final bytes = response.data as List<int>;
        await _saveFile(bytes, 'rapport_revtrack.pdf');
      } else {
        final response = await _apiService.exportExcel(
          startupId: _selectedStartupId!,
          startDate: startDateStr,
          endDate: endDateStr,
        );
        
        // Sauvegarder l'Excel
        final bytes = response.data as List<int>;
        await _saveFile(bytes, 'transactions_revtrack.xlsx');
      }

      Navigator.pop(context); // Close loader
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppStrings.reportDownloaded} $type ${AppStrings.readyToShare}'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: AppStrings.share,
            onPressed: () {},
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loader
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveFile(List<int> bytes, String fileName) async {
    // Sauvegarder le fichier (à implémenter selon la plateforme)
    // Pour web, utiliser download
    // Pour mobile, utiliser path_provider
    print('Fichier $fileName sauvegardé (${bytes.length} bytes)');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.reportsAndExports),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStartups,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sélecteur de période
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _startDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setState(() {
                                  _startDate = date;
                                });
                              }
                            },
                            child: Column(
                              children: [
                                const Text('Début', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                Text(
                                  '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward, color: Colors.grey),
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _endDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setState(() {
                                  _endDate = date;
                                });
                              }
                            },
                            child: Column(
                              children: [
                                const Text('Fin', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                Text(
                                  '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : () => _triggerExport('PDF'),
                            icon: Icon(Icons.picture_as_pdf, size: 18),
                            label: Text(AppStrings.exportPDF),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              minimumSize: const Size(0, 48),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isLoading ? null : () => _triggerExport('Excel'),
                            icon: Icon(Icons.table_view, size: 18),
                            label: Text(AppStrings.exportExcel),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black,
                              side: const BorderSide(color: Color(0xFFC7C4D8)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              minimumSize: const Size(0, 48),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Toggle Insights Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.autoGenerateInsights,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: _autoGenerateInsights,
                      onChanged: (val) => setState(() => _autoGenerateInsights = val),
                      activeColor: AppTheme.primaryColor,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}