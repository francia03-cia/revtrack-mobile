<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Transaction\StoreTransactionRequest;
use App\Http\Requests\Transaction\UpdateTransactionRequest;
use App\Http\Resources\TransactionResource;
use App\Models\AuditLog;
use App\Models\Project;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class TransactionController extends Controller
{
    /**
     * Lister toutes les transactions
     */
    public function index(Request $request)
    {
        $startupId = $request->get('startup_id');
        
        $query = Transaction::forStartup($startupId)
                            ->with(['category', 'user', 'startup']);

        // Filtres
        if ($request->has('date_from')) {
            $query->whereDate('date', '>=', $request->date_from);
        }
        if ($request->has('date_to')) {
            $query->whereDate('date', '<=', $request->date_to);
        }
        if ($request->has('category_id')) {
            $query->where('category_id', $request->category_id);
        }
        if ($request->has('min_amount')) {
            $query->where('amount', '>=', $request->min_amount);
        }
        if ($request->has('max_amount')) {
            $query->where('amount', '<=', $request->max_amount);
        }
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('note', 'LIKE', "%{$search}%")
                  ->orWhere('source', 'LIKE', "%{$search}%");
            });
        }

        // Tri
        $sortBy = $request->get('sort_by', 'date');
        $sortOrder = $request->get('sort_order', 'desc');
        $query->orderBy($sortBy, $sortOrder);

        $transactions = $query->paginate($request->get('per_page', 15));

        return TransactionResource::collection($transactions);
    }

    /**
     * Créer une transaction
     */
    public function store(StoreTransactionRequest $request)
    {
        $data = $request->validated();
        $data['startup_id'] = $request->get('startup_id');
        $data['user_id'] = $request->user()->id;

        // Si le FormRequest utilise 'description', le mapper vers 'note'
        if (isset($data['description'])) {
            $data['note'] = $data['description'];
            unset($data['description']);
        }

        // Gestion de la photo du reçu
        if ($request->hasFile('receipt')) {
            $path = $request->file('receipt')->store('receipts', 'public');
            $data['receipt'] = basename($path);
        }

        $transaction = Transaction::create($data);

        // ✅ METTRE À JOUR LE PROJET SI LIÉ
        if ($transaction->project_id) {
            $this->updateProjectAmountPaid($transaction->project_id);
        }

        // Audit log
        AuditLog::log('create', 'transaction', $transaction->id);

        return response()->json([
            'success' => true,
            'message' => 'Transaction créée avec succès',
            'transaction' => new TransactionResource($transaction->load(['category', 'user', 'startup'])),
        ], 201);
    }

    /**
     * Afficher une transaction
     */
    public function show($id)
    {
        $transaction = Transaction::with(['category', 'user', 'startup'])
                                  ->findOrFail($id);
        return new TransactionResource($transaction);
    }

    /**
     * Mettre à jour une transaction
     */
    public function update(UpdateTransactionRequest $request, $id)
    {
        $transaction = Transaction::findOrFail($id);
        
        // Vérification des droits
        if ($transaction->startup_id != $request->get('startup_id')) {
            return response()->json([
                'success' => false,
                'message' => 'Vous n\'avez pas les droits sur cette transaction',
            ], 403);
        }

        $oldValues = $transaction->toArray();
        $oldProjectId = $transaction->project_id; // ✅ Sauvegarder l'ancien projet
        $data = $request->validated();

        // Si le FormRequest utilise 'description', le mapper vers 'note'
        if (isset($data['description'])) {
            $data['note'] = $data['description'];
            unset($data['description']);
        }

        // Gestion de la photo du reçu
        if ($request->hasFile('receipt')) {
            // Suppression de l'ancienne photo
            if ($transaction->receipt) {
                \Storage::delete('public/receipts/' . $transaction->receipt);
            }
            $path = $request->file('receipt')->store('receipts', 'public');
            $data['receipt'] = basename($path);
        }

        $transaction->update($data);

        // ✅ METTRE À JOUR L'ANCIEN ET LE NOUVEAU PROJET
        $newProjectId = $transaction->project_id;
        
        if ($oldProjectId != $newProjectId) {
            if ($oldProjectId) {
                $this->updateProjectAmountPaid($oldProjectId);
            }
            if ($newProjectId) {
                $this->updateProjectAmountPaid($newProjectId);
            }
        } elseif ($newProjectId) {
            // Même projet, mais montant modifié
            $this->updateProjectAmountPaid($newProjectId);
        }

        // Audit log
        AuditLog::log('update', 'transaction', $transaction->id, $oldValues, $transaction->toArray());

        return response()->json([
            'success' => true,
            'message' => 'Transaction mise à jour avec succès',
            'transaction' => new TransactionResource($transaction->fresh(['category', 'user', 'startup'])),
        ]);
    }

    /**
     * Supprimer une transaction
     */
    public function destroy(Request $request, $id)
    {
        $transaction = Transaction::findOrFail($id);
        
        // Vérification des droits
        if ($transaction->startup_id != $request->get('startup_id')) {
            return response()->json([
                'success' => false,
                'message' => 'Vous n\'avez pas les droits sur cette transaction',
            ], 403);
        }

        $projectId = $transaction->project_id; // ✅ Sauvegarder avant suppression

        // Suppression de la photo
        if ($transaction->receipt) {
            \Storage::delete('public/receipts/' . $transaction->receipt);
        }

        $transaction->delete();

        // ✅ METTRE À JOUR LE PROJET APRÈS SUPPRESSION
        if ($projectId) {
            $this->updateProjectAmountPaid($projectId);
        }

        // Audit log
        AuditLog::log('delete', 'transaction', $id);

        return response()->json([
            'success' => true,
            'message' => 'Transaction supprimée avec succès',
        ]);
    }

    /**
     * Obtenir les statistiques des transactions
     */
    public function stats(Request $request)
    {
        $startupId = $request->get('startup_id');
        
        $today = Transaction::forStartup($startupId)->today()->sum('amount');
        $thisWeek = Transaction::forStartup($startupId)->thisWeek()->sum('amount');
        $thisMonth = Transaction::forStartup($startupId)->thisMonth()->sum('amount');
        $thisYear = Transaction::forStartup($startupId)->thisYear()->sum('amount');
        
        // Croissance
        $currentMonth = Transaction::forStartup($startupId)->thisMonth()->sum('amount');
        $lastMonth = Transaction::forStartup($startupId)->lastMonth()->sum('amount');
        $growth = $lastMonth > 0 ? round((($currentMonth - $lastMonth) / $lastMonth) * 100, 2) : 0;

        // Transactions par catégorie
        $categories = Transaction::forStartup($startupId)
                                 ->thisMonth()
                                 ->with('category')
                                 ->get()
                                 ->groupBy('category_id')
                                 ->map(function ($items) {
                                     return [
                                         'category' => $items->first()->category?->name ?? 'Sans catégorie',
                                         'total' => $items->sum('amount'),
                                         'count' => $items->count(),
                                     ];
                                 });

        return response()->json([
            'success' => true,
            'data' => [
                'today' => $today,
                'this_week' => $thisWeek,
                'this_month' => $thisMonth,
                'this_year' => $thisYear,
                'growth' => $growth,
                'by_category' => $categories,
                'total_transactions' => Transaction::forStartup($startupId)->count(),
            ],
        ]);
    }

    /**
     * Exporter les transactions
     */
    public function export(Request $request)
    {
        $startupId = $request->get('startup_id');
        $format = $request->get('format', 'csv');

        $transactions = Transaction::forStartup($startupId)
                                   ->with(['category'])
                                   ->get();

        // Audit log
        AuditLog::log('export', 'transaction');

        // Export CSV
        if ($format === 'csv') {
            $filename = "transactions_" . now()->format('Y-m-d') . ".csv";
            $headers = [
                'Content-Type' => 'text/csv',
                'Content-Disposition' => "attachment; filename=\"$filename\"",
            ];

            $callback = function () use ($transactions) {
                $file = fopen('php://output', 'w');
                fputcsv($file, ['Date', 'Montant', 'Catégorie', 'Source', 'Note']);

                foreach ($transactions as $transaction) {
                    fputcsv($file, [
                        $transaction->date->format('Y-m-d'),
                        $transaction->amount,
                        $transaction->category?->name,
                        $transaction->source,
                        $transaction->note,
                    ]);
                }

                fclose($file);
            };

            return response()->stream($callback, 200, $headers);
        }

        return response()->json([
            'success' => false,
            'message' => 'Format non supporté',
        ], 400);
    }

    /**
     * Récupérer les transactions groupées par catégorie
     */
    public function getGroupedByCategory(Request $request)
    {
        $startupId = $request->get('startup_id');
        
        if (!$startupId) {
            return response()->json([
                'success' => false,
                'message' => 'startup_id est requis',
            ], 422);
        }

        Log::info('🔍 getGroupedByCategory - startup_id: ' . $startupId);
        
        $transactions = Transaction::with('category')
            ->where('startup_id', $startupId)
            ->when($request->has('start_date'), function ($query) use ($request) {
                return $query->whereDate('date', '>=', $request->start_date);
            })
            ->when($request->has('end_date'), function ($query) use ($request) {
                return $query->whereDate('date', '<=', $request->end_date);
            })
            ->get();

        Log::info('📊 Transactions trouvées: ' . $transactions->count());

        if ($transactions->isEmpty()) {
            return response()->json([
                'success' => true,
                'data' => [],
            ]);
        }

        $grouped = $transactions->groupBy(function ($transaction) {
            return $transaction->category?->name ?? 'Sans catégorie';
        });
        
        $result = [];
        foreach ($grouped as $categoryName => $items) {
            $category = $items->first()->category;
            
            $transactionsList = $items->map(function ($item) {
                return [
                    'id' => $item->id,
                    'amount' => round($item->amount, 2),
                    'date' => $item->date->format('Y-m-d'),
                    'source' => $item->source,
                    'description' => $item->note,
                ];
            })->values()->toArray();

            $result[] = [
                'category_name' => $categoryName,
                'category_id' => $category?->id,
                'category_color' => $category?->color ?? '#6B7280',
                'category_icon' => $category?->icon ?? 'more-horizontal',
                'total' => $items->sum('amount'),
                'count' => $items->count(),
                'transactions' => $transactionsList,
            ];
        }
        
        usort($result, function ($a, $b) {
            return abs($b['total']) <=> abs($a['total']);
        });
        
        return response()->json([
            'success' => true,
            'data' => $result,
        ]);
    }

    // ============================================
    // ✅ MÉTHODE PRIVÉE POUR METTRE À JOUR LE PROJET
    // ============================================

    /**
     * Mettre à jour le montant payé d'un projet
     * 
     * @param int $projectId
     * @return void
     */
    private function updateProjectAmountPaid($projectId)
    {
        $project = Project::find($projectId);
        if (!$project) {
            Log::warning('⚠️ Projet non trouvé pour la mise à jour: ' . $projectId);
            return;
        }

        // Calculer le total des transactions liées au projet
        $totalPaid = Transaction::where('project_id', $projectId)->sum('amount');
        
        // Mettre à jour le projet
        $project->amount_paid = $totalPaid;
        
        // Mettre à jour le statut du budget
        $project->updateBudgetStatus();
        
        $project->save();

        Log::info('✅ Projet mis à jour: ID=' . $projectId . ', amount_paid=' . $totalPaid);
    }
}