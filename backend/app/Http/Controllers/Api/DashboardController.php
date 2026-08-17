<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\RevenueService;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    protected $revenueService;

    public function __construct(RevenueService $revenueService)
    {
        $this->revenueService = $revenueService;
    }

    /**
     * Récupérer les KPIs du tableau de bord
     */
    public function getKPIs(Request $request)
    {
        $startupId = $request->get('startup_id', $request->user()->startups->first()->id ?? null);
        
        if (!$startupId) {
            return response()->json([
                'message' => 'Aucune startup trouvée'
            ], 404);
        }

        try {
            $kpis = $this->revenueService->getKPIs($startupId);
            return response()->json($kpis);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erreur lors de la récupération des KPIs',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Récupérer les données des graphiques
     */
    public function getChartData(Request $request)
    {
        $startupId = $request->get('startup_id', $request->user()->startups->first()->id ?? null);
        $period = $request->get('period', 'month');
        
        if (!$startupId) {
            return response()->json([
                'message' => 'Aucune startup trouvée'
            ], 404);
        }

        try {
            $chartData = $this->revenueService->getChartData($startupId, $period);
            return response()->json($chartData);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erreur lors de la récupération des données',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Récupérer les comparaisons de période
     */
    public function getComparison(Request $request)
    {
        $startupId = $request->get('startup_id', $request->user()->startups->first()->id ?? null);
        $period = $request->get('period', 'month');
        
        if (!$startupId) {
            return response()->json([
                'message' => 'Aucune startup trouvée'
            ], 404);
        }

        try {
            $comparison = $this->revenueService->getComparisonMetrics($startupId, $period);
            return response()->json($comparison);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erreur lors de la récupération des comparaisons',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Récupérer les données de graphique personnalisé
     */
    public function getCustomChart(Request $request)
    {
        $startupId = $request->get('startup_id', $request->user()->startups->first()->id ?? null);
        $startDate = $request->get('start_date');
        $endDate = $request->get('end_date');
        
        if (!$startupId) {
            return response()->json([
                'message' => 'Aucune startup trouvée'
            ], 404);
        }

        if (!$startDate || !$endDate) {
            return response()->json([
                'message' => 'Les dates de début et de fin sont requises'
            ], 422);
        }

        try {
            $chartData = $this->revenueService->getCustomChartData($startupId, $startDate, $endDate);
            return response()->json($chartData);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erreur lors de la récupération des données',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Récupérer les statistiques de la startup
     */
    public function getStats(Request $request)
    {
        $startupId = $request->get('startup_id', $request->user()->startups->first()->id ?? null);
        
        if (!$startupId) {
            return response()->json([
                'message' => 'Aucune startup trouvée'
            ], 404);
        }

        try {
            $stats = $this->revenueService->getStartupStats($startupId);
            return response()->json($stats);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erreur lors de la récupération des statistiques',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Récupérer les transactions récentes
     */
    public function getRecentTransactions(Request $request)
    {
        $startupId = $request->get('startup_id', $request->user()->startups->first()->id ?? null);
        $limit = $request->get('limit', 10);
        
        if (!$startupId) {
            return response()->json([
                'message' => 'Aucune startup trouvée'
            ], 404);
        }

        try {
            $transactions = $this->revenueService->getRecentTransactions($startupId, $limit);
            return response()->json($transactions);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erreur lors de la récupération des transactions',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Récupérer les prévisions de revenus
     */
    public function getForecast(Request $request)
    {
        $startupId = $request->get('startup_id', $request->user()->startups->first()->id ?? null);
        $days = $request->get('days', 30);
        
        if (!$startupId) {
            return response()->json([
                'message' => 'Aucune startup trouvée'
            ], 404);
        }

        try {
            $forecast = $this->revenueService->getForecast($startupId, $days);
            return response()->json([
                'forecast' => round($forecast, 2),
                'days' => $days,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erreur lors du calcul des prévisions',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}