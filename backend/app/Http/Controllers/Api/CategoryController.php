<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Category\StoreCategoryRequest;
use App\Http\Resources\CategoryResource;
use App\Models\AuditLog;
use App\Models\Category;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    /**
     * Lister les catégories
     */
    public function index(Request $request)
    {
        $startupId = $request->get('startup_id');
        
        $categories = Category::forStartup($startupId)
                              ->with(['children'])
                              ->when($request->has('parent_id'), function ($query) use ($request) {
                                  return $query->where('parent_id', $request->parent_id);
                              })
                              ->when($request->has('root_only'), function ($query) {
                                  return $query->root();
                              })
                              ->orderBy('name')
                              ->get();

        return CategoryResource::collection($categories);
    }

    /**
     * Créer une catégorie
     */
    public function store(StoreCategoryRequest $request)
    {
        $data = $request->validated();
        $data['startup_id'] = $request->get('startup_id');
        $data['is_default'] = false;

        $category = Category::create($data);

        // Audit log
        AuditLog::log('create', 'category', $category->id);

        return response()->json([
            'success' => true,
            'message' => 'Catégorie créée avec succès',
            'category' => new CategoryResource($category),
        ], 201);
    }

    /**
     * Afficher une catégorie
     */
    public function show($id)
    {
        $category = Category::with(['children', 'parent', 'transactions'])
                            ->findOrFail($id);
        return new CategoryResource($category);
    }

    /**
     * Mettre à jour une catégorie
     */
    public function update(StoreCategoryRequest $request, $id)
    {
        $category = Category::findOrFail($id);
        
        // Vérification des droits
        if ($category->startup_id != $request->get('startup_id')) {
            return response()->json([
                'success' => false,
                'message' => 'Vous n\'avez pas les droits sur cette catégorie',
            ], 403);
        }

        $oldValues = $category->toArray();
        $category->update($request->validated());

        // Audit log
        AuditLog::log('update', 'category', $category->id, $oldValues, $category->toArray());

        return response()->json([
            'success' => true,
            'message' => 'Catégorie mise à jour avec succès',
            'category' => new CategoryResource($category->fresh()),
        ]);
    }

    /**
     * Supprimer une catégorie
     */
    public function destroy(Request $request, $id)
    {
        $category = Category::findOrFail($id);
        
        // Vérification des droits
        if ($category->startup_id != $request->get('startup_id')) {
            return response()->json([
                'success' => false,
                'message' => 'Vous n\'avez pas les droits sur cette catégorie',
            ], 403);
        }

        // Vérifier si la catégorie a des transactions
        if ($category->transactions()->exists()) {
            return response()->json([
                'success' => false,
                'message' => 'Impossible de supprimer une catégorie qui contient des transactions',
            ], 400);
        }

        $category->delete();

        // Audit log
        AuditLog::log('delete', 'category', $id);

        return response()->json([
            'success' => true,
            'message' => 'Catégorie supprimée avec succès',
        ]);
    }

    /**
     * Obtenir les catégories par défaut
     */
    public function defaults()
    {
        return response()->json([
            'success' => true,
            'categories' => Category::getDefaultCategories(),
        ]);
    }
}