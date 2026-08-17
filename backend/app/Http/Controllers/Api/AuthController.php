<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
use App\Http\Resources\UserResource;
use App\Models\AuditLog;
use App\Models\Category;
use App\Models\Startup;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    /**
     * Inscription d'un nouvel utilisateur
     */
    public function register(RegisterRequest $request)
    {
        // Création de l'utilisateur
        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => 'admin',
        ]);

        // Création de la startup
        $startup = Startup::create([
            'name' => $request->startup_name,
            'user_id' => $user->id,
        ]);

        // Liaison user-startup
        $user->startups()->attach($startup->id, ['role' => 'owner']);

        // Création des catégories par défaut
        foreach (Category::getDefaultCategories() as $categoryData) {
            Category::create([
                'name' => $categoryData['name'],
                'color' => $categoryData['color'],
                'icon' => $categoryData['icon'],
                'startup_id' => $startup->id,
                'is_default' => true,
            ]);
        }

        // Création de la configuration de notifications
        $user->notificationsConfig()->create();

        // Audit log
        AuditLog::log('create', 'user', $user->id);

        // Génération du token
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Inscription réussie',
            'user' => new UserResource($user),
            'startup' => $startup,
            'token' => $token,
        ], 201);
    }

    /**
     * Connexion utilisateur
     */
    public function login(LoginRequest $request)
    {
        if (!Auth::attempt($request->only('email', 'password'))) {
            return response()->json([
                'success' => false,
                'message' => 'Email ou mot de passe incorrect',
            ], 401);
        }

        $user = User::where('email', $request->email)->firstOrFail();

        // Audit log
        AuditLog::log('login', 'user', $user->id);

        // Génération du token
        $token = $user->createToken($request->device_name ?? 'mobile_app')->plainTextToken;

        // Chargement des relations
        $user->load('startups', 'notificationsConfig');

        return response()->json([
            'success' => true,
            'message' => 'Connexion réussie',
            'user' => new UserResource($user),
            'token' => $token,
            'startups' => $user->startups,
        ]);
    }

    /**
     * Déconnexion
     */
    public function logout(Request $request)
    {
        $user = $request->user();
        
        // Audit log
        AuditLog::log('logout', 'user', $user->id);
        
        // Révocation du token
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Déconnexion réussie',
        ]);
    }

    /**
     * Obtenir l'utilisateur connecté
     */
    public function me(Request $request)
    {
        $user = $request->user()->load('startups', 'notificationsConfig');
        return new UserResource($user);
    }

    /**
     * Mettre à jour le profil
     */
    public function updateProfile(Request $request)
    {
        $user = $request->user();

        $request->validate([
            'name' => 'sometimes|string|max:255',
            'email' => 'sometimes|string|email|max:255|unique:users,email,' . $user->id,
            'avatar' => 'nullable|image|max:2048',
        ]);

        $data = $request->only(['name', 'email']);

        // Gestion de l'avatar
        if ($request->hasFile('avatar')) {
            $path = $request->file('avatar')->store('avatars', 'public');
            $data['avatar'] = basename($path);
        }

        $user->update($data);

        return response()->json([
            'success' => true,
            'message' => 'Profil mis à jour',
            'user' => new UserResource($user->fresh()),
        ]);
    }

    /**
     * Changer le mot de passe
     */
    public function changePassword(Request $request)
    {
        $request->validate([
            'current_password' => 'required|string',
            'new_password' => 'required|string|min:8|confirmed',
        ]);

        $user = $request->user();

        if (!Hash::check($request->current_password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Mot de passe actuel incorrect',
            ], 401);
        }

        $user->update([
            'password' => Hash::make($request->new_password),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Mot de passe changé avec succès',
        ]);
    }

    /**
     * Connexion biométrique (vérification du token)
     */
    public function biometricLogin(Request $request)
    {
        $request->validate([
            'device_token' => 'required|string',
        ]);

        // Vérifier si le token existe et est valide
        $token = $request->user()->tokens()->where('id', $request->device_token)->first();
        
        if (!$token) {
            return response()->json([
                'success' => false,
                'message' => 'Token invalide',
            ], 401);
        }

        return response()->json([
            'success' => true,
            'message' => 'Authentification biométrique réussie',
            'user' => new UserResource($request->user()),
        ]);
    }
}