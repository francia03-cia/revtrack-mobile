<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class CheckStartupAccess
{
    public function handle(Request $request, Closure $next)
    {
        $startupId = $request->header('X-Startup-ID') ?? $request->get('startup_id');
        
        if (!$startupId) {
            return response()->json([
                'success' => false,
                'message' => 'Startup ID requis',
            ], 400);
        }

        $user = $request->user();
        
        if (!$user->hasStartup($startupId)) {
            return response()->json([
                'success' => false,
                'message' => 'Vous n\'avez pas accès à cette startup',
            ], 403);
        }

        // Injecter startup_id dans la requête
        $request->merge(['startup_id' => $startupId]);

        return $next($request);
    }
}