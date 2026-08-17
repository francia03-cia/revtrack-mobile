<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class Transaction extends Model
{
    use HasFactory;

    protected $fillable = [
        'amount',
        'date',
        'note',
        'receipt',
        'source',
        'tags',
        'is_recurring',
        'recurring_frequency',
        'startup_id',
        'category_id',
        'user_id',
        'project_id', // ✅ Pour lier aux projets
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'date' => 'date',
        'tags' => 'array',
        'is_recurring' => 'boolean',
    ];

    // ============ RELATIONS ============
    
    public function startup()
    {
        return $this->belongsTo(Startup::class);
    }

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function project()
    {
        return $this->belongsTo(Project::class);
    }

    // ============ SCOPES ============
    
    public function scopeForStartup($query, $startupId)
    {
        return $query->where('startup_id', $startupId);
    }

    public function scopeForPeriod($query, $startDate, $endDate)
    {
        return $query->whereBetween('date', [$startDate, $endDate]);
    }

    public function scopeForCategory($query, $categoryId)
    {
        return $query->where('category_id', $categoryId);
    }

    public function scopeForProject($query, $projectId)
    {
        return $query->where('project_id', $projectId);
    }

    public function scopeToday($query)
    {
        return $query->whereDate('date', today());
    }

    public function scopeThisWeek($query)
    {
        return $query->whereBetween('date', [now()->startOfWeek(), now()->endOfWeek()]);
    }

    public function scopeThisMonth($query)
    {
        return $query->whereMonth('date', now()->month)
                     ->whereYear('date', now()->year);
    }

    public function scopeLastMonth($query)
    {
        $lastMonth = now()->subMonth();
        return $query->whereMonth('date', $lastMonth->month)
                     ->whereYear('date', $lastMonth->year);
    }

    public function scopeThisYear($query)
    {
        return $query->whereYear('date', now()->year);
    }

    public function scopeRecurring($query)
    {
        return $query->where('is_recurring', true);
    }

    // ============ MÉTHODES UTILITAIRES ============
    
    public function getFormattedAmountAttribute()
    {
        return number_format($this->amount, 2, ',', ' ');
    }

    public function getReceiptUrlAttribute()
    {
        if ($this->receipt) {
            return asset('storage/receipts/' . $this->receipt);
        }
        return null;
    }

    public function getTagsArrayAttribute()
    {
        return is_array($this->tags) ? $this->tags : json_decode($this->tags, true) ?? [];
    }

    public function isHighValue()
    {
        $average = Transaction::forStartup($this->startup_id)->avg('amount');
        return $average > 0 && $this->amount > ($average * 3);
    }

    public function isLowValue()
    {
        $average = Transaction::forStartup($this->startup_id)->avg('amount');
        return $average > 0 && $this->amount < ($average * 0.3);
    }

    public function getDayOfWeekAttribute()
    {
        return Carbon::parse($this->date)->dayOfWeek;
    }

    public function getMonthNameAttribute()
    {
        return Carbon::parse($this->date)->format('F');
    }

    public function getYearAttribute()
    {
        return Carbon::parse($this->date)->year;
    }

    public function getWeekNumberAttribute()
    {
        return Carbon::parse($this->date)->weekOfYear;
    }

    public static function getDailyStats($startupId, $date)
    {
        $dayTransactions = self::forStartup($startupId)
                               ->whereDate('date', $date)
                               ->get();
        
        return [
            'total' => $dayTransactions->sum('amount'),
            'count' => $dayTransactions->count(),
            'average' => $dayTransactions->avg('amount') ?? 0,
            'max' => $dayTransactions->max('amount') ?? 0,
            'min' => $dayTransactions->min('amount') ?? 0,
            'transactions' => $dayTransactions,
        ];
    }

    public static function getMonthlyStats($startupId, $month, $year)
    {
        $monthTransactions = self::forStartup($startupId)
                                  ->whereMonth('date', $month)
                                  ->whereYear('date', $year)
                                  ->get();
        
        return [
            'total' => $monthTransactions->sum('amount'),
            'count' => $monthTransactions->count(),
            'average' => $monthTransactions->avg('amount') ?? 0,
            'by_category' => $monthTransactions->groupBy('category_id')
                                               ->map(function ($items) {
                                                   return [
                                                       'total' => $items->sum('amount'),
                                                       'count' => $items->count(),
                                                   ];
                                               }),
        ];
    }

    public static function getGrowthRate($startupId, $period = 'month')
    {
        $current = self::forStartup($startupId)->thisMonth()->sum('amount');
        $previous = self::forStartup($startupId)->lastMonth()->sum('amount');
        
        if ($previous == 0) {
            return $current > 0 ? 100 : 0;
        }
        
        return round((($current - $previous) / $previous) * 100, 2);
    }

    /**
     * Attacher une transaction à un projet et mettre à jour le montant payé
     */
    public function attachToProject($projectId)
    {
        if ($projectId) {
            $this->project_id = $projectId;
            $this->save();
            
            // Mettre à jour le montant payé du projet
            $project = Project::find($projectId);
            if ($project) {
                $project->amount_paid = $project->transactions()->sum('amount');
                $project->updateBudgetStatus();
                $project->save();
            }
        }
    }

    /**
     * Détacher une transaction d'un projet
     */
    public function detachFromProject()
    {
        $projectId = $this->project_id;
        $this->project_id = null;
        $this->save();
        
        if ($projectId) {
            $project = Project::find($projectId);
            if ($project) {
                $project->amount_paid = $project->transactions()->sum('amount');
                $project->updateBudgetStatus();
                $project->save();
            }
        }
    }
}