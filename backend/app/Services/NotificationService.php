<?php

namespace App\Services;

use App\Models\User;
use App\Models\Transaction;
use Carbon\Carbon;

class NotificationService
{
    public function checkAlerts($startupId, $userId)
    {
        $alerts = [];
        $config = User::find($userId)->notificationsConfig;

        // 1. Objectif mensuel
        if ($config?->goal_alert_enabled && $config->monthly_goal_amount > 0) {
            $currentRevenue = Transaction::forStartup($startupId)
                                        ->thisMonth()
                                        ->sum('amount');
            
            if ($currentRevenue >= $config->monthly_goal_amount) {
                $alerts[] = [
                    'type' => 'goal_reached',
                    'message' => '🎉 Objectif mensuel atteint !',
                    'progress' => round(($currentRevenue / $config->monthly_goal_amount) * 100, 2),
                    'goal' => $config->monthly_goal_amount,
                    'achieved' => $currentRevenue,
                ];
            }
        }

        // 2. CA du jour vs moyenne
        $today = Transaction::forStartup($startupId)->today()->sum('amount');
        $avg7Days = Transaction::forStartup($startupId)
                              ->where('date', '>=', Carbon::now()->subDays(7))
                              ->where('date', '<', Carbon::now()->startOfDay())
                              ->avg('amount');

        if ($avg7Days > 0 && $today < $avg7Days * 0.5) {
            $alerts[] = [
                'type' => 'low_revenue',
                'message' => '⚠️ CA du jour inférieur de 50% à la moyenne',
                'today' => $today,
                'average' => round($avg7Days, 2),
                'percentage' => round(($today / $avg7Days) * 100, 2),
            ];
        }

        // 3. Transactions anormales
        $lastTransaction = Transaction::forStartup($startupId)
                                      ->orderBy('created_at', 'desc')
                                      ->first();

        if ($lastTransaction) {
            $avg = Transaction::forStartup($startupId)->avg('amount');
            if ($lastTransaction->amount > $avg * 3) {
                $alerts[] = [
                    'type' => 'high_transaction',
                    'message' => '💸 Transaction anormalement élevée',
                    'amount' => $lastTransaction->amount,
                    'average' => round($avg, 2),
                    'transaction_id' => $lastTransaction->id,
                ];
            }
        }

        return $alerts;
    }

    public function sendDailyReminder($userId)
    {
        // Implémentation d'envoi de notification push
    }

    public function sendWeeklyReport($userId)
    {
        // Implémentation du rapport hebdomadaire
    }
}