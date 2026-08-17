<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\NotificationsConfig;
use App\Models\Transaction;
use Illuminate\Http\Request;

class NotificationsController extends Controller
{
    /**
     * Obtenir la configuration des notifications
     */
    public function getConfig(Request $request)
    {
        $config = $request->user()->notificationsConfig;
        
        if (!$config) {
            $config = NotificationsConfig::create([
                'user_id' => $request->user()->id,
            ]);
        }

        return response()->json([
            'success' => true,
            'config' => $config,
        ]);
    }

    /**
     * Mettre à jour la configuration
     */
    public function updateConfig(Request $request)
    {
        $config = $request->user()->notificationsConfig;
        
        if (!$config) {
            $config = NotificationsConfig::create([
                'user_id' => $request->user()->id,
            ]);
        }

        $validated = $request->validate([
            'daily_reminder_enabled' => 'boolean',
            'daily_reminder_time' => 'nullable|date_format:H:i',
            'goal_alert_enabled' => 'boolean',
            'monthly_goal_amount' => 'nullable|numeric|min:0',
            'weekly_report_enabled' => 'boolean',
            'weekly_report_day' => 'nullable|in:monday,tuesday,wednesday,thursday,friday,saturday,sunday',
            'anomaly_alert_enabled' => 'boolean',
            'anomaly_threshold_percentage' => 'nullable|numeric|min:0|max:100',
            'push_notifications_enabled' => 'boolean',
        ]);

        $config->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Configuration mise à jour',
            'config' => $config->fresh(),
        ]);
    }

    /**
     * Vérifier les alertes (pour le cron)
     */
    public function checkAlerts(Request $request)
    {
        $startupId = $request->get('startup_id');
        $user = $request->user();
        $config = $user->notificationsConfig;
        $alerts = [];

        // Alerte 1: Objectif mensuel atteint
        if ($config && $config->isGoalAlertEnabled()) {
            $progress = $config->getMonthlyGoalProgress($startupId);
            if ($progress >= 100) {
                $alerts[] = [
                    'type' => 'goal_reached',
                    'message' => '🎉 Objectif mensuel atteint !',
                    'progress' => $progress,
                ];
            }
        }

        // Alerte 2: CA du jour inférieur à la moyenne
        $today = Transaction::forStartup($startupId)->today()->sum('amount');
        $average7Days = Transaction::forStartup($startupId)
                                   ->where('date', '>=', Carbon::now()->subDays(7))
                                   ->where('date', '<', Carbon::now()->startOfDay())
                                   ->avg('amount') ?? 0;
        
        if ($average7Days > 0 && $today < ($average7Days * 0.5)) {
            $alerts[] = [
                'type' => 'low_revenue',
                'message' => '⚠️ CA du jour inférieur de 50% à la moyenne',
                'today' => $today,
                'average' => $average7Days,
            ];
        }

        // Alerte 3: Transaction anormalement élevée
        $lastTransaction = Transaction::forStartup($startupId)
                                      ->orderBy('created_at', 'desc')
                                      ->first();
        
        if ($lastTransaction && $lastTransaction->isHighValue()) {
            $alerts[] = [
                'type' => 'high_transaction',
                'message' => '💸 Transaction anormalement élevée',
                'amount' => $lastTransaction->amount,
                'transaction_id' => $lastTransaction->id,
            ];
        }

        return response()->json([
            'success' => true,
            'alerts' => $alerts,
            'has_alerts' => count($alerts) > 0,
        ]);
    }
}