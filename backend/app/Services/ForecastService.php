<?php

namespace App\Services;

use App\Models\Transaction;
use Carbon\Carbon;

class ForecastService
{
    /**
     * Prévision simple par moyenne mobile
     */
    public function simpleMovingAverage($startupId, $days = 30)
    {
        $transactions = Transaction::forStartup($startupId)
                                   ->where('date', '>=', Carbon::now()->subDays($days))
                                   ->get();

        if ($transactions->isEmpty()) {
            return null;
        }

        $average = $transactions->avg('amount');
        $trend = $this->calculateTrend($transactions);

        return [
            'method' => 'Moving Average',
            'average_daily' => round($average, 2),
            'trend' => $trend,
            'confidence' => $transactions->count() >= 20 ? 'high' : 'medium',
            'sample_size' => $transactions->count(),
        ];
    }

    /**
     * Calculer la tendance
     */
    private function calculateTrend($transactions)
    {
        if ($transactions->count() < 2) {
            return 'stable';
        }

        $firstHalf = $transactions->take(ceil($transactions->count() / 2));
        $secondHalf = $transactions->slice(ceil($transactions->count() / 2));

        $firstAvg = $firstHalf->avg('amount');
        $secondAvg = $secondHalf->avg('amount');

        if ($secondAvg > $firstAvg * 1.1) {
            return 'up';
        } elseif ($secondAvg < $firstAvg * 0.9) {
            return 'down';
        } else {
            return 'stable';
        }
    }

    /**
     * Prévision exponentielle
     */
    public function exponentialSmoothing($startupId, $alpha = 0.3)
    {
        $transactions = Transaction::forStartup($startupId)
                                   ->where('date', '>=', Carbon::now()->subDays(30))
                                   ->orderBy('date')
                                   ->get();

        if ($transactions->isEmpty()) {
            return null;
        }

        $forecast = $transactions->first()->amount;
        
        foreach ($transactions as $transaction) {
            $forecast = $alpha * $transaction->amount + (1 - $alpha) * $forecast;
        }

        return [
            'method' => 'Exponential Smoothing',
            'forecast' => round($forecast, 2),
            'alpha' => $alpha,
            'sample_size' => $transactions->count(),
        ];
    }

    /**
     * Prévision avancée avec tendance et saisonnalité
     */
    public function advancedForecast($startupId)
    {
        $data = Transaction::forStartup($startupId)
                          ->where('date', '>=', Carbon::now()->subMonths(6))
                          ->get()
                          ->groupBy(function ($item) {
                              return $item->date->format('Y-m');
                          })
                          ->map(function ($items) {
                              return $items->sum('amount');
                          });

        if ($data->isEmpty()) {
            return null;
        }

        // Analyse de tendance
        $trend = $this->calculateTrendFromData($data);
        
        // Prévision pour le mois prochain
        $lastMonth = $data->last();
        $previousMonth = $data->slice(-2, 1)->first();
        $growthRate = $previousMonth > 0 
            ? (($lastMonth - $previousMonth) / $previousMonth) 
            : 0;

        $nextMonthForecast = $lastMonth * (1 + $growthRate);

        return [
            'method' => 'Advanced',
            'trend' => $trend,
            'growth_rate' => round($growthRate * 100, 2),
            'last_month_amount' => $lastMonth,
            'next_month_forecast' => round($nextMonthForecast, 2),
            'months_analyzed' => $data->count(),
            'confidence' => $data->count() >= 6 ? 'high' : 'medium',
        ];
    }

    /**
     * Calculer la tendance à partir des données
     */
    private function calculateTrendFromData($data)
    {
        $values = $data->values()->toArray();
        $count = count($values);
        
        if ($count < 2) {
            return 'stable';
        }

        $firstHalf = array_slice($values, 0, ceil($count / 2));
        $secondHalf = array_slice($values, ceil($count / 2));

        $firstAvg = array_sum($firstHalf) / count($firstHalf);
        $secondAvg = array_sum($secondHalf) / count($secondHalf);

        if ($secondAvg > $firstAvg * 1.15) {
            return '📈 En croissance';
        } elseif ($secondAvg < $firstAvg * 0.85) {
            return '📉 En baisse';
        } else {
            return '➡️ Stable';
        }
    }
}