import 'package:revtrack_mobile/data/models/transaction.dart';
import 'package:revtrack_mobile/services/api_service.dart';

class TransactionRepository {
  final ApiService _apiService = ApiService();

  Future<List<TransactionModel>> getTransactions({
    int? startupId,
    String? startDate,
    String? endDate,
    int? categoryId,
    String? search,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      print('📋 Repository: Récupération des transactions...');
      final result = await _apiService.getTransactions(
        startupId: startupId,
        startDate: startDate,
        endDate: endDate,
        categoryId: categoryId,
        search: search,
        page: page,
        perPage: perPage,
      );
      print('📋 Repository: ${result.length} transactions trouvées');
      return result;
    } catch (e) {
      print('❌ Repository Transactions Error: $e');
      rethrow;
    }
  }

  Future<TransactionModel> createTransaction({
    required double amount,
    required DateTime date,
    required String source,
    String? description,
    required int categoryId,
    required int startupId,
    List<String>? tags,
    String? receipt,
    int? projectId,
  }) async {
    try {
      return await _apiService.createTransaction(
        amount: amount,
        date: date,
        source: source,
        description: description,
        categoryId: categoryId,
        startupId: startupId,
        tags: tags,
        receipt: receipt,
        projectId: projectId,
      );
    } catch (e) {
      print('❌ Create Transaction Error: $e');
      rethrow;
    }
  }

  Future<TransactionModel> updateTransaction({
    required int id,
    double? amount,
    DateTime? date,
    String? source,
    String? description,
    int? categoryId,
    List<String>? tags,
  }) async {
    try {
      return await _apiService.updateTransaction(
        id: id,
        amount: amount,
        date: date,
        source: source,
        description: description,
        categoryId: categoryId,
        tags: tags,
      );
    } catch (e) {
      print('❌ Update Transaction Error: $e');
      rethrow;
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await _apiService.deleteTransaction(id);
    } catch (e) {
      print('❌ Delete Transaction Error: $e');
      rethrow;
    }
  }

  Future<void> bulkDeleteTransactions(List<int> ids) async {
    try {
      await _apiService.bulkDeleteTransactions(ids);
    } catch (e) {
      print('❌ Bulk Delete Error: $e');
      rethrow;
    }
  }
}