<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\NotificationsController;
use App\Http\Controllers\Api\StartupController;
use App\Http\Controllers\Api\TransactionController;
use App\Http\Controllers\Api\ProjectController;
use App\Http\Controllers\Api\ExportController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes - RevTrack Mobile
|--------------------------------------------------------------------------
*/

// Routes publiques
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::get('/test', function () {
    return ['status' => 'API fonctionne', 'time' => now()];
});

// Routes protégées
Route::middleware('auth:sanctum')->group(function () {
    
    // ============================================================
    // AUTHENTIFICATION
    // ============================================================
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);
    Route::put('/profile', [AuthController::class, 'updateProfile']);
    Route::put('/change-password', [AuthController::class, 'changePassword']);
    Route::post('/biometric-login', [AuthController::class, 'biometricLogin']);

    // ============================================================
    // STARTUPS
    // ============================================================
    Route::get('/startups', [StartupController::class, 'index']);
    Route::post('/startups', [StartupController::class, 'store']);
    Route::get('/startups/{id}', [StartupController::class, 'show']);
    Route::put('/startups/{id}', [StartupController::class, 'update']);
    Route::delete('/startups/{id}', [StartupController::class, 'destroy']);
    Route::post('/startups/switch', [StartupController::class, 'switch']);

    // ============================================================
    // TRANSACTIONS
    // ============================================================
    Route::get('/transactions', [TransactionController::class, 'index']);
    Route::post('/transactions', [TransactionController::class, 'store']);
    Route::get('/transactions/{id}', [TransactionController::class, 'show']);
    Route::put('/transactions/{id}', [TransactionController::class, 'update']);
    Route::delete('/transactions/{id}', [TransactionController::class, 'destroy']);
    
    // 🔥 Statistiques et regroupement
    Route::get('/transactions/stats', [TransactionController::class, 'stats']);
    Route::get('/transactions/grouped-by-category', [TransactionController::class, 'getGroupedByCategory']);
    Route::get('/transactions/export', [TransactionController::class, 'export']);
    
    // 🔥 Suppression groupée (Bulk Delete)
    Route::post('/transactions/bulk-delete', [TransactionController::class, 'bulkDelete']);

    // ============================================================
    // CATEGORIES
    // ============================================================
    Route::get('/categories', [CategoryController::class, 'index']);
    Route::post('/categories', [CategoryController::class, 'store']);
    Route::get('/categories/{id}', [CategoryController::class, 'show']);
    Route::put('/categories/{id}', [CategoryController::class, 'update']);
    Route::delete('/categories/{id}', [CategoryController::class, 'destroy']);
    Route::get('/categories/defaults', [CategoryController::class, 'defaults']);
    
    // 🔥 Sous-catégories
    Route::get('/categories/parent/{parentId}/children', [CategoryController::class, 'children']);

    // ============ PROJETS ============
    Route::get('/projects', [ProjectController::class, 'index']);
    Route::post('/projects', [ProjectController::class, 'store']);
    Route::get('/projects/{id}', [ProjectController::class, 'show']);
    Route::put('/projects/{id}', [ProjectController::class, 'update']);
    Route::delete('/projects/{id}', [ProjectController::class, 'destroy']);
    Route::get('/projects/stats', [ProjectController::class, 'stats']);

    // ============================================================
    // DASHBOARD
    // ============================================================
    Route::get('/dashboard/kpis', [DashboardController::class, 'getKPIs']);
    Route::get('/dashboard/charts', [DashboardController::class, 'getChartData']);
    Route::get('/dashboard/comparison', [DashboardController::class, 'getComparison']);
    Route::get('/dashboard/custom-chart', [DashboardController::class, 'getCustomChart']);
    Route::get('/dashboard/stats', [DashboardController::class, 'getStats']);
    Route::get('/dashboard/recent-transactions', [DashboardController::class, 'getRecentTransactions']);
    Route::get('/dashboard/forecast', [DashboardController::class, 'getForecast']);

    // ============================================================
    // EXPORTS
    // ============================================================
    Route::get('/export/pdf', [ExportController::class, 'exportPDF']);
    Route::get('/export/excel', [ExportController::class, 'exportExcel']);
    Route::get('/export/csv', [ExportController::class, 'exportCSV']);

    // ============================================================
    // NOTIFICATIONS
    // ============================================================
    Route::get('/notifications/config', [NotificationsController::class, 'getConfig']);
    Route::put('/notifications/config', [NotificationsController::class, 'updateConfig']);
    Route::get('/notifications/alerts', [NotificationsController::class, 'checkAlerts']);
    Route::post('/notifications/test', [NotificationsController::class, 'sendTestNotification']);
    Route::post('/notifications/fcm-token', [NotificationsController::class, 'updateFCMToken']);
});