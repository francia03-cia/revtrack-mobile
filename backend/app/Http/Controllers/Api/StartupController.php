<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\StartupResource;
use App\Models\AuditLog;
use App\Models\Startup;
use Illuminate\Http\Request;

class StartupController extends Controller
{
    /**
     * Lister les startups de l'utilisateur
     */
    public function index(Request $request)
    {
        $user = $request->user();
        $startups = $user->startups()->with(['owner', 'categories'])->get();
        
        return StartupResource::collection($startups);
    }

    /**
     * Créer une nouvelle startup
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'currency' => 'nullable|string|max:3',
            'email' => 'nullable|email',
            'phone' => 'nullable|string|max:20',
            'address' => 'nullable|string',
        ]);

        $startup = Startup::create([
            'name' => $validated['name'],
            'currency' => $validated['currency'] ?? 'Ar',
            'email' => $validated['email'] ?? null,
            'phone' => $validated['phone'] ?? null,
            'address' => $validated['address'] ?? null,
            'user_id' => $request->user()->id,
        ]);

        // Ajouter l'utilisateur comme owner
        $request->user()->startups()->attach($startup->id, ['role' => 'owner']);

        // Audit log
        AuditLog::log('create', 'startup', $startup->id);

        return response()->json([
            'success' => true,
            'message' => 'Startup créée avec succès',
            'startup' => new StartupResource($startup),
        ], 201);
    }

    /**
     * Afficher une startup
     */
    public function show($id)
    {
        $startup = Startup::with(['owner', 'users', 'categories'])->findOrFail($id);
        return new StartupResource($startup);
    }

    /**
     * Mettre à jour une startup
     */
    public function update(Request $request, $id)
    {
        $startup = Startup::findOrFail($id);
        
        // Vérifier que l'utilisateur est le owner
        if ($startup->user_id != $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Seul le propriétaire peut modifier la startup',
            ], 403);
        }

        $oldValues = $startup->toArray();
        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'logo' => 'nullable|image|max:2048',
            'currency' => 'nullable|string|max:3',
            'email' => 'nullable|email',
            'phone' => 'nullable|string|max:20',
            'address' => 'nullable|string',
        ]);

        if ($request->hasFile('logo')) {
            $path = $request->file('logo')->store('startups', 'public');
            $validated['logo'] = basename($path);
        }

        $startup->update($validated);

        // Audit log
        AuditLog::log('update', 'startup', $startup->id, $oldValues, $startup->toArray());

        return response()->json([
            'success' => true,
            'message' => 'Startup mise à jour avec succès',
            'startup' => new StartupResource($startup->fresh()),
        ]);
    }

    /**
     * Supprimer une startup
     */
    public function destroy(Request $request, $id)
    {
        $startup = Startup::findOrFail($id);
        
        // Vérifier que l'utilisateur est le owner
        if ($startup->user_id != $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Seul le propriétaire peut supprimer la startup',
            ], 403);
        }

        $startup->delete();

        // Audit log
        AuditLog::log('delete', 'startup', $id);

        return response()->json([
            'success' => true,
            'message' => 'Startup supprimée avec succès',
        ]);
    }

    /**
     * Changer la startup active
     */
    public function switch(Request $request)
    {
        $validated = $request->validate([
            'startup_id' => 'required|exists:startups,id',
        ]);

        $startupId = $validated['startup_id'];
        $user = $request->user();

        // Vérifier que l'utilisateur a accès à cette startup
        if (!$user->hasStartup($startupId)) {
            return response()->json([
                'success' => false,
                'message' => 'Vous n\'avez pas accès à cette startup',
            ], 403);
        }

        // Stocker la startup active dans une session ou token
        $user->update(['current_startup_id' => $startupId]);

        return response()->json([
            'success' => true,
            'message' => 'Startup active changée',
            'startup_id' => $startupId,
        ]);
    }
}