<?php

namespace App\Services;

use App\Models\Transaction;
use App\Models\Startup;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class RevenueService
{
    /**
     * Récupérer les KPIs du tableau de bord
     */
    public function getKPIs($startupId)
    {
        $startup = Startup::findOrFail($startupId);
        
        // CA du jour
        $today = Transaction::where('transactions.startup_id', $startupId)
            ->whereDate('transactions.date', Carbon::today())
            ->sum('transactions.amount');
        
        // CA de la semaine
        $thisWeek = Transaction::where('transactions.startup_id', $startupId)
            ->whereBetween('transactions.date', [Carbon::now()->startOfWeek(), Carbon::now()->endOfWeek()])
            ->sum('transactions.amount');
        
        // CA du mois
        $thisMonth = Transaction::where('transactions.startup_id', $startupId)
            ->whereBetween('transactions.date', [Carbon::now()->startOfMonth(), Carbon::now()->endOfMonth()])
            ->sum('transactions.amount');
        
        // CA de l'année
        $thisYear = Transaction::where('transactions.startup_id', $startupId)
            ->whereYear('transactions.date', Carbon::now()->year)
            ->sum('transactions.amount');
        
        // CA du mois précédent (pour calcul de croissance)
        $lastMonth = Transaction::where('transactions.startup_id', $startupId)
            ->whereBetween('transactions.date', [Carbon::now()->subMonth()->startOfMonth(), Carbon::now()->subMonth()->endOfMonth()])
            ->sum('transactions.amount');
        
        // Calcul de la croissance
        $growth = $lastMonth > 0 ? (($thisMonth - $lastMonth) / $lastMonth) * 100 : 0;
        
        // Objectif mensuel (depuis la configuration de l'utilisateur)
        $user = auth()->user();
        $monthlyGoal = $user->notificationConfig?->monthly_goal ?? 0;
        
        // Progression de l'objectif
        $goalProgress = $monthlyGoal > 0 ? ($thisMonth / $monthlyGoal) * 100 : 0;
        
        return [
            'today' => round($today, 2),
            'this_week' => round($thisWeek, 2),
            'this_month' => round($thisMonth, 2),
            'this_year' => round($thisYear, 2),
            'growth' => round($growth, 2),
            'monthly_goal' => round($monthlyGoal, 2),
            'goal_progress' => round($goalProgress, 2),
        ];
    }

    /**
     * Récupérer les données pour les graphiques
     */
    public function getChartData($startupId, $period = 'month')
    {
        switch ($period) {
            case 'day':
                return $this->getDailyChartData($startupId);
            case 'week':
                return $this->getWeeklyChartData($startupId);
            case 'month':
                return $this->getMonthlyChartData($startupId);
            case 'year':
                return $this->getYearlyChartData($startupId);
            default:
                return $this->getMonthlyChartData($startupId);
        }
    }

    /**
     * Récupérer les données de graphique quotidien
     * (dernières 24 heures)
     */
    public function getDailyChartData($startupId)
    {
        // Données horaires pour les dernières 24 heures
        $revenueByPeriod = Transaction::where('transactions.startup_id', $startupId)
            ->whereDate('transactions.date', Carbon::today())
            ->select(
                DB::raw("DATE_FORMAT(transactions.date, '%H:00') as period"),
                DB::raw('SUM(transactions.amount) as total')
            )
            ->groupBy('period')
            ->orderBy('period')
            ->get()
            ->map(function ($item) {
                return [
                    'period' => $item->period,
                    'total' => round($item->total, 2),
                ];
            });

        // Répartition par catégorie (jour)
        $revenueByCategory = Transaction::where('transactions.startup_id', $startupId)
            ->whereDate('transactions.date', Carbon::today())
            ->join('categories', 'transactions.category_id', '=', 'categories.id')
            ->select(
                'categories.name as category_name',
                'categories.color as category_color',
                DB::raw('SUM(transactions.amount) as total')
            )
            ->groupBy('categories.id', 'categories.name', 'categories.color')
            ->get()
            ->map(function ($item) {
                return [
                    'category_name' => $item->category_name,
                    'category_color' => $item->category_color ?? '#4F46E5',
                    'total' => round($item->total, 2),
                ];
            });

        // Top 5 sources de revenus (jour)
        $topSources = Transaction::where('transactions.startup_id', $startupId)
            ->whereDate('transactions.date', Carbon::today())
            ->select('transactions.source', DB::raw('SUM(transactions.amount) as total'))
            ->groupBy('transactions.source')
            ->orderBy('total', 'desc')
            ->limit(5)
            ->get()
            ->map(function ($item) {
                return [
                    'source' => $item->source,
                    'total' => round($item->total, 2),
                ];
            });

        // Prévisions (basées sur la moyenne des 7 derniers jours)
        $forecast = $this->getForecast($startupId, 7);

        return [
            'revenue_by_period' => $revenueByPeriod,
            'revenue_by_category' => $revenueByCategory,
            'top_sources' => $topSources,
            'forecast' => round($forecast, 2),
        ];
    }

    /**
     * Récupérer les données de graphique hebdomadaire
     * (7 derniers jours)
     */
    public function getWeeklyChartData($startupId)
    {
        // Données journalières pour les 7 derniers jours
        $revenueByPeriod = Transaction::where('transactions.startup_id', $startupId)
            ->whereBetween('transactions.date', [Carbon::now()->subDays(6), Carbon::today()])
            ->select(
                DB::raw("DATE_FORMAT(transactions.date, '%Y-%m-%d') as period"),
                DB::raw('SUM(transactions.amount) as total')
            )
            ->groupBy('period')
            ->orderBy('period')
            ->get()
            ->map(function ($item) {
                return [
                    'period' => Carbon::parse($item->period)->format('D d'),
                    'total' => round($item->total, 2),
                ];
            });

        // Répartition par catégorie (semaine)
        $revenueByCategory = Transaction::where('transactions.startup_id', $startupId)
            ->whereBetween('transactions.date', [Carbon::now()->subDays(6), Carbon::today()])
            ->join('categories', 'transactions.category_id', '=', 'categories.id')
            ->select(
                'categories.name as category_name',
                'categories.color as category_color',
                DB::raw('SUM(transactions.amount) as total')
            )
            ->groupBy('categories.id', 'categories.name', 'categories.color')
            ->get()
            ->map(function ($item) {
                return [
                    'category_name' => $item->category_name,
                    'category_color' => $item->category_color ?? '#4F46E5',
                    'total' => round($item->total, 2),
                ];
            });

        // Top 5 sources de revenus (semaine)
        $topSources = Transaction::where('transactions.startup_id', $startupId)
            ->whereBetween('transactions.date', [Carbon::now()->subDays(6), Carbon::today()])
            ->select('transactions.source', DB::raw('SUM(transactions.amount) as total'))
            ->groupBy('transactions.source')
            ->orderBy('total', 'desc')
            ->limit(5)
            ->get()
            ->map(function ($item) {
                return [
                    'source' => $item->source,
                    'total' => round($item->total, 2),
                ];
            });

        // Prévisions (basées sur la moyenne des 30 derniers jours)
        $forecast = $this->getForecast($startupId, 30);

        return [
            'revenue_by_period' => $revenueByPeriod,
            'revenue_by_category' => $revenueByCategory,
            'top_sources' => $topSources,
            'forecast' => round($forecast, 2),
        ];
    }

    /**
     * Récupérer les données de graphique mensuel
     * (30 derniers jours)
     */
    public function getMonthlyChartData($startupId)
    {
        // Données journalières pour les 30 derniers jours
        $revenueByPeriod = Transaction::where('transactions.startup_id', $startupId)
            ->whereBetween('transactions.date', [Carbon::now()->subDays(29), Carbon::today()])
            ->select(
                DB::raw("DATE_FORMAT(transactions.date, '%Y-%m-%d') as period"),
                DB::raw('SUM(transactions.amount) as total')
            )
            ->groupBy('period')
            ->orderBy('period')
            ->get()
            ->map(function ($item) {
                return [
                    'period' => Carbon::parse($item->period)->format('d M'),
                    'total' => round($item->total, 2),
                ];
            });

        // Répartition par catégorie (mois)
        $revenueByCategory = Transaction::where('transactions.startup_id', $startupId)
            ->whereBetween('transactions.date', [Carbon::now()->subDays(29), Carbon::today()])
            ->join('categories', 'transactions.category_id', '=', 'categories.id')
            ->select(
                'categories.name as category_name',
                'categories.color as category_color',
                DB::raw('SUM(transactions.amount) as total')
            )
            ->groupBy('categories.id', 'categories.name', 'categories.color')
            ->get()
            ->map(function ($item) {
                return [
                    'category_name' => $item->category_name,
                    'category_color' => $item->category_color ?? '#4F46E5',
                    'total' => round($item->total, 2),
                ];
            });

        // Top 5 sources de revenus (mois)
        $topSources = Transaction::where('transactions.startup_id', $startupId)
            ->whereBetween('transactions.date', [Carbon::now()->subDays(29), Carbon::today()])
            ->select('transactions.source', DB::raw('SUM(transactions.amount) as total'))
            ->groupBy('transactions.source')
            ->orderBy('total', 'desc')
            ->limit(5)
            ->get()
            ->map(function ($item) {
                return [
                    'source' => $item->source,
                    'total' => round($item->total, 2),
                ];
            });

        // Prévisions (basées sur la moyenne des 30 derniers jours)
        $forecast = $this->getForecast($startupId, 30);

        return [
            'revenue_by_period' => $revenueByPeriod,
            'revenue_by_category' => $revenueByCategory,
            'top_sources' => $topSources,
            'forecast' => round($forecast, 2),
        ];
    }

    /**
     * Récupérer les données de graphique annuel
     * (12 derniers mois)
     */
    public function getYearlyChartData($startupId)
    {
        // Données mensuelles pour les 12 derniers mois
        $revenueByPeriod = Transaction::where('transactions.startup_id', $startupId)
            ->whereBetween('transactions.date', [Carbon::now()->subMonths(11)->startOfMonth(), Carbon::today()])
            ->select(
                DB::raw("DATE_FORMAT(transactions.date, '%Y-%m') as period"),
                DB::raw('SUM(transactions.amount) as total')
            )
            ->groupBy('period')
            ->orderBy('period')
            ->get()
            ->map(function ($item) {
                return [
                    'period' => Carbon::parse($item->period . '-01')->format('M Y'),
                    'total' => round($item->total, 2),
                ];
            });

        // Répartition par catégorie (année)
        $revenueByCategory = Transaction::where('transactions.startup_id', $startupId)
            ->whereBetween('transactions.date', [Carbon::now()->subMonths(11)->startOfMonth(), Carbon::today()])
            ->join('categories', 'transactions.category_id', '=', 'categories.id')
            ->select(
                'categories.name as category_name',
                'categories.color as category_color',
                DB::raw('SUM(transactions.amount) as total')
            )
            ->groupBy('categories.id', 'categories.name', 'categories.color')
            ->get()
            ->map(function ($item) {
                return [
                    'category_name' => $item->category_name,
                    'category_color' => $item->category_color ?? '#4F46E5',
                    'total' => round($item->total, 2),
                ];
            });

        // Top 5 sources de revenus (année)
        $topSources = Transaction::where('transactions.startup_id', $startupId)
            ->whereBetween('transactions.date', [Carbon::now()->subMonths(11)->startOfMonth(), Carbon::today()])
            ->select('transactions.source', DB::raw('SUM(transactions.amount) as total'))
            ->groupBy('transactions.source')
            ->orderBy('total', 'desc')
            ->limit(5)
            ->get()
            ->map(function ($item) {
                return [
                    'source' => $item->source,
                    'total' => round($item->total, 2),
                ];
            });

        // Prévisions (basées sur la moyenne des 12 derniers mois)
        $forecast = $this->getForecast($startupId, 365);

        return [
            'revenue_by_period' => $revenueByPeriod,
            'revenue_by_category' => $revenueByCategory,
            'top_sources' => $topSources,
            'forecast' => round($forecast, 2),
        ];
    }

    /**
     * Calculer les prévisions de revenus
     * Utilise une moyenne mobile simple
     * 
     * @param int $startupId
     * @param int $days Nombre de jours pour la moyenne
     * @return float
     */
    public function getForecast($startupId, $days = 30)
    {
        // Récupérer les revenus des X derniers jours
        $transactions = Transaction::where('transactions.startup_id', $startupId)
            ->whereBetween('transactions.date', [Carbon::now()->subDays($days), Carbon::now()->subDay()])
            ->select('transactions.date', DB::raw('SUM(transactions.amount) as total'))
            ->groupBy('transactions.date')
            ->orderBy('transactions.date')
            ->get()
            ->pluck('total')
            ->toArray();

        // Si pas de données, retourner 0
        if (empty($transactions)) {
            return 0;
        }

        // Calcul de la moyenne mobile simple
        $average = array_sum($transactions) / count($transactions);

        // Ajustement pour la tendance (si plus de 7 jours de données)
        if (count($transactions) >= 7) {
            // Tendance linéaire simple
            $recentAvg = array_sum(array_slice($transactions, -7)) / 7;
            $olderAvg = array_sum(array_slice($transactions, 0, 7)) / 7;
            $trend = $recentAvg - $olderAvg;
            
            // Ajuster la prévision avec la tendance
            $forecast = $average + ($trend * 0.3);
        } else {
            $forecast = $average;
        }

        // S'assurer que le résultat est positif
        return max(0, $forecast);
    }

    /**
     * Récupérer les données de graphique par période personnalisée
     * 
     * @param int $startupId
     * @param string $startDate
     * @param string $endDate
     * @return array
     */
    public function getCustomChartData($startupId, $startDate, $endDate)
    {
        $start = Carbon::parse($startDate);
        $end = Carbon::parse($endDate);
        $daysDiff = $start->diffInDays($end);

        // Déterminer le groupement en fonction de la durée
        if ($daysDiff <= 1) {
            $groupBy = "DATE_FORMAT(transactions.date, '%H:00')";
            $format = 'H:00';
        } elseif ($daysDiff <= 7) {
            $groupBy = "DATE_FORMAT(transactions.date, '%Y-%m-%d')";
            $format = 'D d';
        } elseif ($daysDiff <= 31) {
            $groupBy = "DATE_FORMAT(transactions.date, '%Y-%m-%d')";
            $format = 'd M';
        } elseif ($daysDiff <= 365) {
            $groupBy = "DATE_FORMAT(transactions.date, '%Y-%m')";
            $format = 'M Y';
        } else {
            $groupBy = "DATE_FORMAT(transactions.date, '%Y')";
            $format = 'Y';
        }

        // Données par période
        $revenueByPeriod = Transaction::where('transactions.startup_id', $startupId)
            ->whereBetween('transactions.date', [$start, $end])
            ->select(
                DB::raw("$groupBy as period"),
                DB::raw('SUM(transactions.amount) as total')
            )
            ->groupBy('period')
            ->orderBy('period')
            ->get()
            ->map(function ($item) use ($format) {
                return [
                    'period' => $item->period,
                    'total' => round($item->total, 2),
                ];
            });

        // Répartition par catégorie
        $revenueByCategory = Transaction::where('transactions.startup_id', $startupId)
            ->whereBetween('transactions.date', [$start, $end])
            ->join('categories', 'transactions.category_id', '=', 'categories.id')
            ->select(
                'categories.name as category_name',
                'categories.color as category_color',
                DB::raw('SUM(transactions.amount) as total')
            )
            ->groupBy('categories.id', 'categories.name', 'categories.color')
            ->get()
            ->map(function ($item) {
                return [
                    'category_name' => $item->category_name,
                    'category_color' => $item->category_color ?? '#4F46E5',
                    'total' => round($item->total, 2),
                ];
            });

        // Top 5 sources
        $topSources = Transaction::where('transactions.startup_id', $startupId)
            ->whereBetween('transactions.date', [$start, $end])
            ->select('transactions.source', DB::raw('SUM(transactions.amount) as total'))
            ->groupBy('transactions.source')
            ->orderBy('total', 'desc')
            ->limit(5)
            ->get()
            ->map(function ($item) {
                return [
                    'source' => $item->source,
                    'total' => round($item->total, 2),
                ];
            });

        // Prévisions
        $forecast = $this->getForecast($startupId, min($daysDiff, 30));

        return [
            'revenue_by_period' => $revenueByPeriod,
            'revenue_by_category' => $revenueByCategory,
            'top_sources' => $topSources,
            'forecast' => round($forecast, 2),
        ];
    }

    /**
     * Récupérer les statistiques d'une startup
     * 
     * @param int $startupId
     * @return array
     */
    public function getStartupStats($startupId)
    {
        $totalRevenue = Transaction::where('transactions.startup_id', $startupId)->sum('transactions.amount');
        
        $monthlyRevenue = Transaction::where('transactions.startup_id', $startupId)
            ->whereBetween('transactions.date', [Carbon::now()->startOfMonth(), Carbon::now()->endOfMonth()])
            ->sum('transactions.amount');
        
        $dailyRevenue = Transaction::where('transactions.startup_id', $startupId)
            ->whereDate('transactions.date', Carbon::today())
            ->sum('transactions.amount');
        
        $transactionCount = Transaction::where('transactions.startup_id', $startupId)->count();
        
        $categoryCount = Transaction::where('transactions.startup_id', $startupId)
            ->distinct('category_id')
            ->count();
        
        $userCount = Startup::where('id', $startupId)->first()->users()->count();

        return [
            'total_revenue' => round($totalRevenue, 2),
            'monthly_revenue' => round($monthlyRevenue, 2),
            'daily_revenue' => round($dailyRevenue, 2),
            'transaction_count' => $transactionCount,
            'category_count' => $categoryCount,
            'user_count' => $userCount,
        ];
    }

    /**
     * Récupérer les transactions récentes d'une startup
     * 
     * @param int $startupId
     * @param int $limit
     * @return \Illuminate\Database\Eloquent\Collection
     */
    public function getRecentTransactions($startupId, $limit = 10)
    {
        return Transaction::where('transactions.startup_id', $startupId)
            ->with('category')
            ->orderBy('transactions.date', 'desc')
            ->orderBy('transactions.created_at', 'desc')
            ->limit($limit)
            ->get()
            ->map(function ($transaction) {
                return [
                    'id' => $transaction->id,
                    'amount' => round($transaction->amount, 2),
                    'date' => $transaction->date->format('Y-m-d'),
                    'source' => $transaction->source,
                    'description' => $transaction->description,
                    'category' => $transaction->category?->name,
                    'category_color' => $transaction->category?->color ?? '#4F46E5',
                ];
            });
    }

    /**
     * Calculer les métriques de comparaison
     * 
     * @param int $startupId
     * @param string $period (day, week, month, year)
     * @return array
     */
    public function getComparisonMetrics($startupId, $period = 'month')
    {
        switch ($period) {
            case 'day':
                $currentPeriod = Carbon::today();
                $previousPeriod = Carbon::yesterday();
                break;
            case 'week':
                $currentPeriod = [Carbon::now()->startOfWeek(), Carbon::now()->endOfWeek()];
                $previousPeriod = [Carbon::now()->subWeek()->startOfWeek(), Carbon::now()->subWeek()->endOfWeek()];
                break;
            case 'month':
                $currentPeriod = [Carbon::now()->startOfMonth(), Carbon::now()->endOfMonth()];
                $previousPeriod = [Carbon::now()->subMonth()->startOfMonth(), Carbon::now()->subMonth()->endOfMonth()];
                break;
            case 'year':
                $currentPeriod = [Carbon::now()->startOfYear(), Carbon::now()->endOfYear()];
                $previousPeriod = [Carbon::now()->subYear()->startOfYear(), Carbon::now()->subYear()->endOfYear()];
                break;
            default:
                $currentPeriod = [Carbon::now()->startOfMonth(), Carbon::now()->endOfMonth()];
                $previousPeriod = [Carbon::now()->subMonth()->startOfMonth(), Carbon::now()->subMonth()->endOfMonth()];
        }

        // Calculer les revenus de la période actuelle
        if (is_array($currentPeriod)) {
            $currentRevenue = Transaction::where('transactions.startup_id', $startupId)
                ->whereBetween('transactions.date', $currentPeriod)
                ->sum('transactions.amount');
        } else {
            $currentRevenue = Transaction::where('transactions.startup_id', $startupId)
                ->whereDate('transactions.date', $currentPeriod)
                ->sum('transactions.amount');
        }

        // Calculer les revenus de la période précédente
        if (is_array($previousPeriod)) {
            $previousRevenue = Transaction::where('transactions.startup_id', $startupId)
                ->whereBetween('transactions.date', $previousPeriod)
                ->sum('transactions.amount');
        } else {
            $previousRevenue = Transaction::where('transactions.startup_id', $startupId)
                ->whereDate('transactions.date', $previousPeriod)
                ->sum('transactions.amount');
        }

        // Calculer la variation
        $change = $previousRevenue > 0 
            ? (($currentRevenue - $previousRevenue) / $previousRevenue) * 100 
            : ($currentRevenue > 0 ? 100 : 0);

        return [
            'current_revenue' => round($currentRevenue, 2),
            'previous_revenue' => round($previousRevenue, 2),
            'change' => round($change, 2),
            'trend' => $change >= 0 ? 'up' : 'down',
        ];
    }
}