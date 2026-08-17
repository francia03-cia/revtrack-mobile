<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class DashboardResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'kpis' => [
                'today' => $this['kpis']['today'] ?? 0,
                'this_week' => $this['kpis']['this_week'] ?? 0,
                'this_month' => $this['kpis']['this_month'] ?? 0,
                'this_year' => $this['kpis']['this_year'] ?? 0,
                'growth_rate' => $this['kpis']['growth_rate'] ?? 0,
                'monthly_goal' => $this['kpis']['monthly_goal'] ?? 0,
                'goal_progress' => $this['kpis']['goal_progress'] ?? 0,
            ],
            'chart_data' => [
                'daily' => $this['chart_data']['daily'] ?? [],
                'weekly' => $this['chart_data']['weekly'] ?? [],
                'monthly' => $this['chart_data']['monthly'] ?? [],
                'categories' => $this['chart_data']['categories'] ?? [],
                'comparison' => $this['chart_data']['comparison'] ?? [],
            ],
            'top_sources' => $this['top_sources'] ?? [],
            'recent_transactions' => TransactionResource::collection($this['recent_transactions'] ?? []),
            'forecast' => $this['forecast'] ?? null,
        ];
    }
}