<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Project;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;

class ProjectController extends Controller
{
    /**
     * Liste des projets
     */
    public function index(Request $request)
    {
        $startupId = $request->get('startup_id');
        
        $query = Project::forStartup($startupId)
                        ->with(['category', 'user', 'transactions']);

        // Filtres
        if ($request->has('progress_status')) {
            $query->withStatus($request->progress_status);
        }
        if ($request->has('budget_status')) {
            $query->budgetStatus($request->budget_status);
        }
        if ($request->has('category_id')) {
            $query->where('category_id', $request->category_id);
        }
        if ($request->has('search')) {
            $search = $request->search;
            $query->where('name', 'LIKE', "%{$search}%");
        }

        $projects = $query->orderBy('created_at', 'desc')
                          ->paginate($request->get('per_page', 15));

        return response()->json([
            'success' => true,
            'data' => $projects->map(function ($project) {
                return $this->formatProject($project);
            }),
            'pagination' => [
                'total' => $projects->total(),
                'per_page' => $projects->perPage(),
                'current_page' => $projects->currentPage(),
                'last_page' => $projects->lastPage(),
            ],
        ]);
    }

    /**
     * Créer un projet
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'start_date' => 'required|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
            'budget' => 'required|numeric|min:0',
            'category_id' => 'required|exists:categories,id',
            'description' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $project = Project::create([
            'name' => $request->name,
            'start_date' => $request->start_date,
            'end_date' => $request->end_date,
            'budget' => $request->budget,
            'amount_paid' => 0,
            'budget_status' => 'unpaid',
            'progress_status' => 'ongoing',
            'startup_id' => $request->get('startup_id'),
            'category_id' => $request->category_id,
            'user_id' => $request->user()->id,
            'description' => $request->description,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Projet créé avec succès',
            'data' => $this->formatProject($project->load(['category', 'user', 'transactions'])),
        ], 201);
    }

    /**
     * Voir un projet
     */
    public function show($id)
    {
        $project = Project::with(['category', 'user', 'transactions'])->findOrFail($id);
        return response()->json([
            'success' => true,
            'data' => $this->formatProject($project),
        ]);
    }

    /**
     * Mettre à jour un projet
     */
    public function update(Request $request, $id)
    {
        $project = Project::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|string|max:255',
            'start_date' => 'sometimes|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
            'budget' => 'sometimes|numeric|min:0',
            'category_id' => 'sometimes|exists:categories,id',
            'description' => 'nullable|string',
            'progress_status' => 'sometimes|in:ongoing,completed,delayed',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $project->update($request->all());
        
        // Mettre à jour les statuts
        $project->updateProgressStatus();
        $project->updateBudgetStatus();

        return response()->json([
            'success' => true,
            'message' => 'Projet mis à jour avec succès',
            'data' => $this->formatProject($project->fresh(['category', 'user', 'transactions'])),
        ]);
    }

    /**
     * Supprimer un projet
     */
    public function destroy($id)
    {
        $project = Project::findOrFail($id);
        
        // Détacher les transactions
        Transaction::where('project_id', $id)->update(['project_id' => null]);
        
        $project->delete();

        return response()->json([
            'success' => true,
            'message' => 'Projet supprimé avec succès',
        ]);
    }

    /**
     * Formater un projet pour la réponse
     */
    private function formatProject($project)
    {
        return [
            'id' => $project->id,
            'name' => $project->name,
            'start_date' => $project->start_date->format('Y-m-d'),
            'end_date' => $project->end_date?->format('Y-m-d'),
            'budget' => $project->budget,
            'amount_paid' => $project->amount_paid,
            'remaining_budget' => $project->remaining_budget,
            'budget_status' => $project->budget_status,
            'progress_status' => $project->progress_status,
            'progress_percentage' => $project->progress_percentage,
            'is_over_budget' => $project->is_over_budget,
            'category_id' => $project->category_id,
            'category_name' => $project->category?->name,
            'category_color' => $project->category?->color,
            'startup_id' => $project->startup_id,
            'user_id' => $project->user_id,
            'user_name' => $project->user?->name,
            'description' => $project->description,
            'transactions' => $project->transactions->map(function ($transaction) {
                return [
                    'id' => $transaction->id,
                    'amount' => $transaction->amount,
                    'date' => $transaction->date->format('Y-m-d'),
                    'source' => $transaction->source,
                ];
            }),
            'created_at' => $project->created_at,
            'updated_at' => $project->updated_at,
        ];
    }

    /**
     * Récupérer les statistiques des projets
     */
    public function stats(Request $request)
    {
        $startupId = $request->get('startup_id');
        
        $stats = [
            'total' => Project::forStartup($startupId)->count(),
            'ongoing' => Project::forStartup($startupId)->withStatus('ongoing')->count(),
            'completed' => Project::forStartup($startupId)->withStatus('completed')->count(),
            'delayed' => Project::forStartup($startupId)->withStatus('delayed')->count(),
            'paid' => Project::forStartup($startupId)->budgetStatus('paid')->count(),
            'unpaid' => Project::forStartup($startupId)->budgetStatus('unpaid')->count(),
            'total_budget' => Project::forStartup($startupId)->sum('budget'),
            'total_paid' => Project::forStartup($startupId)->sum('amount_paid'),
        ];

        return response()->json([
            'success' => true,
            'data' => $stats,
        ]);
    }
}