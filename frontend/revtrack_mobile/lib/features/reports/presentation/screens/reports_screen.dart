import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:revtrack_mobile/core/theme/app_theme.dart';
import 'package:revtrack_mobile/core/constants/app_strings.dart';
import 'package:revtrack_mobile/services/api_service.dart';
import 'package:revtrack_mobile/data/repositories/startup_repository.dart';
import 'package:revtrack_mobile/data/models/startup.dart';
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
  List<StartupModel> _startups = [];

  @override
  void initState() {
    super.initState();
    _loadStartups();
  }

  Future<void> _loadStartups() async {
    try {
      final startups = await _startupRepository.getStartups();
      setState(() {
        _startups = startups;
        if (startups.isNotEmpty && _selectedStartupId == null) {
          _selectedStartupId = startups.first.id;
        }
      });
    } catch (e) {
      print('❌ Load Startups Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de chargement des startups: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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

    // Afficher le dialogue de chargement
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
        // Récupérer le PDF
        final response = await _apiService.exportPdf(
          startupId: _selectedStartupId!,
          startDate: startDateStr,
          endDate: endDateStr,
        );
        
        // Récupérer les bytes
        final bytes = response.data as Uint8List;
        final filename = 'rapport_revtrack_${DateTime.now().toIso8601String().split('T')[0]}.pdf';
        
        // Sauvegarder le fichier
        await _saveFile(bytes, filename);
        
      } else {
        // Récupérer l'Excel
        final response = await _apiService.exportExcel(
          startupId: _selectedStartupId!,
          startDate: startDateStr,
          endDate: endDateStr,
        );
        
        // Récupérer les bytes
        final bytes = response.data as Uint8List;
        final filename = 'transactions_revtrack_${DateTime.now().toIso8601String().split('T')[0]}.xlsx';
        
        // Sauvegarder le fichier
        await _saveFile(bytes, filename);
      }

      // Fermer le dialogue de chargement
      if (mounted) {
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.reportDownloaded} $type ${AppStrings.readyToShare}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }

    } catch (e) {
      // Fermer le dialogue de chargement
      if (mounted) {
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveFile(Uint8List bytes, String fileName) async {
    try {
      // Pour le Web (Chrome, Edge, etc.)
      if (html.window != null) {
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
        
        print('✅ Fichier sauvegardé: $fileName');
      } else {
        // Pour Mobile/Desktop - Utiliser path_provider
        // À implémenter pour mobile
        print('📱 Sauvegarde mobile: $fileName (${bytes.length} bytes)');
        // Vous pouvez ajouter une logique pour mobile ici
      }
    } catch (e) {
      print('❌ Erreur de sauvegarde: $e');
      rethrow;
    }
  }

  String _getStartupName() {
    if (_startups.isEmpty) return 'Aucune startup';
    final startup = _startups.firstWhere(
      (s) => s.id == _selectedStartupId,
      orElse: () => _startups.first,
    );
    return startup.name;
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
          // Sélecteur de startup
          if (_startups.isNotEmpty)
            PopupMenuButton<int>(
              icon: const Icon(Icons.business_center, color: Colors.black87),
              onSelected: (value) {
                setState(() {
                  _selectedStartupId = value;
                });
              },
              itemBuilder: (context) => _startups.map((startup) {
                return PopupMenuItem(
                  value: startup.id,
                  child: Row(
                    children: [
                      Text(startup.name),
                      if (_selectedStartupId == startup.id) ...[
                        const Spacer(),
                        const Icon(Icons.check, color: Colors.green, size: 18),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _loadStartups,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.business_center, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getStartupName(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sélecteur de période
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Titre
                    const Text(
                      '📅 Sélectionner la période',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Sélecteurs de dates
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateButton(
                            label: 'Début',
                            date: _startDate,
                            onTap: () async {
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
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.arrow_forward, color: Colors.grey),
                        ),
                        Expanded(
                          child: _buildDateButton(
                            label: 'Fin',
                            date: _endDate,
                            onTap: () async {
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
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Boutons rapides
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildQuickDateButton('Ce mois', () {
                          setState(() {
                            _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
                            _endDate = DateTime.now();
                          });
                        }),
                        _buildQuickDateButton('Ce trimestre', () {
                          final month = DateTime.now().month;
                          final startMonth = ((month - 1) ~/ 3) * 3 + 1;
                          setState(() {
                            _startDate = DateTime(DateTime.now().year, startMonth, 1);
                            _endDate = DateTime.now();
                          });
                        }),
                        _buildQuickDateButton('Cette année', () {
                          setState(() {
                            _startDate = DateTime(DateTime.now().year, 1, 1);
                            _endDate = DateTime.now();
                          });
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Boutons d'export
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : () => _triggerExport('PDF'),
                            icon: const Icon(Icons.picture_as_pdf, size: 18),
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
                            icon: const Icon(Icons.table_view, size: 18),
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
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
            
            // Information sur le nombre de jours
            const SizedBox(height: 16),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Période sélectionnée: ${_startDate.difference(_endDate).inDays.abs() + 1} jours',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDateButton(String label, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 28),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(fontSize: 11),
      ),
      child: Text(label),
    );
  }
}