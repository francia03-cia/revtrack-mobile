<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Project extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'start_date',
        'end_date',
        'budget',
        'amount_paid',
        'budget_status',
        'progress_status',
        'startup_id',
        'category_id',
        'user_id',
        'description',
    ];

    protected $casts = [
        'start_date' => 'date',
        'end_date' => 'date',
        'budget' => 'decimal:2',
        'amount_paid' => 'decimal:2',
    ];

    // Relations
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

    public function transactions()
    {
        return $this->hasMany(Transaction::class);
    }

    // Scopes
    public function scopeForStartup($query, $startupId)
    {
        return $query->where('startup_id', $startupId);
    }

    public function scopeWithStatus($query, $status)
    {
        return $query->where('progress_status', $status);
    }

    public function scopeBudgetStatus($query, $status)
    {
        return $query->where('budget_status', $status);
    }

    // Méthodes
    public function updateBudgetStatus()
    {
        if ($this->amount_paid >= $this->budget) {
            $this->budget_status = 'paid';
        } else {
            $this->budget_status = 'unpaid';
        }
        $this->save();
    }

    public function updateProgressStatus()
    {
        $now = now();
        if ($this->end_date && $this->end_date->isPast()) {
            $this->progress_status = 'delayed';
        } elseif ($this->progress_status === 'delayed' && $this->end_date && !$this->end_date->isPast()) {
            $this->progress_status = 'ongoing';
        }
        $this->save();
    }

    public function getProgressPercentageAttribute()
    {
        if ($this->budget <= 0) return 0;
        return min(100, round(($this->amount_paid / $this->budget) * 100));
    }

    public function getRemainingBudgetAttribute()
    {
        return max(0, $this->budget - $this->amount_paid);
    }

    public function getIsOverBudgetAttribute()
    {
        return $this->amount_paid > $this->budget;
    }
}